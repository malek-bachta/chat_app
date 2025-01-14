// import Firebase

// @main
// @objc class AppDelegate: FlutterAppDelegate {
//     override func application(
//         _ application: UIApplication,
//         didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//     ) -> Bool {
//         #if DEBUG
//         let filePath = Bundle.main.path(forResource: "GoogleService-Info-dev", ofType: "plist")
//         #else
//         let filePath = Bundle.main.path(forResource: "GoogleService-Info-prod", ofType: "plist")
//         #endif

//         guard let filePath = filePath else {
//             fatalError("GoogleService-Info.plist file not found.")
//         }

//         guard let options = FirebaseOptions(contentsOfFile: filePath) else {
//             fatalError("Invalid Firebase configuration file.")
//         }

//         FirebaseApp.configure(options: options)

//         return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//     }
// }

import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.reg ister(with: self)
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}