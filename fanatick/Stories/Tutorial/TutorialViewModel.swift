//
//  TutorialViewModel.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/11/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import UIKit

class TutorialViewModel: ViewModel {
  let tutorials: [Tutorial] = [
    Tutorial(title: LocalizedString("title_1", story: .tutorial),
             description: LocalizedString("description_1", story: .tutorial),
             image: UIImage(named: "tutorial1")!),
    Tutorial(title: LocalizedString("title_2", story: .tutorial),
             description: LocalizedString("description_2", story: .tutorial),
             image: UIImage(named: "tutorial2")!),
    Tutorial(title: LocalizedString("title_3", story: .tutorial),
             description: LocalizedString("description_3", story: .tutorial),
             image: UIImage(named: "tutorial3")!),
    Tutorial(title: LocalizedString("title_4", story: .tutorial),
             description: LocalizedString("description_4", story: .tutorial),
             image: UIImage(named: "tutorial4")!),
    
  ];
}

struct Tutorial {
    var title: String?
    var description: String?
    var image: UIImage
}
