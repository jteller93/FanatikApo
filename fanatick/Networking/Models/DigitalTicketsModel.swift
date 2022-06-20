//
//  DigitalTicketsViewModel.swift
//  fanatick
//
//  Created by Yashesh on 01/07/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import Alamofire
import Wires


class GetDigitalTickets: NetworkRequest {
    convenience init(listing id: String) {
        let url = "\(NetworkConfiguration.share.endpoint.urlAddress)listings/\(id)/tickets"
        
        self.init(url: url,
                  method: .get,
                  headers: NetworkConfiguration.defaultHeaders())
    }
}

struct DigitalTicket: Mappable {
    var id: String?
    var ticket: UploadedTicket?
    var seat: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case ticket = "ticket_upload"
        case seat
    }
}

struct UploadedTicket: Mappable, AWSImage {
    var id: String?
    var bucket: String?
    var key: String?
}
