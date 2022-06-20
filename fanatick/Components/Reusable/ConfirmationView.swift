//
//  ConfirmationView.swift
//  fanatick
//
//  Created by Yashesh on 16/07/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import UIKit
import RxCocoa
import Cartography
import RxSwift

typealias DismissPopup = () -> ()

class ConfirmationView: View {

    let imageViewTick = UIImageView()
    let labelDescription = Label()
    let imageTickSize = CGSize.init(width: 109, height: 86.4)
    var dismiss: DismissPopup!
    
    override func setupSubviews() {
        super.setupSubviews()
        
        addSubview(imageViewTick)
        addSubview(labelDescription)
        backgroundColor = .fanatickblack_alpa_70
        alpha = 0
        
        constrain(imageViewTick, labelDescription) { (imageViewTick, labelDescription) in
            
            imageViewTick.height == imageTickSize.height
            imageViewTick.width == imageTickSize.width
            imageViewTick.centerX == imageViewTick.superview!.centerX
            imageViewTick.centerY == imageViewTick.superview!.centerY - imageTickSize.height
            
            labelDescription.centerX == labelDescription.superview!.centerX
            labelDescription.top == imageViewTick.bottom + K.Dimen.largeMargin
        }
    }
    
    override func applyStyling() {
        super.applyStyling()
        imageViewTick.image = UIImage.init(named: "checkIconWhite")
        labelDescription.font = UIFont.shFont(size: 24, fontType: .helveticaNeue, weight: .regular)
        labelDescription.textColor = .fanatickWhite
        labelDescription.textAlignment = .center
        labelDescription.numberOfLines = 0
    }
    
    func setText(string: String) {
        labelDescription.text = string
        animate()
    }
    
    fileprivate func animate() {
        
        transform = CGAffineTransform.init(scaleX: 1.5, y: 1.5)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.showViewAlpha()
            self.transform = CGAffineTransform.identity
        }) { (completion) in
            UIView.animate(withDuration: 0.3, delay: 5.0, animations: {
                self.showViewAlpha()
            }, completion: { (completion) in
                if self.dismiss != nil {
                    self.dismiss!()
                }
            })
        }
    }
    
    fileprivate func showViewAlpha() {
        alpha = alpha == 1 ? 0 : 1
    }
    
    func dismissPopup(completion: @escaping DismissPopup) {
        dismiss = completion
    }
}
