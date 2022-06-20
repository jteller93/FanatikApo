//
//  K.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/8/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import UIKit

enum K {
    static let eventsLimit = 5
    static let window = UIApplication.shared.connectedScenes
        .filter({$0.activationState == .foregroundActive})
        .map({$0 as? UIWindowScene})
        .compactMap({$0})
        .first?.windows
        .filter({$0.isKeyWindow}).first
    static let maxPaidTime = 15.0 * 60.0 // 15mins
    
    enum DateFormat: String {
        case eventDetail = "EEEE, MMMM dd 'at' hh:mma"
    }
    
    enum Dimen {
        static let cell: CGFloat = 65
        static let button: CGFloat = 50
        static let expandedCell: CGFloat = 320
        static let xSmallMargin: CGFloat = 8
        static let smallMargin: CGFloat = 16
        static let defaultMargin: CGFloat = 20
        static let largeMargin: CGFloat = 30
        static let textFieldHeight: CGFloat = 50
        static let toolBarHeight: CGFloat = 43.5
        static let topPadding = window?.safeAreaInsets.top == 0 ? K.Dimen.defaultMargin : window?.safeAreaInsets.top ?? 0 
        static let bottomPadding = window?.safeAreaInsets.bottom ?? 0
        static let navigationBarHeight: CGFloat = (K.Dimen.topPadding > 0 ? K.Dimen.topPadding + 67 : 87) // Yellow color Navigation bar height as per zeplin.
        static let screenSize: CGSize = window?.frame.size ?? .zero
    }
    
    enum URL {
        // TODO update URL
        static let privacyUrl = "https://fanatickapp.com/privacy/"
        static let termOfUseUrl = "https://fanatickapp.com/privacy/"
        static let stripeUrl = "https://dashboard.stripe.com/login"
    }
    
    enum PathExtension: String {
        case PDF = "pdf"
        case PNG = "png"
    }
    
    static let miles = 0.000621371192
}
