import UIKit
import Flutter
import os

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
  override init() {
    super.init()
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(self.onProtectedDataDidBecomeAvailable),
                                           name: UIApplication.protectedDataDidBecomeAvailableNotification,
                                           object: nil)
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(self.onProtectedDataWillBecomeUnavailable),
                                           name: UIApplication.protectedDataWillBecomeUnavailableNotification,
                                           object: nil)
  }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // register for trigger from app
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let testChannel = FlutterMethodChannel(name: "unpluggyourself.com/protected_data",
                                           binaryMessenger: controller)
    testChannel.setMethodCallHandler({
        [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
        guard call.method == "fireMessage" else {
            result(FlutterMethodNotImplemented)
            return
        }
        self?.fireMessage(result: result)
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    private func fireMessage(result: FlutterResult) {
        let notification = Notification(name: UIApplication.protectedDataDidBecomeAvailableNotification)
        self.onProtectedDataDidBecomeAvailable(notification: notification)
        result(String("fire"))
    }

  @objc func onProtectedDataDidBecomeAvailable(notification:Notification) {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let testChannel = FlutterMethodChannel(name: "unpluggyourself.com/protected_data",
                                           binaryMessenger: controller)
    testChannel.invokeMethod("message", arguments: "unlock")
  }

  @objc func onProtectedDataWillBecomeUnavailable(notification:Notification) {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let testChannel = FlutterMethodChannel(name: "unpluggyourself.com/protected_data",
                                           binaryMessenger: controller)
    testChannel.invokeMethod("message", arguments: "lock")
  }

}
