/// Delegate for the callback return calls for the plugin
public protocol FirebaseMessagingCallbackProtocol {
    /// Returns a success text or an error.
    /// - Parameters:
    ///   - result: In case of value, the text to be returned.
    ///   - error: In case of value, the error to be returned
    func callback(result: String?, error: FirebaseMessagingErrors?)
}

/// Delegate for the event trigger. Should be called by the plugin.
public protocol FirebaseMessagingEventProtocol {
    /// Triggers an event with the data passed
    /// - Parameters:
    ///   - event: Event to be triggered
    ///   - data: Data to be processed
    func event(_ event: FirebaseEventType, data: String)
}

// MARK: - FirebaseMessagingCallbackProtocol Default Implementation
extension FirebaseMessagingCallbackProtocol {
    /// Triggers the callback when there's an error
    /// - Parameter error: Error to be thrown
    func callbackError(error: FirebaseMessagingErrors) {
        self.callback(result: nil, error: error)
    }
    
    /// Triggers the callback when there's a success text
    /// - Parameter result: Text to be returned
    func callback(result: String) {
        self.callback(result: result, error: nil)
    }
    
    /// Triggers the callback when there's a success without text
    func callbackSuccess() {
        self.callback(result: "", error: nil)
    }
}
