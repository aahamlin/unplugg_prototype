import UIKit
import Flutter
import os

enum ChannelName {
    static let dataProtection = "unpluggyourself.com/dp";
}

enum DataProtectionState {
    static let locking = "locking"
    static let unlocked = "unlocked"
}


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, FlutterStreamHandler {
    
    private var eventSink : FlutterEventSink?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
        ) -> Bool {
        
        GeneratedPluginRegistrant.register(with: self)
        
        guard let controller = window?.rootViewController as? FlutterViewController else {
            fatalError("rootViewController is not type FlutterViewController")
        }
        
        let dataProtectionChannel = FlutterEventChannel(name: ChannelName.dataProtection,
                                                         binaryMessenger: controller)
        dataProtectionChannel.setStreamHandler(self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(AppDelegate.onProtectedDataWillBecomeUnavailable),
            name: UIApplication.protectedDataWillBecomeUnavailableNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(AppDelegate.onProtectedDataDidBecomeAvailable),
            name: UIApplication.protectedDataDidBecomeAvailableNotification,
            object: nil)

        return nil
    }
    
    @objc private func onProtectedDataWillBecomeUnavailable(notification: Notification) {
        let state = DataProtectionState.locking
        sendDataProtectionState(state)
    }
    
    @objc private func onProtectedDataDidBecomeAvailable(notification: Notification) {
        let state = DataProtectionState.unlocked
        sendDataProtectionState(state)
    }
    
    private func sendDataProtectionState(_ state: String) {
        guard let eventSink = eventSink else {
            if #available(iOS 10.0, *) {
                os_log("eventSink not initialized")
            } else {
                print("eventSink not initialized")
            }
            return
        }
        if #available(iOS 10.0, *) {
            os_log("sending %s", state)
        } else {
            print("sending %s", state)
        }
        eventSink(state)
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        NotificationCenter.default.removeObserver(self)
        eventSink = nil
        return nil
    }
}
