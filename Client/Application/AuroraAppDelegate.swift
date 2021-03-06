/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Alamofire
import MessageUI

private let AuroraPropertyListURL = "https://pvtbuilds.mozilla.org/ios/FennecAurora.plist"
private let AuroraDownloadPageURL = "https://pvtbuilds.mozilla.org/ios/index.html"

private let AppUpdateTitle = NSLocalizedString("New version available", comment: "Prompt title for application update")
private let AppUpdateMessage = NSLocalizedString("There is a new version available of Firefox Aurora. Tap OK to go to the download page.", comment: "Prompt message for application update")
private let AppUpdateCancel = NSLocalizedString("Not Now", comment: "Label for button to cancel application update prompt")
private let AppUpdateOK = NSLocalizedString("OK", comment: "Label for OK button in the application update prompt")

class AuroraAppDelegate: AppDelegate {
    private var naggedAboutAuroraUpdate = false

    override func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        super.application(application, willFinishLaunchingWithOptions: launchOptions)

        checkForAuroraUpdate()
        registerFeedbackNotification()

        return true
    }

    func applicationDidBecomeActive(application: UIApplication) {
        if !naggedAboutAuroraUpdate {
            checkForAuroraUpdate()
        }
    }

    func application(application: UIApplication, applicationWillTerminate app: UIApplication) {
        unregisterFeedbackNotification()
    }

    func applicationWillResignActive(application: UIApplication) {
        unregisterFeedbackNotification()
    }

    private func registerFeedbackNotification() {
        NSNotificationCenter.defaultCenter().addObserverForName(
            UIApplicationUserDidTakeScreenshotNotification,
            object: nil,
            queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
                if let window = self.window {
                    UIGraphicsBeginImageContext(window.bounds.size)
                    window.drawViewHierarchyInRect(window.bounds, afterScreenUpdates: true)
                    let image = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    self.sendFeedbackMailWithImage(image)
                }
        }
    }

    private func unregisterFeedbackNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: UIApplicationUserDidTakeScreenshotNotification, object: nil)
    }
}

extension AuroraAppDelegate: UIAlertViewDelegate {
    private func checkForAuroraUpdate() {
        if let localVersion = localVersion() {
            fetchLatestAuroraVersion() { version in
                if let remoteVersion = version {
                    if localVersion.compare(remoteVersion as String, options: NSStringCompareOptions.NumericSearch) == NSComparisonResult.OrderedAscending {
                        self.naggedAboutAuroraUpdate = true

                        let alert = UIAlertView(title: AppUpdateTitle, message: AppUpdateMessage, delegate: self, cancelButtonTitle: AppUpdateCancel, otherButtonTitles: AppUpdateOK)
                        alert.show()
                    }
                }
            }
        }
    }

    private func localVersion() -> NSString? {
        return NSBundle.mainBundle().objectForInfoDictionaryKey(String(kCFBundleVersionKey)) as? NSString
    }

    private func fetchLatestAuroraVersion(completionHandler: NSString? -> Void) {
        Alamofire.request(.GET, AuroraPropertyListURL).responsePropertyList(options: NSPropertyListReadOptions.allZeros, completionHandler: { (_, _, object, _) -> Void in
            if let plist = object as? NSDictionary {
                if let items = plist["items"] as? NSArray {
                    if let item = items[0] as? NSDictionary {
                        if let metadata = item["metadata"] as? NSDictionary {
                            if let remoteVersion = metadata["bundle-version"] as? String {
                                completionHandler(remoteVersion)
                                return
                            }
                        }
                    }
                }
            }
            completionHandler(nil)
        })
    }

    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            UIApplication.sharedApplication().openURL(NSURL(string: AuroraDownloadPageURL)!)
        }
    }
}

extension AuroraAppDelegate: MFMailComposeViewControllerDelegate {
    private func sendFeedbackMailWithImage(image: UIImage) {
        if (MFMailComposeViewController.canSendMail()) {
            if let buildNumber = NSBundle.mainBundle().objectForInfoDictionaryKey(String(kCFBundleVersionKey)) as? NSString {
                let mailComposeViewController = MFMailComposeViewController()
                mailComposeViewController.mailComposeDelegate = self
                mailComposeViewController.setSubject("Feedback on iOS client version v\(appVersion) (\(buildNumber))")
                mailComposeViewController.setToRecipients(["ios-feedback@mozilla.com"])

                let imageData = UIImagePNGRepresentation(image)
                mailComposeViewController.addAttachmentData(imageData, mimeType: "image/png", fileName: "feedback.png")
                window?.rootViewController?.presentViewController(mailComposeViewController, animated: true, completion: nil)
            }
        }
    }

    func mailComposeController(mailComposeViewController: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        mailComposeViewController.dismissViewControllerAnimated(true, completion: nil)
    }
}