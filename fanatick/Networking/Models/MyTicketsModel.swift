//
//  MyTicketsModel.swift
//  fanatick
//
//  Created by Yashesh on 23/07/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import Alamofire
import Wires

class GetTransactions: NetworkRequest {
    
    convenience init(userType: String?) {
        let url = "\(NetworkConfiguration.share.endpoint.urlAddress)me/transactions"
        
        self.init(url: url,
                  method: .get,
                  headers: NetworkConfiguration.defaultHeaders())
        if userType != nil {
            queryParameters["user_type"] = userType ?? ""
        }
        //        queryParameters["state"] = TransactionState.succeeded.rawValue
        //        queryParameters["state"] = "pending_capture"
    }
}

class GetNegotiations: NetworkRequest {
    
    convenience init(userType: String?) {
        let url = "\(NetworkConfiguration.share.endpoint.urlAddress)listings/negotiations/open"
        
        self.init(url: url,
                  method: .get,
                  headers: NetworkConfiguration.defaultHeaders())
        if userType != nil {
            queryParameters["user_type"] = userType ?? ""
        }
    }
}

struct UserTransaction: Mappable {
    var id: String?
    var userId: String?
    var payment: Payment?
    var fee: Int?
    var state: TransactionState?
    var phoneSession: String?
    var listing: Listing?
    var buyer: User?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case payment
        case fee
        case state
        case phoneSession = "phone_session"
        case listing
        case buyer
    }
}

struct OpenNegotiations: Mappable {
    var id: String?
    var seller: User?
    var eventId: String?
    var event: Event?
    var section: String?
    var row: String?
    var seats: [String]?
    var status: ListingStatus?
    var unitPrice: Int?
    var deliveryMethod: DeliveryMethod?
    var quickBuy: Bool?
    var pickupLocation: String?
    var negotiations: [Negotiations]?
    var isExpanded: Bool = false
    var transaction: Transaction?
    
    enum CodingKeys: String, CodingKey {
        case id
        case seller
        case eventId = "event_id"
        case event
        case section
        case row
        case seats
        case status
        case unitPrice = "unit_price"
        case deliveryMethod = "delivery_method"
        case quickBuy = "quick_buy"
        case pickupLocation = "pickup_location"
        case negotiations
        case transaction
    }
}
