import Foundation
import OSCommonPluginLib

@objc(OSFirebaseCloudMessaging)
class OSFirebaseCloudMessaging: CDVPlugin {

    var plugin: FirebaseMessagingController?
    var callbackId: String = ""

    var deviceReady: Bool = false
    var eventQueue: [String]?

    override func pluginInitialize() {
        plugin = FirebaseMessagingController(delegate:self)
        FirebaseMessagingApplicationDelegate.shared.eventDelegate = self
    }

    @objc(ready:)
    func ready(command: CDVInvokedUrlCommand) {
        self.callbackId = command.callbackId
        self.deviceReady = true

        if let eventQueue = self.eventQueue {
            self.commandDelegate.run { [weak self] in
                guard let self = self else { return }

                for js in eventQueue {
                    self.commandDelegate.evalJs(js)
                }
                self.eventQueue = nil
            }
        }
    }

    @objc(registerDevice:)
    func registerDevice(command: CDVInvokedUrlCommand) {
        self.callbackId = command.callbackId
        Task {
            await self.plugin?.registerDevice()
        }
    }

    @objc(getPendingNotifications:)
    func getPendingNotifications(command: CDVInvokedUrlCommand) {
        self.callbackId = command.callbackId

        guard let clearFromDatabase = command.arguments[0] as? Bool else {
            self.sendResult(result: "", error:FirebaseMessagingErrors.obtainSilentNotificationsError as NSError, callBackID: self.callbackId)
            return
        }

        self.plugin?.getPendingNotifications(clearFromDatabase: clearFromDatabase)
    }

    @objc(unregisterDevice:)
    func unregisterDevice(command: CDVInvokedUrlCommand) {
        self.callbackId = command.callbackId
        Task {
            await self.plugin?.unregisterDevice()
        }
    }

    @objc(getToken:)
    func getToken(command: CDVInvokedUrlCommand) {
        self.callbackId = command.callbackId
        Task {
            await self.plugin?.getToken()
        }
    }

    @objc(getAPNSToken:)
    func getAPNSToken(command: CDVInvokedUrlCommand) {
        self.callbackId = command.callbackId
        Task {
            await self.plugin?.getAPNSToken()
        }
    }

    @objc(clearNotifications:)
    func clearNotifications(command: CDVInvokedUrlCommand) {
        self.callbackId = command.callbackId
        self.plugin?.clearNotifications()
    }

    @objc(sendLocalNotification:)
    func sendLocalNotification(command: CDVInvokedUrlCommand) {
        self.callbackId = command.callbackId
        guard
            let badge = command.arguments[0] as? Int,
            let body = command.arguments[1] as? String,
            let title = command.arguments[2] as? String
        else {
            self.sendResult(result: "", error:FirebaseMessagingErrors.sendNotificationsError as NSError, callBackID: self.callbackId)
            return
        }

        Task {
            await self.plugin?.sendLocalNotification(title: title, body: body, badge: badge)
        }
    }

    @objc(getBadge:)
    func getBadge(command: CDVInvokedUrlCommand) {
        self.callbackId = command.callbackId
        self.plugin?.getBadge()
    }

    @objc(setBadge:)
    func setBadge(command: CDVInvokedUrlCommand) {
        self.callbackId = command.callbackId

        guard
            let badge = command.arguments[0] as? Int
        else {
            self.sendResult(result: "", error:FirebaseMessagingErrors.settingBadgeNumberError as NSError, callBackID: self.callbackId)
            return
        }

        self.plugin?.setBadge(badge:badge)
    }

    @objc(subscribe:)
    func subscribe(command: CDVInvokedUrlCommand) {
        self.callbackId = command.callbackId

        guard
            let topic = command.arguments[0] as? String
        else {
            self.sendResult(result: "", error:FirebaseMessagingErrors.subscriptionError as NSError, callBackID: self.callbackId)
            return
        }

        Task {
            do {
                try await self.plugin?.subscribe(topic)
            } catch {
                self.sendResult(result: "", error:FirebaseMessagingErrors.subscriptionError as NSError, callBackID: self.callbackId)
            }
        }
    }

    @objc(unsubscribe:)
    func unsubscribe(command: CDVInvokedUrlCommand) {
        self.callbackId = command.callbackId

        guard
            let topic = command.arguments[0] as? String
        else {
            self.sendResult(result: "", error:FirebaseMessagingErrors.unsubscriptionError as NSError, callBackID: self.callbackId)
            return
        }

        Task {
            do {
                try await self.plugin?.unsubscribe(fromTopic: topic)
            } catch {
                self.sendResult(result: "", error:FirebaseMessagingErrors.unsubscriptionError as NSError, callBackID: self.callbackId)
            }
        }
    }

}

// MARK: - OSCommonPluginLib's PlatformProtocol Methods
extension OSFirebaseCloudMessaging: PlatformProtocol {
    func sendResult(result: String?, error: NSError?, callBackID: String) {
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)

        if let error = error, !error.localizedDescription.isEmpty {
            let errorCode = "OS-PLUG-FCMS-\(String(format: "%04d", error.code))"
            let errorMessage = error.localizedDescription
            let errorDict = ["code": errorCode, "message": errorMessage]
            pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: errorDict);
        } else if let result = result {
            pluginResult = result.isEmpty ? CDVPluginResult(status: CDVCommandStatus_OK) : CDVPluginResult(status: CDVCommandStatus_OK, messageAs: result)
        }

        self.commandDelegate.send(pluginResult, callbackId: callBackID);
    }

    func trigger(event: String, data: String) {
        let js = "cordova.plugins.OSFirebaseCloudMessaging.fireEvent('\(event)', \(data))"

        if self.deviceReady {
            self.commandDelegate.evalJs(js)
        } else if self.eventQueue != nil {
            self.eventQueue?.append(js)
        } else {
            self.eventQueue = [js]
        }
    }
}

// MARK: - OSFirebaseMessagingLib's FirebaseMessagingCallbackProtocol Methods
extension OSFirebaseCloudMessaging: FirebaseMessagingCallbackProtocol {
    func callback(result: String?, error: FirebaseMessagingErrors?) {
        if let error = error {
            self.sendResult(result: nil, error: error as NSError, callBackID: self.callbackId)
        } else {
            if let result = result {
                self.sendResult(result: result, error: nil, callBackID: self.callbackId)
            }
        }
    }
}

// MARK: - OSFirebaseMessagingLib's FirebaseMessagingEventProtocol Methods
extension OSFirebaseCloudMessaging: FirebaseMessagingEventProtocol {
    func event(_ event: FirebaseEventType, data: String) {
        var eventName = "notificationClick"
        if case let .trigger(notification) = event {
            eventName = notification == .silentNotification ? "silentNotification" : "defaultNotification"
        }

        self.trigger(event: eventName, data: data)
    }
}
