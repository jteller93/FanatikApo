//
//  LocationUpdateModel.swift
//  fanatick
//
//  Created by Yashesh on 04/07/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import Alamofire
import Wires

class UpdateLocation: NetworkRequest {
    convenience init(location: UserLocation) {
        let url = "\(NetworkConfiguration.share.endpoint.urlAddress)me/location"
        
        self.init(url: url,
                  method: .post,
                  headers: NetworkConfiguration.defaultHeaders())
        self.model = location
    }
}

class GetSellerLocation: NetworkRequest {
    convenience init(user id: String) {
        let url = "\(NetworkConfiguration.share.endpoint.urlAddress)listings/\(id)/seller/location"
        
        self.init(url: url,
                  method: .get,
                  headers: NetworkConfiguration.defaultHeaders())
    }
}

class GetPhoneNumber: NetworkRequest {
    convenience init(transaction id: String) {
        let url = "\(NetworkConfiguration.share.endpoint.urlAddress)transactions/\(id)/phone-sessions"
        self.init(url: url,
                  method: .post,
                  headers: NetworkConfiguration.defaultHeaders())
    }
}


struct UserLocation: Mappable {
    var latitude: Double?
    var longitude: Double?
    
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }
}

struct SellerPhoneNumber: Mappable {
    var id: String?
    var state: String?
    var number: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case state
        case number
    }
}
