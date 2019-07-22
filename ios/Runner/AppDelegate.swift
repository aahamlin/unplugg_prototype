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
            selector: #selector(onDidReceiveNotification),
            name: nil,
            object: nil)

        // Can I just hook 1 observer with a method to perform the selector?
        // other events of interest:
        // didEnterBackgroundNotification
        // willEnterForegroundNotification
        // willResignActiveNotification
        // willTerminateNotification
        sendPhoneEventState("stream initiated")
        return nil
    }
    
    let FlutterSemanticsUpdate = Notification.Name(rawValue: "FlutterSemanticsUpdate")
    
    @objc private func onDidReceiveNotification(_ notification: Notification) {
        switch (notification.name) {
        case UIApplication.protectedDataWillBecomeUnavailableNotification:
            sendPhoneEventState("locking");
        case UIApplication.protectedDataDidBecomeAvailableNotification:
            sendPhoneEventState("unlocked");
        case FlutterSemanticsUpdate:
            break;
        default:
            if (notification.name.rawValue.starts(with: "UIStatusBar") ||
                notification.name.rawValue.starts(with: "_UI") ||
                notification.name.rawValue.starts(with: "UIApplicationScene") ||
                notification.name.rawValue.starts(with: "UIDeviceOrientation") ||
                notification.name.rawValue.starts(with: "UIScreenBrightness")) {
                break;
            }
            sendPhoneEventState(notification.name.rawValue);
        }
    }
    private func sendPhoneEventState(_ state: String) {
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
        sendPhoneEventState("stream cancelled")
        NotificationCenter.default.removeObserver(self)
        eventSink = nil
        return nil
    }
}
