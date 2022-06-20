//
//  ResponseHandler.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/8/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import Alamofire
import Wires

class ResponseHandler: Wires.NetworkErrorHandler {
    override func handle(response: DataResponse<Any>) -> (Data?, NetworkError?) {
        var error = NetworkError()
        switch response.result {
        case .success:
            return (response.data, nil)
        case .failure:
            if let data = response.data, let model = try? JSONDecoder().decode(ErrorModel.self, from: data) {
                error.networkingError = model
            } else {
                error.networkingError = response.error
            }
            error.data = response.data
            return (nil, error)
        }
    }
}
