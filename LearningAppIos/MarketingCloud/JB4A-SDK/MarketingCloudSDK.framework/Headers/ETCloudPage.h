//
//  ETCloudPage.h
//  JB4A-SDK-iOS
//
//  JB4A iOS SDK GitHub Repository
//  https://salesforce-marketingcloud.github.io/JB4A-SDK-iOS/
//
//  Copyright © 2016 Salesforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PushConstants.h"
#import <CoreLocation/CoreLocation.h>

/**
 ETCloudPage class defines the cloudpage message type. The ETCloudPage object defines the inbox message properties which are used to support and store rich messages from the MarketingCloud. This class works with the ETCloudPageDataSource which is suitable for displaying the inbox UITableView.
 */
@interface ETCloudPage : NSObject

/**
 Encoded ID from Salesforce. Will match the ID in MobilePush. This is the primary key.
 @deprecated in __DOC_REPLACEME__
 */
@property (nonatomic, readonly, copy, nullable) NSString *messageIdentifier __attribute__((deprecated("__REPLACEME__")));

/**
 This is the name which is set on SalesforceMarketingCloud, while setting the ETMessage
 @deprecated in __DOC_REPLACEME__
 */
@property (nonatomic, readonly, copy, nullable) NSString *messageName __attribute__((deprecated("__REPLACEME__")));


/**
 The alert text of the message. This displays on the screen.
 @deprecated in __DOC_REPLACEME__
 */
@property (nonatomic, readonly, copy, nullable) NSString *alert __attribute__((deprecated("__REPLACEME__")));

/**
 The category name for an interactive notification if it has one.
 @deprecated in __DOC_REPLACEME__
 */
@property (nonatomic, readonly, copy, nullable) NSString *category __attribute__((deprecated("__REPLACEME__")));

/**
 An array of Key Value Pairs, or Custom Keys in local parlance, for this message. This will contain NSDictionary objects.
 @deprecated in __DOC_REPLACEME__
 */
@property (nonatomic, readonly, copy, nullable) NSArray *keyValuePairs __attribute__((deprecated("__REPLACEME__")));

/**
 The message's start date. Messages shouldn't show before this time.
 @deprecated in __DOC_REPLACEME__
 */
@property (nonatomic, readonly, copy, nullable) NSDate *startDate __attribute__((deprecated("__REPLACEME__")));

/**
 The message's end date. Messages shouldn't show after this time.
 @deprecated in __DOC_REPLACEME__
 */
@property (nonatomic, readonly, copy, nullable) NSDate *endDate __attribute__((deprecated("__REPLACEME__")));


/**
 The Site URL for the ClouePage attached to this message. It is saved as an NSString and converted later to NSURL.
 @deprecated in __DOC_REPLACEME__
 */
@property (nonatomic, readonly, copy, nullable) NSString *siteUrlAsString __attribute__((deprecated("__REPLACEME__")));

/**
 OpenDirect payload for this message, if there is one.
 @deprecated in __DOC_REPLACEME__
 */
@property (nonatomic, readonly, copy, nullable) NSString *openDirectPayload __attribute__((deprecated("__REPLACEME__")));


/**
 Whether or not the message has been read. This must be set through markAsRead by the developer.
 @deprecated in __DOC_REPLACEME__
 */
@property (nonatomic, readonly, getter = isRead) BOOL read __attribute__((deprecated("__REPLACEME__")));


/**
 Use this for display in an inbox.
 @deprecated in __DOC_REPLACEME__
 */
@property (nonatomic, readonly, copy, nullable) NSString *subject __attribute__((deprecated("__REPLACEME__")));

/**
 A Cleansed Site URL as a proper NSURL. This is mostly for convenience.
 @deprecated in __DOC_REPLACEME__
 */
@property (nonatomic, readonly, copy, nullable) NSURL *siteURL __attribute__((deprecated("__REPLACEME__")));



/**
 Marks a message as deleted. They will not be returned after this, and it's irreversable.
 @deprecated in __DOC_REPLACEME__
 */
-(BOOL)markAsDeleted DEPRECATED_MSG_ATTRIBUTE("__REPLACEME__");

/**
 Marks a message as read in the local cache. Read messages do not show up in the Inbox.
 @deprecated in __DOC_REPLACEME__
 */
-(BOOL)markAsRead DEPRECATED_MSG_ATTRIBUTE("__REPLACEME__");

@end
