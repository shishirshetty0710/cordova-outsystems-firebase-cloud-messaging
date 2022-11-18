@_implementationOnly import FirebaseCore
@_implementationOnly import FirebaseMessaging

/// Class that manages and triggers all methods required to reliable deliver all messages.
public class MessagingManager: MessagingProtocol {
    /// Main topic suffix for the iOS app.
    static let generalTopic = "-general-topic-ios"

    /// Empy construct method. It's required to publicly expose the class.
    public init() {
        // needed init to expose the class
    }

    /// Returns the main topic for the iOS app.
    /// - Returns: Main topic.
    public func getGeneralTopic() -> String {
        return "\(FirebaseApp.app()?.options.gcmSenderID ?? "")\(Self.generalTopic)"
    }

    /// Returns the Firebase Cloud Messaging registration token. This token is obtained asynchronously.
    /// - Returns: Registration token.
    public func getToken() async throws -> String {
        return try await Messaging.messaging().token()
    }
    public func getAPNSToken() async throws -> String {
        let deviceToken: Data?  = try await Messaging.messaging().apnsToken
        ///let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        let tokenString = String(decoding: deviceToken, as: UTF8.self)
        return tokenString
    }

    /// Deletes the Firebase cloud Messaging registration token. The deletion is made asynchronously.
    public func deleteToken() async throws {
        try await Messaging.messaging().deleteToken()
    }

    /// Subscribes to a provided topic. The subscription is done asynchronously.
    /// - Parameter topic: Topic to subscribe to.
    public func subscribe(toTopic topic: String) async throws {
        try await Messaging.messaging().subscribe(toTopic: topic)
    }

    /// Unsubscribes from the provided topic. The subscription is done asynchronously.
    /// - Parameter topic: Topic to unsubscribe from.
    public func unsubscribe(fromTopic topic: String) async throws {
        try await Messaging.messaging().unsubscribe(fromTopic: topic)
    }

}
