//
//  AuthenticationError.swift
//  iBench
//
//  Created by Андрей Журавлев on 13.11.2020.
//  Copyright © 2020 Андрей Журавлев. All rights reserved.
//

import Foundation

enum AuthError {
    case notFilled, invalidEmail, notMatchingPasswords, serverError, unknownError
}

extension AuthError: LocalizedError {
    var errorDescription: String? {
        switch self {
            case .notFilled:
                return NSLocalizedString("Fill all fields", comment: "")
            case .invalidEmail:
                return NSLocalizedString("Invalid Email format", comment: "Check your email spelling")
            case .notMatchingPasswords:
                return NSLocalizedString("Passwords do not match", comment: "Check your passwords again")
            case .serverError:
                return NSLocalizedString("Server error", comment: "")
            case .unknownError:
                return NSLocalizedString("Unknown error", comment: "")
        }
    }
}
