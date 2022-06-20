//
//  UIActivityViewController+Helper.swift
//  fanatick
//
//  Created by Yashesh on 28/06/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import UIKit

extension UIActivityViewController {
    
    static func openActivityViewController(vc: UIViewController, items: [Any]) {
        
        let activityViewController = UIActivityViewController.init(activityItems: items, applicationActivities: nil)
        
        vc.present(activityViewController, animated: true, completion: nil)
    }
}
