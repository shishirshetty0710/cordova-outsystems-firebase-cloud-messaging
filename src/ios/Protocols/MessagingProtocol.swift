/// Delegate to manage and trigger all methods required to reliable deliver all messages.
public protocol MessagingProtocol {
    /// Returns the main topic for the iOS app.
    /// - Returns: Main topic.
    func getGeneralTopic() -> String

    /// Returns the Firebase Cloud Messaging registration token. This token is obtained asynchronously.
    /// - Returns: Registration token.
    func getToken() async throws -> String

    /// Returns the APNS registration token. This token is obtained asynchronously.
    /// - Returns: Registration token.
    func getAPNSToken() async throws -> String

    /// Deletes the Firebase cloud Messaging registration token. The deletion is made asynchronously.
    func deleteToken() async throws

    /// Subscribes to a provided topic. The subscription is done asynchronously.
    /// - Parameter topic: Topic to subscribe to.
    func subscribe(toTopic topic: String) async throws

    /// Unsubscribes from the provided topic. The subscription is done asynchronously.
    /// - Parameter topic: Topic to unsubscribe from.
    func unsubscribe(fromTopic topic: String) async throws
}
