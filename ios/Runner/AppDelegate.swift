import UIKit

import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions:
     [UIApplication.LaunchOptionsKey: Any]?
    import GoogleMaps
    GMSServices.provideAPIKey("YOUR_API_KEY_HERE")

  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
