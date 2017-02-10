Pod::Spec.new do |s|
    s.name              = "MarketingCloudSDK"
    s.version           = "4.8.0"
    s.summary           = "Salesforce Marketing Cloud iOS SDK"
    s.homepage          = "https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/"
    s.documentation_url = 'https://salesforce-marketingcloud.github.io/MarketingCloudSDK-iOS/appledoc/index.html'
    s.license           = { :type => "Salesforce Marketing Cloud iOS SDK License", :file => "LICENSE.md" }
    s.author            = "Salesforce Marketing Cloud"
    s.platform          = :ios, "9.0"
    s.source            = { :git => "https://github.com/salesforce-marketingcloud/MarketingCloudSDK-iOS.git",
                            :tag => "v#{s.version}"}
    s.preserve_path    = 'MarketingCloudSDK/MarketingCloudSDK.framework'
    s.requires_arc      = true
    s.vendored_frameworks = 'MarketingCloudSDK/MarketingCloudSDK.framework'
    s.frameworks        = 'WebKit', 'CoreLocation', 'UserNotifications', 'UIKit'
end
