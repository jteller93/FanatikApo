//
//  EventModel.swift
//  fanatick
//
//  Created by Vincent Ngo on 5/6/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import Alamofire
import Wires

class GetEventsRequest: NetworkRequest {
    convenience init(before id: String? = nil) {
        var url = "\(NetworkConfiguration.share.endpoint.urlAddress)events"
        if id != nil {
            url += "?before=\(id!)"
        }
        self.init(url: url,
            method: .get,
            headers: NetworkConfiguration.defaultHeaders())
    }
}

class GetEventRequest: NetworkRequest {
    convenience init(eventId id: String) {
        let url = "\(NetworkConfiguration.share.endpoint.urlAddress)events/\(id)"
        self.init(url: url,
                  method: .get,
                  headers: NetworkConfiguration.defaultHeaders())
    }
}

struct Event: Mappable {
    var id: String?
    var image: EventImage?
    var location: Location?
    var name: String?
    var startAt: String?
    var venue: Venue?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case image = "image"
        case location = "location"
        case name = "name"
        case startAt = "start_at"
        case venue = "venue"
    }
}

struct EventImage: Mappable, AWSImage {
    var bucket: String?
    var key: String?
    var url: String?
}

struct Venue: Mappable {
    var id: String?
    var name: String?
    var seatingMap: VenueSeatingMap?
    var location: Location?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case seatingMap = "seating_map"
        case location
    }
}

struct VenueSeatingMap: Mappable, AWSImage {
    var bucket: String?
    var key: String?
}

struct Location: Mappable {
    var address1: String?
    var address2: String?
    var city: String?
    var country: String?
    var id: String?
    var latitude: Double?
    var longitude: Double?
    var state: String?
    var zipCode: String?
    
    enum CodingKeys: String, CodingKey {
        case address1 = "address_1"
        case address2 = "address_2"
        case city = "city"
        case country = "country"
        case id = "id"
        case latitude = "latitude"
        case longitude = "longitude"
        case state = "state"
        case zipCode = "zip_code"
    }
    
    var cityAndState: String {
           get {
               var location = ""
               if let city = city {
                   location = city
               }
               if let state = state {
                   if location.isEmpty {
                       location = state
                   } else {
                       location = location + ", " + state
                   }
               }
               return location
           }
       }
}

// MARK: Extension
extension Array where Element == Event {
    func takeFuture() -> [Element] {
        return filter({ (event) -> Bool in
            if let startAt = event.startAt, let date = Date(fromString: startAt, format: DateFormatType.isoDateTimeMilliSec), date.compare(.isInTheFuture), !date.compare(.isToday) {
                return true
            }
            return false
        })
    }
    
    func takeToday() -> [Element] {
        return filter({ (event) -> Bool in
            if let startAt = event.startAt, let date = Date(fromString: startAt, format: DateFormatType.isoDateTimeMilliSec), date.compare(.isToday) {
                return true
            }
            return false
        })
    }
}
