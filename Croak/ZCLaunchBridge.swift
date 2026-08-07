import UIKit
import Foundation
import ZCLaunchKit

@objc(ZCLaunchBridge)
public final class ZCLaunchBridge: NSObject {
    @objc(bootWithApplication:launchOptions:)
    public static func boot(application: UIApplication, launchOptions: NSDictionary?) -> Bool {
        var typedOptions: [UIApplication.LaunchOptionsKey: Any]?
        if let launchOptions {
            typedOptions = [:]
            for (key, value) in launchOptions {
                if let key = key as? UIApplication.LaunchOptionsKey {
                    typedOptions?[key] = value
                } else if let key = key as? String {
                    typedOptions?[UIApplication.LaunchOptionsKey(rawValue: key)] = value
                }
            }
        }

        return ZCLaunchKit.boot(application, didFinishLaunchingWithOptions: typedOptions)
    }
}
