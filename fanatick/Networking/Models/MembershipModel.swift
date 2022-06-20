//
//  MembershipModel.swift
//  fanatick
//
//  Created by Essam on 1/9/20.
//  Copyright © 2020 Fanatick. All rights reserved.
//


import Foundation
import Alamofire
import Wires

class VerifyReceipt: NetworkRequest {
    convenience init(receiptModel: Receipt) {
        self.init(url: "\(NetworkConfiguration.share.endpoint.urlAddress)subscriptions/verify",
            method: .post,
            headers: NetworkConfiguration.defaultHeaders())
        model = receiptModel
    }
}

struct Membership: Mappable {
    var proSubscriptionActive: Bool?

    enum CodingKeys: String, CodingKey {
        case proSubscriptionActive = "pro_subscription_active"
    }
}

struct Receipt: Mappable {
    var receiptData: String?
    init(receiptData: Data) {
        self.receiptData = receiptData.base64EncodedString()
    }
    enum CodingKeys: String, CodingKey {
        case receiptData = "receipt_data"
    }
}
