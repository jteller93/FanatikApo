//
//  NetworkConfiguration.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/8/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import Wires

#if DEBUG
#elseif STAGING
var baseUrl = "https://stage.app.fanatickapp.com/api/v1/"
#else
var baseUrl = "https://app.fanatickapp.com/api/v1/"
#endif

class NetworkConfiguration: Wires.NetworkConfiguration {
    static let share = NetworkConfiguration()
    
    func setup() {
        #if DEBUG
        NetworkActivityLogger.shared.startLogging()
        NetworkActivityLogger.shared.level = .debug
        #elseif STAGING
        NetworkActivityLogger.shared.startLogging()
        NetworkActivityLogger.shared.level = .debug
        #endif
        
        NetworkManager.networkErrorHandler = ResponseHandler()
        
        endpoint = Endpoint(name: "Fanatick", urlAddress: baseUrl)
    }
    
    class func defaultHeaders() -> [String: String] {
        if let token = FirebaseSession.shared.fanatickAuthToken {
            return ["Authorization" : token]
        } else {
            return [:]
        }
    }
    
//    class func defaultHeaders() -> [String: String] {
//        if let token = FirebaseSession.shared.fanatickAuthToken {
//            return ["Authorization" : "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiQ1BEWjlOcGpobllKTW8yWjlDV004NG1wR21BMiIsInBob25lX251bWJlciI6IiIsImV4cCI6MTU5MTY4NjA1NiwiaXNzIjoiZmFuYXRpY2sifQ.-4PzFTuPIBIy-pV350sSvaW2eXih0stQ5kjsg0TXb_c"]
//        } else {
//            return [:]
//        }
//    }
}
