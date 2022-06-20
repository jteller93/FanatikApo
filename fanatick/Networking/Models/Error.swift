//
//  Error.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/12/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import Wires
import Alamofire

enum RuntimeError {
    case `internal`
    case sessionExpired
    case invalidPhone
    case network
    case unknown
    case runtime(String)
}

extension RuntimeError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .sessionExpired:
            return LocalizedString("error_session_expired", story: .error)
        case .invalidPhone:
            return LocalizedString("error_invalid_phone", story: .error)
        case .internal:
            return LocalizedString("error_internal", story: .error)
        case .network:
            return LocalizedString("error_network", story: .error)
        case .unknown:
            return LocalizedString("error_unknown", story: .error)
        case .runtime(let message):
            return message
        }
    }
}

extension RuntimeError: Equatable {}
    
func == (lhs: Error, rhs: RuntimeError) -> Bool {
    return lhs.localizedDescription == rhs.localizedDescription
}

extension Error {
    var runtimeError: RuntimeError {
        if let error = self as? RuntimeError {
            return error
        } else if let firebaseError = toAuthErrorCode()?.runtimeError {
            return firebaseError
        } else if let error = self as? NetworkError {
            return RuntimeError.runtime(error.networkingError?.localizedDescription ?? "")
        } else {
            return RuntimeError.runtime(localizedDescription)
        }
    }
}

struct ErrorModel: Mappable, LocalizedError {
    var code: String?
    var message: String?
    
    var errorDescription: String? {
        get {
            return message
        }
    }
}
