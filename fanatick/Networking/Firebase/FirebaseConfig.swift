//
//  FirebaseConfig.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/10/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import Firebase

class FirebaseConfig {
    private init() {}
    
    static func configure() {
        FirebaseApp.configure()
    }
    
    static func didRegisterWithDeviceToken(deviceToken: Data) {
        Auth.auth().setAPNSToken(deviceToken, type: .unknown)
    }
    
    static func canHandleNotification(notification: [AnyHashable: Any]) -> Bool {
        return Auth.auth().canHandleNotification(notification)
    }
    
    static func canHandle(url: URL) -> Bool {
        return Auth.auth().canHandle(url)
    }
}
