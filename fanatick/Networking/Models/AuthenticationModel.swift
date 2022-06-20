//
//  AuthenticationModel.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/29/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import Alamofire
import Wires

class AuthenticationRequest: NetworkRequest {
    convenience init(tokenId: String, deviceToken: String, phoneNumber: String) {
        self.init(url: "\(NetworkConfiguration.share.endpoint.urlAddress)authentications",
            method: .post)
        self.model = AuthenticationRequestModel(tokenId: tokenId,
                                                deviceToken: deviceToken,
                                                hwid: UIDevice.current.identifierForVendor!.uuidString,
                                                phoneNumber: phoneNumber)
    }
}

class FirebaseReauthenticationRequest: NetworkRequest {
    convenience init() {
        self.init(url: "\(NetworkConfiguration.share.endpoint.urlAddress)me/firebase/token", method: .post)
    }
}

struct AuthenticationResponse: Mappable {
    var token: String?
}

struct AuthenticationRequestModel: Mappable {
    var tokenId: String
    var deviceToken: String
    var hwid: String
    var phoneNumber: String
    
    enum CodingKeys: String, CodingKey {
        case tokenId = "token_id"
        case deviceToken = "device_token"
        case hwid
        case phoneNumber = "phone_number"
    }
}
