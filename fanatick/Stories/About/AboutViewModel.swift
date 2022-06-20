//
//  AboutViewModel.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/30/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation

class AboutViewModel: ViewModel {
    var abouts: [AboutItem] = [
        AboutItem(title: LocalizedString("title_1", story: .about),
                  description: LocalizedString("description_1", story: .about)),
        AboutItem(title: LocalizedString("title_2", story: .about),
                  description: LocalizedString("description_2", story: .about)),
        AboutItem(title: LocalizedString("title_3", story: .about),
                  description: LocalizedString("description_3", story: .about)),
        AboutItem(title: LocalizedString("title_4", story: .about),
                  description: LocalizedString("description_4", story: .about))
    ]
}

struct AboutItem {
    var title: String
    var description: String
}
