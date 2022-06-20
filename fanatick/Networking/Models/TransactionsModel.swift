//
//  Transactions.swift
//  fanatick
//
//  Created by Yashesh on 27/06/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import Alamofire
import Wires

class CreateTransaction: NetworkRequest {
    convenience init(listing id: String, token: StripeToken) {
        let url = "\(NetworkConfiguration.share.endpoint.urlAddress)listings/\(id)/transactions"
        
        self.init(url: url,
                  method: .post,
                  headers: NetworkConfiguration.defaultHeaders())
        model = token
    }
}

class CreatePayment: NetworkRequest {
    convenience init(transaction id: String, token: StripeToken) {
        let url = "\(NetworkConfiguration.share.endpoint.urlAddress)transactions/\(id)/payment"

        self.init(url: url,
                  method: .post,
                  headers: NetworkConfiguration.defaultHeaders())
        model = token
    }
}

class TransactionGetRequest: NetworkRequest {
    convenience init(transaction id: String) {
        let url = "\(NetworkConfiguration.share.endpoint.urlAddress)transactions/\(id)"
        
        self.init(url: url,
                  method: .get,
                  headers: NetworkConfiguration.defaultHeaders())
    }
}

class TransactionVerification: NetworkRequest {
    convenience init(transaction id: String) {
        let url = "\(NetworkConfiguration.share.endpoint.urlAddress)transactions/\(id)/verification"
        
        self.init(url: url,
                  method: .post,
                  headers: NetworkConfiguration.defaultHeaders())
    }
}

class VerifyPayment: NetworkRequest {
    convenience init(transaction id: String, qrCode: QRCode) {
        let url = "\(NetworkConfiguration.share.endpoint.urlAddress)transactions/\(id)/verify"
        
        self.init(url: url,
                  method: .post,
                  headers: NetworkConfiguration.defaultHeaders())
        self.model = qrCode
    }
}

struct StripeToken: Mappable {
    var token: String?
    
    enum CodingKeys: String, CodingKey {
        case token
    }
}

struct Transaction: Mappable {
    var id: String?
    var userId: String?
    var payment: Payment?
    var fee: Int?
    var state: TransactionState?
    var rating: RatingParamsModel? = nil
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case payment
        case fee
        case state
        case rating
    }
}

struct Payment: Mappable {
    var id: String?
    var source: String?
    var amount: Int?
    var state: TransactionState?
    var chargeId: String?
    var updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case source
        case amount
        case state
        case chargeId = "charge_id"
        case updatedAt = "updated_at"
    }
}

struct QRCode: Mappable {
    var code: String?
    var transactionId: String?
    
    enum CodingKeys: String, CodingKey {
        case code
        case transactionId = "transaction_id"
    }
    
    func getString() -> String? {
        do {
            let data1 = try JSONSerialization.data(withJSONObject: serializeToDictionary(),
                                                   options: JSONSerialization.WritingOptions.prettyPrinted)
            return String(data: data1, encoding: String.Encoding.utf8)
        } catch _ {
            return nil
        }
    }
}

struct MyTransactions: Mappable {
    
    var id: String?
    var userId: String?
    var payment: Payment?
    var fee: Int?
    var state: TransactionState?
    var phoneSession: String?
    var event: Event?
    var ticket: Ticket?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case payment
        case fee
        case state
        case phoneSession = "phone_session"
        case event
        case ticket
    }
}
