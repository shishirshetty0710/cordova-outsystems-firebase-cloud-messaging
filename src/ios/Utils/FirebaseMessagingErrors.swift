/// Object that contain all specific errors that can be thrown by the app.
public enum FirebaseMessagingErrors: Int, CustomNSError, LocalizedError {
    
    case registrationError = 1
    case registrationPermissionsError = 2
    case unregistrationError = 3
    case unregistrationDeleteTokenError = 4
    case subscriptionError = 5
    case unsubscriptionError = 6
    case obtainingTokenError = 7
    case deletingTokenError = 8
    case settingBadgeNumberError = 9
    case notificationsPermissionsDeniedError = 12
    case sendNotificationsError = 14
    case deleteNotificationsError = 15
    case obtainSilentNotificationsError = 16
    // MARK: - errors not returned to bridge
    case requestPermissionsError
    
    /// The text associated to the error.
    public var description: String {
        switch self {
        case .registrationError:
            return "Couldn't register your device."
        case .registrationPermissionsError:
            return "Couldn't register your device due to lack of permissions."
        case .unregistrationError:
            return "Couldn't unregister your device."
        case .unregistrationDeleteTokenError:
            return "Couldn't unregister your device due to an error while deleting the token."
        case .subscriptionError:
            return "Couldn't subscribe to topic."
        case .unsubscriptionError:
            return "Couldn't unsubscribe to topic."
        case .obtainingTokenError:
            return "Couldn't obtain token."
        case .deletingTokenError:
            return "Couldn't delete token."
        case .settingBadgeNumberError:
            return "Couldn't set badge number."
        case .notificationsPermissionsDeniedError:
            return "Permission to receive notifications was denied."
        case .sendNotificationsError:
            return "Couldn't send notification."
        case .deleteNotificationsError:
            return "Couldn't delete notification."
        case .obtainSilentNotificationsError:
            return "Couldn't fetch silent notifications."
            
        case .requestPermissionsError:
            return "There was an error requesting permissions to send notifications."
        }
    }
    
    /// The text associated to the error., with a fallback in case of empty text
    public var errorDescription: String? {
        return description.isEmpty ? NSLocalizedString(String(rawValue), comment: "") : description
    }

}
