//
//  FirebaseError.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/12/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth

extension Error {
    func toAuthErrorCode()-> AuthErrorCode? {
        return  17000...18000 ~= _code ? AuthErrorCode(rawValue: _code) : nil
    }
}

extension AuthErrorCode {
    var runtimeError: RuntimeError {
        switch self {
        case .invalidCredential, .missingVerificationCode, .invalidVerificationCode:
            return RuntimeError.runtime(LocalizedString("error_invalid_credential", story: .error))
        case .userDisabled:
            return RuntimeError.runtime(LocalizedString("error_user_disabled", story: .error))
        case .tooManyRequests:
            return RuntimeError.runtime(LocalizedString("error_too_many_request", story: .error))
        case .userTokenExpired, .invalidUserToken:
            return RuntimeError.sessionExpired
        case .invalidPhoneNumber:
            return RuntimeError.invalidPhone
        case .internalError:
            return RuntimeError.internal
        case .networkError:
            return RuntimeError.network
        default:
            return RuntimeError.unknown
        }
    }
}
