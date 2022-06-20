//
//  StripeConfig.swift
//  fanatick
//
//  Created by Yashesh on 28/06/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import Stripe

class StripeConfig {
    
    #if DEBUG
    static let publishableKey = "pk_test_jOLNfsR4NICH0KFQkM4diVXX00qBF7liCC"
    #elseif STAGING
    static let publishableKey = "pk_test_jOLNfsR4NICH0KFQkM4diVXX00qBF7liCC"
    #else
    static let publishableKey = "pk_live_w1BO8yY0W0AoRDsTxtGiqXjl00TCQrOCvo"
    #endif
    
    class func setup() {
        STPPaymentConfiguration.shared().publishableKey = publishableKey
    }
    
    class func openStripeAccountVerification() {
        
        if let token = FirebaseSession.shared.fanatickAuthToken {
//            let paymenturl = "https://connect.stripe.com/oauth/authorize?response_type=code&client_id=ca_FPJyjAmXPhrUoEPUcm45jYwTNGTHX9e8&scope=read_write&state=\(token)&redirect_uri=https://fanatick-app-prod.us-west-2.elasticbeanstalk.com/api/v1/stripe/callback"

            #if DEBUG
            let paymenturl = "https://connect.stripe.com/oauth/authorize?response_type=code&client_id=ca_FPJyjAmXPhrUoEPUcm45jYwTNGTHX9e8&scope=read_write&state=\(token)&redirect_uri=https://fanatick-app-dev.us-west-2.elasticbeanstalk.com/api/v1/stripe/callback"

            #elseif STAGING
            let paymenturl = "https://connect.stripe.com/oauth/authorize?response_type=code&client_id=ca_FPJyjAmXPhrUoEPUcm45jYwTNGTHX9e8&scope=read_write&state=\(token)&redirect_uri=http://fanatick-app-stage.us-west-2.elasticbeanstalk.com/api/v1/stripe/callback"

            #else
            let paymenturl = "https://connect.stripe.com/oauth/authorize?response_type=code&client_id=ca_FPJyrbSj2krxJRos7tNV8jGA9nSNyZuX&scope=read_write&state=\(token)&redirect_uri=https://app.fanatickapp.com/api/v1/stripe/callback"

            #endif

            if let url = URL(string: paymenturl) {
                UIApplication.shared.open(url)
            }
        }
    }
}
