//
//  Algolia.swift
//  fanatick
//
//  Created by Vincent Ngo on 5/21/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import Wires

struct AlgoliaFacetResponse: Mappable {
    var facetHits: [Facet]
}

struct Facet: Mappable {
    var count: Int?
    var highlighted: String?
    var value: String?
}

struct AlgoliaEventResponse: Mappable {
    var query: String?
    var page: Int?
    var totalHits: Int?
    var totalPages: Int?
    var hitsPerPage: Int?
    var hits: [Event] = []
    var hasNextPage: Bool {
        return page ?? 0 < totalPages ?? 0
    }
    
    enum CodingKeys: String, CodingKey {
        case query
        case page
        case hitsPerPage
        case hits
        case totalPages = "nbPages"
        case totalHits = "nbHits"
    }
}
