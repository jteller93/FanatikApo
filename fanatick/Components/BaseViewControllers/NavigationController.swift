//
//  NavigationController.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/8/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

extension UINavigationBar {
    class func applyDefaultStyling() {
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font: UIFont.shFont(size: 20, fontType: .sfProDisplay, weight: .regular),
                                                            NSAttributedString.Key.foregroundColor: UIColor.fanatickWhite]
        UINavigationBar.appearance().barStyle = .black
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().tintColor = UIColor.fanatickWhite // Icon color
        UINavigationBar.appearance().barTintColor = UIColor.fanatickGrey // Background color
        UINavigationBar.appearance().isTranslucent = false
        
        var backButtonImage = UIImage(named: "icon_back")
        if #available(iOS 11.0, *) {
            
        } else {
            backButtonImage = backButtonImage?.withAlignmentRectInsets(UIEdgeInsets.init(top: 0, left: 0, bottom: 12, right: 0))
        }
        UINavigationBar.appearance().backIndicatorImage = backButtonImage
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = backButtonImage
        
    }
}

extension UIBarButtonItem {
    class func applyDefaultStyling() {
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .normal)
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -200, vertical: 0), for:UIBarMetrics.default)
        
        let normalAttributes = [NSAttributedString.Key.font: UIFont.shFont(size: 16, fontType: .sfProDisplay, weight: .medium),
                                NSAttributedString.Key.foregroundColor: UIColor.fanatickWhite]
        let highlightedAttributes = [NSAttributedString.Key.font: UIFont.shFont(size: 16, fontType: .sfProDisplay, weight: .medium),
                                     NSAttributedString.Key.foregroundColor: UIColor.fanatickWhite.withAlphaComponent(0.7)]
        let disabledAttributes = [NSAttributedString.Key.font: UIFont.shFont(size: 16, fontType: .sfProDisplay, weight: .medium),
                                  NSAttributedString.Key.foregroundColor: UIColor.fanatickWhite.withAlphaComponent(0.5)]
        
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationController.self]).setTitleTextAttributes(normalAttributes, for: .normal)
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationController.self]).setTitleTextAttributes(highlightedAttributes, for: .highlighted)
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationController.self]).setTitleTextAttributes(disabledAttributes, for: .disabled)
        
        let toolbarNormalAttributes = [NSAttributedString.Key.font: UIFont.shFont(size: 14, fontType: .helveticaNeue, weight: .regular),
                                       NSAttributedString.Key.foregroundColor: UIColor.fanatickWhite]
        let toolbarHighlightedAttributes = [NSAttributedString.Key.font:UIFont.shFont(size: 14, fontType: .helveticaNeue, weight: .regular),
                                            NSAttributedString.Key.foregroundColor: UIColor.fanatickWhite.withAlphaComponent(0.7)]
        let toolbarDisabledAttributes = [NSAttributedString.Key.font: UIFont.shFont(size: 14, fontType: .helveticaNeue, weight: .regular),
                                         NSAttributedString.Key.foregroundColor: UIColor.fanatickWhite.withAlphaComponent(0.5)]
        
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [Toolbar.self]).setTitleTextAttributes(toolbarNormalAttributes, for: .normal)
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [Toolbar.self]).setTitleTextAttributes(toolbarHighlightedAttributes, for: .highlighted)
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [Toolbar.self]).setTitleTextAttributes(toolbarDisabledAttributes, for: .disabled)
        
        if #available(iOS 11.0, *) {
            UINavigationBar.appearance(whenContainedInInstancesOf: [UIDocumentBrowserViewController.self]).tintColor = .fanatickBlack
            let documentNormalAttributes = [NSAttributedString.Key.font: UIFont.shFont(size: 16, fontType: .sfProDisplay, weight: .medium),
                                    NSAttributedString.Key.foregroundColor: UIColor.fanatickBlack]
            let documentHighlightedAttributes = [NSAttributedString.Key.font: UIFont.shFont(size: 16, fontType: .sfProDisplay, weight: .medium),
                                         NSAttributedString.Key.foregroundColor: UIColor.fanatickBlack.withAlphaComponent(0.7)]
            let documentDisabledAttributes = [NSAttributedString.Key.font: UIFont.shFont(size: 16, fontType: .sfProDisplay, weight: .medium),
                                      NSAttributedString.Key.foregroundColor: UIColor.fanatickBlack.withAlphaComponent(0.5)]
            
            UIBarButtonItem.appearance(whenContainedInInstancesOf: [UIDocumentBrowserViewController.self]).setTitleTextAttributes(documentNormalAttributes, for: .normal)
            UIBarButtonItem.appearance(whenContainedInInstancesOf: [UIDocumentBrowserViewController.self]).setTitleTextAttributes(documentHighlightedAttributes, for: .highlighted)
            UIBarButtonItem.appearance(whenContainedInInstancesOf: [UIDocumentBrowserViewController.self]).setTitleTextAttributes(documentDisabledAttributes, for: .disabled)
        }
    }
}

class NavigationController: UINavigationController {
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        setupSubviews()
        applyStyling()
        addObservables()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reapplyStyling()
    }
    
    // Get called in viewDidLoad
    func applyStyling() {}
    // Get called in viewWillAppear
    func reapplyStyling() {}
    func setupSubviews() {}
    func addObservables() {}
}
