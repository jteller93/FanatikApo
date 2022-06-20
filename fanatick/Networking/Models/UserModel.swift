//
//  UserModel.swift
//  fanatick
//
//  Created by Vincent Ngo on 5/1/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import Alamofire
import Wires

class GetUserRequest: NetworkRequest {
    convenience init() {
        self.init(url: "\(NetworkConfiguration.share.endpoint.urlAddress)me/profile",
            method: .get,
            headers: NetworkConfiguration.defaultHeaders())
    }
}

class CreateUserRequest: NetworkRequest {
    convenience init(createUserModel: UserUpdateModel) {
        self.init(url: "\(NetworkConfiguration.share.endpoint.urlAddress)me/profile",
            method: .post,
            headers: NetworkConfiguration.defaultHeaders())
        model = createUserModel
    }
}

class EditUserRequest: NetworkRequest {
    convenience init(createUserModel: UserUpdateModel) {
        self.init(url: "\(NetworkConfiguration.share.endpoint.urlAddress)me/profile",
            method: .patch,
            headers: NetworkConfiguration.defaultHeaders())
        model = createUserModel
    }
}

class GetUsersDetails: NetworkRequest {
    convenience init(user id: String) {
        self.init(url: "\(NetworkConfiguration.share.endpoint.urlAddress)users/\(id)/profile",
            method: .get,
            headers: NetworkConfiguration.defaultHeaders())
    }
}

struct User: Mappable {
    var stripeID: String?
    var firstName: String?
    var lastName: String?
    var id: String?
    var userId: String?
    var image: UserImage?
    var membership: Membership?
    var locationActive: Bool?
    var ratings: String?

    enum CodingKeys: String, CodingKey {
        case stripeID = "stripe_user_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case id = "id"
        case userId = "user_id"
        case image = "image"
        case membership = "user"
        case locationActive = "location_active"
        case ratings
    }
}

struct UserUpdateModel: Mappable {
    var firstName: String?
    var lastName:String?
    var id: String?
    var userId: String?
    var image: UserImage?
    var locationActive: Bool?
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case id = "id"
        case userId = "user_id"
        case image = "image"
        case locationActive = "location_active"
    }
}

struct UserImage: Mappable, AWSImage {
    var bucket: String?
    var key: String?
}
