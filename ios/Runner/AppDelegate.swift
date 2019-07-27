import UIKit
import Flutter
import os

enum ChannelName {
    static let phoneEvent = "unpluggyourself.com/phone_event";
}

enum PhoneEventState {
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
        
        let channel = FlutterEventChannel(name: ChannelName.phoneEvent,
                                                         binaryMessenger: controller)
        channel.setStreamHandler(self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onDidReceiveNotification),
            name: nil,
            object: nil)

        sendPhoneEventState("stream initiated")
        return nil
    }
    
    @objc private func onDidReceiveNotification(_ notification: Notification) {
        switch (notification.name) {
        case UIApplication.protectedDataWillBecomeUnavailableNotification:
            sendPhoneEventState(PhoneEventState.locking);
        case UIApplication.protectedDataDidBecomeAvailableNotification:
            sendPhoneEventState(PhoneEventState.unlocked);
        default:
            break;
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
