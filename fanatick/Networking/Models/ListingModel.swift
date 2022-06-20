//
//  ListingModel.swift
//  fanatick
//
//  Created by Vincent Ngo on 5/22/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Alamofire
import Foundation
import Wires

class GetMyListingsRequest: NetworkRequest {
    convenience init(before id: String?, active: Bool?, soldStatus: Bool?) {
        let url = "\(NetworkConfiguration.share.endpoint.urlAddress)me/listings"
        
        self.init(url: url,
                  method: .get,
                  headers: NetworkConfiguration.defaultHeaders())
        
        if id != nil {
            queryParameters["before"] = "\(id!)"
        }
        
        if active != nil {
            queryParameters["active"] = active! ? "true" : "false"
        }
        
        if soldStatus != nil {
            queryParameters["status"] = soldStatus! ? "sold" : "unsold"
        }
    }
}

class GetListingsRequest: NetworkRequest {
    convenience init(eventId: String?, before id: String?) {
        let url = "\(NetworkConfiguration.share.endpoint.urlAddress)listings"
        
        self.init(url: url,
                  method: .get,
                  headers: NetworkConfiguration.defaultHeaders())
        
        if id != nil {
            queryParameters["before"] = id!
//            url += "&before=\(id!)"
        }
        
        
        if eventId != nil {
            queryParameters["event_id"] = eventId
        }
    }
}

class GetListingRequest: NetworkRequest {
    convenience init(id: String) {
        let url = "\(NetworkConfiguration.share.endpoint.urlAddress)listings/\(id)"
        
        self.init(url: url,
                  method: .get,
                  headers: NetworkConfiguration.defaultHeaders())
    }
}

class PostListingRequest: NetworkRequest {
    convenience init(newListingModel: Listing?) {
        self.init(url: "\(NetworkConfiguration.share.endpoint.urlAddress)listings",
            method: .post,
            headers: NetworkConfiguration.defaultHeaders())
        model = newListingModel
    }
}

class DeleteListings: NetworkRequest {
    convenience init(id: String) {
        self.init(url: "\(NetworkConfiguration.share.endpoint.urlAddress)listings/\(id)",
            method: .delete,
            headers: NetworkConfiguration.defaultHeaders())
    }
}

enum DeliveryMethod: String, Mappable {
    case digital
    case hardcopy
    var value: String {
        switch self {
        case .digital: return LocalizedString("digital", story: .ticketinfo)
        case .hardcopy: return LocalizedString("Hardcopy_pick_up_before_the_event", story: .ticketinfo)
        }
    }
}

struct Listing: Mappable {
    var deliveryMethod: DeliveryMethod?
    var eventId: String?
    var event: Event?
    var id: String?
    var quickBuy: Bool?
    var seller: User?
    var tickets: [Ticket]?
    var unitPrice: Int? // Price in cent
    var sellerID: String?
    var section: String?
    var row: String?
    var seats: [String]?
    var quantity: Int? {
        set {
            qty = newValue
        }
        
        get {
            if qty == nil {
                return seats?.count
            } else {
                return qty
            }
        }
    }
    private var qty: Int? = nil
    var status: ListingStatus?
    var pickupLocation: String?
    var transaction: Transaction?
    
    init(deliveryMethod: DeliveryMethod?,
         eventId: String?,
         event: Event?,
         id: String?,
         quickBuy: Bool?,
         seller: User?,
         tickets: [Ticket]?,
         unitPrice: Int?, // Price in cent
        sellerID: String?,
        section: String?,
        row: String?,
        seats: [String]?,
        quantity: Int?, pickupLocation: String?) {
        self.deliveryMethod = deliveryMethod
        self.eventId = eventId
        self.event = event
        self.id = id
        self.quickBuy = quickBuy
        self.seller = seller
        self.tickets = tickets
        self.unitPrice = unitPrice
        self.sellerID = sellerID
        self.section = section
        self.row = row
        self.seats = seats
        self.quantity = qty
        self.pickupLocation = pickupLocation
    }
    
    enum CodingKeys: String, CodingKey{
        case deliveryMethod = "delivery_method"
        case eventId = "event_id"
        case event
        case id
        case quickBuy = "quick_buy"
        case seller
        case unitPrice = "unit_price"
        case sellerID = "seller_id"
        case section
        case row
        case seats
        case tickets = "ticket"
        case qty
        case status
        case pickupLocation = "pickup_location"
        case transaction
    }
}

struct Ticket: Mappable {
    var id: String?
    var image: TicketImage?
    var listingId: String?
    var seat: String?
    var ticketUpload: TicketImage?
    
    enum CodingKeys: String, CodingKey {
        case id
        case image
        case listingId = "listing_id"
        case seat
        case ticketUpload = "ticket_upload"
    }
}

struct TicketImage: Mappable, AWSImage {
    var key: String?
    var bucket: String?
}

struct DeletedList: Mappable {
    var code: String?
    
    enum CodingKeys: String, CodingKey {
        case code
    }
}
