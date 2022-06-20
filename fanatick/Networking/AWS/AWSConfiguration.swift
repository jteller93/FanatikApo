//
//  AWSConfiguration.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/30/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import AWSCore
import AWSS3
import AWSCognito

class AWSConfiguration {
    static let callbackKey = "AWSTransferCallback"
    
    #if DEBUG
    static let identityPoolID = "us-west-2:f433ef13-e0fc-4bd9-8bc2-cf320f09f33e"
    static let imageBucket = "fanatick-app-dev"
    #elseif STAGING
    static let imageBucket = "fanatick-app-stage"
    static let identityPoolID = "us-west-2:ff2bb681-0a07-44d5-86cb-919a7ef00b6e"
    #else
    static let imageBucket = "fanatick-app-prod"
    static let identityPoolID = "us-west-2:16d64fd8-0574-417f-9308-32fb7e918be7"
    #endif
    
    class func setup() {
        let credentialProvider = AWSCognitoCredentialsProvider(regionType: .USWest2, identityPoolId: identityPoolID)
        let configuration = AWSServiceConfiguration(region: .USWest2, credentialsProvider: credentialProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        let transferConfig = AWSS3TransferUtilityConfiguration()
        transferConfig.bucket = imageBucket
        AWSS3TransferUtility.register(with: configuration!, transferUtilityConfiguration: transferConfig, forKey: callbackKey)
//        AWSDDLog.sharedInstance.logLevel = .verbose
    }
}

protocol AWSImage {
    var key: String? { get set }
    var bucket: String? { get set }
}

extension AWSImage {
    var publicUrl: URL? {
        get {
            guard let bucket = bucket, let key = key else { return nil }
            let url = AWSS3.default().configuration.endpoint.url
            return url?.appendingPathComponent(bucket)
                .appendingPathComponent(key)
        }
    }
}
