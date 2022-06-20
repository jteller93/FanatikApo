//
//  RatingModel.swift
//  fanatick
//
//  Created by Vincent Ngo on 12/9/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import Alamofire
import Wires

class PostRating: NetworkRequest {
    
    convenience init(ratings: RatingParamsModel) {
        let url = "\(NetworkConfiguration.share.endpoint.urlAddress)ratings"
        
        self.init(url: url,
                  method: .post,
                  headers: NetworkConfiguration.defaultHeaders())
        model = ratings
    }
}


struct RatingParamsModel: Mappable {
    var createdAt: String? = nil
    var id: String? = nil
    var ratingOptions: [RatingOption] = []
    var rating: Int? = nil
    var sellerId: String? = nil
    var transactionId: String? = nil
    var updatedAt: String? = nil
    var userId: String? = nil
    var options: String {
        set {
            ratingOptions = newValue.split(separator: ",")
                .map({ (string) -> RatingOption in
                    return RatingOption(rawValue: String(string))!
                })
        }
        get {
            return ratingOptions.map { (it) -> String in
                return it.rawValue
            }.joined(separator: ",")
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case id
        case options
        case rating
        case sellerId = "seller_id"
        case transactionId = "transaction_id"
        case updatedAt = "updated_at"
        case userId = "user_id"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(id, forKey: .id)
        try container.encode(options, forKey: .options)
        try container.encode(rating, forKey: .rating)
        try container.encode(sellerId, forKey: .sellerId)
        try container.encode(transactionId, forKey: .transactionId)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(userId, forKey: .userId)
    }
    
    init(ratingOptions: [RatingOption] = [],
         rating: Int? = nil,
         sellerId: String? = nil,
         transactionId: String? = nil,
         userId: String? = nil) {
        self.ratingOptions = ratingOptions
        self.rating = rating
        self.sellerId = sellerId
        self.transactionId = transactionId
        self.userId = userId
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        createdAt = try? values.decode(String.self, forKey: .createdAt)
        id = try? values.decode(String.self, forKey: .id)
        options = try! values.decode(String.self, forKey: .options)
        rating = try? values.decode(Int.self, forKey: .rating)
        sellerId = try? values.decode(String.self, forKey: .sellerId)
        transactionId = try? values.decode(String.self, forKey: .transactionId)
        updatedAt = try? values.decode(String.self, forKey: .updatedAt)
        userId = try? values.decode(String.self, forKey: .updatedAt)
    }
}

enum RatingOption: String, Codable {
    case fair = "FAIR"
    case friendly = "FRIENDLY"
    case quick = "QUICK"
    case easyToLocate = "EASY_TO_LOCATE"
    
    enum CodingKeys: String, CodingKey {
        case fair = "FAIR"
        case friendly = "FRIENDLY"
        case quick = "QUICK"
        case easyToLocate = "EASY_TO_LOCATE"
    }
}
