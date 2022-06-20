//
//  MockListing.swift
//  fanatick
//
//  Created by Vincent Ngo on 5/22/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation

private let listingDataHardCopy = """
{
"delivery_method": "hardcopy",
"event_id": "string",
"id": "string",
"qty": 5,
"quick_buy": true,
"seller": {
    "first_name": "First",
    "last_name" : "Last"
},
"tickets": [
    {
        "id": "string",
        "listing_id": "string",
        "row": "8",
        "seat_number": "D",
        "section": "440"
    },
    {
        "id": "string",
        "listing_id": "string",
        "row": "8",
        "seat_number": "F",
        "section": "440"
    }
],
"unit_price": 4000,
}
"""

private let listingDataDigital = """
{
"delivery_method": "digital",
"event_id": "string",
"id": "string",
"qty": 5,
"quick_buy": false,
"seller": {
    "first_name": "First",
    "last_name" : "Last"
},
"tickets": [
    {
        "id": "string",
        "listing_id": "string",
        "row": "9",
        "seat_number": "D",
        "section": "450"
    },
    {
        "id": "string",
        "listing_id": "string",
        "row": "9",
        "seat_number": "F",
        "section": "450"
    }
],
"unit_price": 4000,
}
"""

extension Mock {
    static func listings() -> [Listing] {
        var listings: [Listing] = []
        
        for _ in 0...10 {
            if let hardCopy = Listing(jsonString: listingDataHardCopy) {
                listings.append(hardCopy)
            }
            if let digital = Listing(jsonString: listingDataDigital) {
                listings.append(digital)
            }
        }
        return listings
    }
}
