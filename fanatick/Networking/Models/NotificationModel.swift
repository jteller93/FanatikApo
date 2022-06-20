//
//  NotificationModel.swift
//  fanatick
//
//  Created by Yashesh on 05/08/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import Alamofire
import Wires

class GetNotificaitons: NetworkRequest {
    
    convenience init() {
        let url = "\(NetworkConfiguration.share.endpoint.urlAddress)me/notifications"
        
        self.init(url: url,
                  method: .get,
                  headers: NetworkConfiguration.defaultHeaders())
    }
}


struct Notifications: Mappable {
    
//    var id: String?
//    var userId: String?
//    var title: String?
    var description: String?
//    var isMarkedRead: String?
    var createdAt: String?
//    var updatedAt: String?
//    var deviceToken: String?
    
    enum CodingKeys: String, CodingKey {
//        case id
//        case userId = "user_id"
//        case title
        case description
//        case isMarkedRead = "is_marked_read"
        case createdAt = "created_at"
//        case updatedAt = "updated_at"
//        case deviceToken = "DeviceTokenx"
    }
}
