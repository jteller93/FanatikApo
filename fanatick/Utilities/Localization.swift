//
//  Localizatio.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/8/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation

let commonStringTable = "General"
let noLocalizedStringKey = "NoLocalizedStringKey"

enum LocalizationStory: String {
    case about
    case authentication
    case error
    case general
    case home
    case menu
    case notifications
    case tutorial
    case settings
    case newList
    case ticketinfo
    case listingdetail
    case negotiation
    case myTickets
}

private class Localization {
    static func localizedString(forKey key: String, story: LocalizationStory? = nil) -> String {
        if let story = story {
            let tableName = story.rawValue.capitalized
            
            var localizedString = Bundle.main.localizedString(forKey: key, value: noLocalizedStringKey, table: tableName)
            
            if (localizedString == noLocalizedStringKey) {
                localizedString = Bundle.main.localizedString(forKey: key, value: nil, table: commonStringTable)
            }
            return localizedString
        } else {
            return Bundle.main.localizedString(forKey: key, value: nil, table: commonStringTable)
        }
    }
}


func LocalizedString(_ key: String, story: LocalizationStory? = nil) -> String {
    return Localization.localizedString(forKey: key, story: story)
}
