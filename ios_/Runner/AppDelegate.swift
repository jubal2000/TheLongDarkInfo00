import UIKit
import Flutter
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure() // Add Line.
    GeneratedPluginRegistrant.register(withRegistry: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
