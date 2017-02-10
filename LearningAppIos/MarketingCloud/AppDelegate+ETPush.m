/*
 * Copyright (c) 2016, salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license.
 * For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
 */

#import "AppDelegate+ETPush.h"
#import "AppDelegate+ETPushConstants.h"
#import <MarketingCloudSDK/MarketingCloudSDK.h>
#import <UserNotifications/UserNotifications.h>

@implementation AppDelegate (ETPush)
#pragma mark - SDK Setup
- (BOOL)application:(UIApplication *)application shouldInitETSDKWithOptions:(NSDictionary *)launchOptions {
    
    BOOL successful = NO;
    NSError *error = nil;
    
    [[MarketingCloudSDK sfmcSDK] sfmc_setCloudPageWithAlertDelegate:self];
    
#ifdef DEBUG
    /**
     To enable Debug Log set to YES
     */
    [MarketingCloudSDK sfmc_enableSDKLogging:YES];
    
    successful = [[MarketingCloudSDK sfmcSDK] sfmc_configureSDKWithAppID:kETAppID_Debug				// Configure the SDK with the Debug App ID
                                              accessToken:kETAccessToken_Debug		// Configure the SDK with the Debug Access Token
                                               analyticsEnabled:YES						// Enable Analytics
                                         locationServicesEnabled:YES                        // Enable Location Services (Geofence Messaging)
                                        proximityServicesEnabled:YES						// Enable Proximity services (Beacon Messaging)
                                               cloudPagesEnabled:YES						// Enable Cloud Pages
                                             piAnalyticsEnabled:YES						// Enable WAMA / PI Analytics
                                                       error:&error];
    
#else
    /**
     Configure and set initial settings of the JB4ASDK when in PRODUCTION mode
     */
    successful = [[MarketingCloudSDK sfmcSDK] sfmc_configureSDKWithAppID:kETAppID_Prod				// Configure the SDK with the Debug App ID
                                              accessToken:kETAccessToken_Prod		// Configure the SDK with the Debug Access Token
                                                   analyticsEnabled:YES						// Enable Analytics
                                            locationServicesEnabled:YES                        // Enable Location Services (Geofence Messaging)
                                           proximityServicesEnabled:YES						// Enable Proximity services (Beacon Messaging)
                                                  cloudPagesEnabled:YES						// Enable Cloud Pages
                                                 piAnalyticsEnabled:YES						// Enable WAMA / PI Analytics
                                                              error:&error];
#endif
    /**
     If configureSDKWithAppID returns NO, check the error object for detailed failure info. See PushConstants.h for codes.
     The features of the JB4ASDK will NOT be useable unless configureSDKWithAppID returns YES.
     */
    if (!successful) {
        dispatch_async(dispatch_get_main_queue(), ^{
            /**
             Something has failed in the configureSDKWithAppID call - show error message
             Because this only occurs when an error has occured, and because UIAlertView
             is deprecated in iOS 9+, but we're backwards compatible these pragma marks
             disable deprecation warnings for UIAlertView.
             */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed configureSDKWithAppID!", @"Failed configureSDKWithAppID!")
                                        message:[error localizedDescription]
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                              otherButtonTitles:nil] show];
#pragma clang diagnostic pop
            
        });
        
        [MarketingCloudSDK sfmc_trackPageView:@"data://SDKInitializationFailed" andTitle:[error localizedDescription] andItem:nil andSearch:nil];
        
    } else {
        /**
         Register for push notifications - enable all notification types, no categories
         */
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max) {
            [[MarketingCloudSDK sfmcSDK] sfmc_registerForRemoteNotificationsWithDelegate:self options:(UNAuthorizationOptionAlert + UNAuthorizationOptionBadge + UNAuthorizationOptionSound) categories:nil completionHandler:^(BOOL granted, NSError * _Nullable error) {
                
                NSLog(@"Registered for remote notifications: %d", granted);
                
            }];
        }
        else {
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound |
                                                    UIUserNotificationTypeAlert
                                                                                     categories:nil];
            // Notify the SDK what user notification settings have been selected
            [[MarketingCloudSDK sfmcSDK] sfmc_registerUserNotificationSettings:settings];
            [[MarketingCloudSDK sfmcSDK] sfmc_registerForRemoteNotifications];
        }
        
        /**
         Start geoLocation
         */
        [[MarketingCloudSDK sfmcSDK] sfmc_startWatchingLocation];
        
        /**
         Inform the JB4ASDK of the launch options - possibly UIApplicationLaunchOptionsRemoteNotificationKey or UIApplicationLaunchOptionsLocalNotificationKey
         */
        [[MarketingCloudSDK sfmcSDK] sfmc_applicationLaunchedWithOptions:launchOptions];
        
        [MarketingCloudSDK sfmc_trackPageView:@"data://SDKInitializationCompletedSuccessfully" andTitle:@"SDK Initialization Completed" andItem:nil andSearch:nil];
        // set an attribute called 'MyBooleanAttribute' with value '0'
        [[MarketingCloudSDK sfmcSDK] sfmc_addAttributeNamed:@"MyBooleanAttribute" value:@"0"];
        
        /*
         Example of using the getSDKState Method for rapidly debugging issues
         */
        [MarketingCloudSDK sfmc_sdkState];
        
    }
    
    return YES;
}

#pragma mark - Lifecycle Callbacks

// The method will be called on the delegate only if the application is in the foreground. If the method is not implemented or the handler is not called in a timely manner then the notification will not be presented. The application can choose to have the notification presented as a sound, badge, alert and/or in the notification list. This decision should be based on whether the information in the notification is otherwise visible to the user.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    
    if (completionHandler != nil) {
        if ([[MarketingCloudSDK sfmcSDK] sfmc_showRemoteNotificationWhenAppInForeground] == YES) {
            completionHandler(UNNotificationPresentationOptionAlert);
        }
        else {
            [[MarketingCloudSDK sfmcSDK] sfmc_handleNotification:notification.request.content.userInfo forApplicationState:[UIApplication sharedApplication].applicationState];
            completionHandler(UNNotificationPresentationOptionNone);
        }
    }
    else {
        [[MarketingCloudSDK sfmcSDK] sfmc_handleNotification:notification.request.content.userInfo forApplicationState:[UIApplication sharedApplication].applicationState];
    }
}

// The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from applicationDidFinishLaunching:.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler {
    
    /**
     Inform the JB4ASDK that the device received a remote notification
     */
    [[MarketingCloudSDK sfmcSDK] sfmc_handleUserNotificationResponse:response];
    
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    /**
     Is it a silent push?
     */
    if (userInfo[@"aps"][@"content-available"]) {
        /**
         Received a silent remote notification...
         Indicate a silent push
         */
        NSLog(@"Silent Push Notification Received");
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    } else {
        /**
         Received a remote notification...
         Clear the badge
         */
        [[MarketingCloudSDK sfmcSDK] sfmc_resetBadgeCount];
    }

    if (completionHandler != nil) {
        completionHandler();
    }
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    /**
     Inform the JB4ASDK of the requested notification settings
     */
    [[MarketingCloudSDK sfmcSDK] sfmc_didRegisterUserNotificationSettings:notificationSettings];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    /**
     Inform the JB4ASDK of the device token
     */
    [[MarketingCloudSDK sfmcSDK] sfmc_registerDeviceToken:deviceToken];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    /**
     Inform the JB4ASDK that the device failed to register and did not receive a device token
     */
    [[MarketingCloudSDK sfmcSDK] sfmc_applicationDidFailToRegisterForRemoteNotificationsWithError:error];
    [MarketingCloudSDK sfmc_trackPageView:@"data://applicationDidFailToRegisterForRemoteNotificationsWithError" andTitle:[error localizedDescription] andItem:nil andSearch:nil];
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /**
     Use this method to disable Location Services through the MobilePush SDK.
     */
    [[MarketingCloudSDK sfmcSDK] sfmc_startWatchingLocation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /**
     Use this method to initiate Location Services through the MobilePush SDK.
     */
    [[MarketingCloudSDK sfmcSDK] sfmc_stopWatchingLocation];
}

#pragma mark - Message Received Callbacks
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    /**
     Inform the JB4ASDK that the device received a local notification
     */
    NSLog(@"Local Notification Receieved");
    [[MarketingCloudSDK sfmcSDK] sfmc_handleLocalNotification:notification];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler {
    /**
     Inform the JB4ASDK that the device received a remote notification
     */
    [[MarketingCloudSDK sfmcSDK] sfmc_handleNotification:userInfo forApplicationState:application.applicationState];
    
    /**
     Is it a silent push?
     */
    if (userInfo[@"aps"][@"content-available"]) {
        /**
         Received a silent remote notification...
         Indicate a silent push
         */
        NSLog(@"Silent Push Notification Received");
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    } else {
        /**
         Received a remote notification...
         Clear the badge
         */
        [[MarketingCloudSDK sfmcSDK] sfmc_resetBadgeCount];
    }
    
    handler(UIBackgroundFetchResultNoData);
}

#pragma mark Cloud Page delegates
- (void)sfmc_didReceiveCloudPageWithAlertMessageWithContents:(NSString *)payload {
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:[[MarketingCloudSDK sfmcSDK] landingPageWithString:payload]
                                                                                 animated:YES
                                                                               completion:nil];
}

-(BOOL)shouldDeliverCloudPageWithAlertMessageIfAppIsRunning {
    return YES;
}


@end
