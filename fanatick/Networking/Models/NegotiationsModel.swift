//
//  NegotiationsModel.swift
//  fanatick
//
//  Created by Yashesh on 19/06/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import Alamofire
import Wires

class GetListingNegotiationRequest: NetworkRequest {
    convenience init(listing id: String?) {
        let url = "\(NetworkConfiguration.share.endpoint.urlAddress)me/negotiations"
        
        self.init(url: url,
                  method: .get,
                  headers: NetworkConfiguration.defaultHeaders())
        
        if id != nil {
            queryParameters["listing_id"] = "\(id!)"
        }
    }
}

class UpdateTicketPriceRequest: NetworkRequest {
    convenience init(listing id: String, ticketPriceModel: UpdateTicketListing) {
        let url = "\(NetworkConfiguration.share.endpoint.urlAddress)listings/\(id)"
        
        self.init(url: url,
                  method: .patch,
                  headers: NetworkConfiguration.defaultHeaders())
        
        model = ticketPriceModel
    }
}

class GetNegotiationsEvents: NetworkRequest {
    convenience init(negotiation id: String) {
        let url = "\(NetworkConfiguration.share.endpoint.urlAddress)negotiations/\(id)/events"
        
        self.init(url: url,
                  method: .get,
                  headers: NetworkConfiguration.defaultHeaders())
    }
}

class NegotiationAction: NetworkRequest {
    convenience init(negotiation id: String, accept: Bool) {
        let url = "\(NetworkConfiguration.share.endpoint.urlAddress)negotiations/\(id)/\(accept ? "accept" : "decline")"
        
        self.init(url: url,
                  method: .post,
                  headers: NetworkConfiguration.defaultHeaders())
    }
}

class GetNegotiation: NetworkRequest {
    convenience init(negotiation id: String) {
        let url = "\(NetworkConfiguration.share.endpoint.urlAddress)negotiations/\(id)"
        
        self.init(url: url,
                  method: .get,
                  headers: NetworkConfiguration.defaultHeaders())
    }
}

class NegotiationAskingPrice: NetworkRequest {
    convenience init(negotiation id: String, priceModel: NegotiationPrice) {
        let url = "\(NetworkConfiguration.share.endpoint.urlAddress)negotiations/\(id)"
        
        self.init(url: url,
                  method: .patch,
                  headers: NetworkConfiguration.defaultHeaders())
        self.model = priceModel
    }
}

class CreateNegotiation: NetworkRequest {
    convenience init(negotiation: StartNegotiation) {
        let url = "\(NetworkConfiguration.share.endpoint.urlAddress)negotiations"
        
        self.init(url: url,
                  method: .post,
                  headers: NetworkConfiguration.defaultHeaders())
        self.model = negotiation
    }
}

class CancelNegotiation: NetworkRequest {
    convenience init(negotiation id: String) {
        let url = "\(NetworkConfiguration.share.endpoint.urlAddress)negotiations/\(id)/cancel"
        
        self.init(url: url,
                  method: .put,
                  headers: NetworkConfiguration.defaultHeaders())
    }
}

struct Negotiations: Mappable {
    var id: String?
    var userId: String?
    var listingId: String?
    var offerPrice: Int?
    var askingPrice: Int?
    var status: NegotiationStatus?
    var listing: Listing?
    var event: Event?
    var buyer: User?
    var negotiatonStatus: ListingStatus?
    var transaction: Transaction?
    var finalPrice: Int?
    var updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case listingId = "listing_id"
        case offerPrice = "offer_price"
        case askingPrice = "asking_price"
        case status
        case listing
        case event
        case buyer
        case transaction
        case finalPrice = "final_price"
        case updatedAt = "updated_at"
    }
}

struct UpdateTicketListing: Mappable {
    
    var quickBuy: Bool?
    var status: String?
    var unitPrice: Int?
    
    enum CodingKeys: String, CodingKey {
        case quickBuy = "quick_buy"
        case status
        case unitPrice = "unit_price"
    }
}

enum ListingStatus: String, Codable {
    case sold
    case unsold
    case exception = ""
}

struct NegotiationsEvents: Mappable {
    
    var id: String?
    var negotiationId: String?
    var type: EventType? = .exception
    var amount: Int?
    var userID: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case negotiationId = "negotiation_id"
        case type
        case amount
        case userID = "user_id"
    }
}

enum EventType: String, Codable {
    case ask
    case offer
    case decline
    case accept
    case exception = ""
}

struct NegotiationPrice: Mappable {
    var price: Int?
    
    enum CodingKeys: String, CodingKey {
        case price
    }
}

enum NegotiationStatus: String, Codable {
    case active
    case declined
    case accepted
}

enum TransactionState: String, Codable {
    case pending
    case failed
    case canceled
    case succeeded
    case charged
    case exception = ""
    case pickupPending = "pending_capture"
    case expired
    case scanSuccess
}

struct StartNegotiation: Mappable {
    
    var listingId: String?
    var offerPrice: Int?
    var userId: String?
        
    enum CodingKeys: String, CodingKey {
        case listingId = "listing_id"
        case offerPrice = "offer_price"
        case userId = "user_id"
    }
}
