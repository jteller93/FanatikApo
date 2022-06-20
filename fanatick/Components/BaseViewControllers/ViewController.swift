//
//  ViewController.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/8/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import UIKit
import RxSwift
import Cartography

class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    let backBtn: UIBarButtonItem = UIBarButtonItem(image: UIImage(named:"icon_back")?.withRenderingMode(.alwaysTemplate),
                                                    style: .plain,
                                                    target: nil,
                                                    action: nil)
    let menuBtn: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_thunder")?.withRenderingMode(.alwaysOriginal),
                                                   style: .plain,
                                                   target: nil,
                                                   action: nil)
    lazy var closeBtn: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_close"),
                                                         style: .plain,
                                                         target: self,
                                                         action: #selector(dismissButtonTapped))
    
    var hasMenu: Bool = false {
        didSet {
            if hasMenu {
                addBarButton(button: menuBtn, toRight: false)
            } else {
                removeBarButton(button: menuBtn, toRight: false)
            }
        }
    }
    
    open var hasBackButton: Bool = true
    
    var hasCloseButton = false {
        didSet {
            if hasCloseButton {
                addBarButton(button: closeBtn, toRight: true, animated: false)
            } else {
                removeBarButton(button: closeBtn)
            }
        }
    }
    
    var customNavigationBar: NavigationBar!
    
    var hasYellowNavigation: Bool = false {
        didSet {
            if hasYellowNavigation {
                setCustomNavigationBar()
            }
        }
    }
    
    var hideNavigationBar: Bool = false {
        didSet {
            navigationController?.setNavigationBarHidden(hideNavigationBar, animated: hideNavigationBar)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        setupSubviews()
        applyStyling()
        addObservables()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if (navigationController?.viewControllers.count ?? 0) > 1 && hasBackButton {
            addBarButton(button: backBtn, toRight: false)
        } else {
            removeBarButton(button: backBtn, toRight: false)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reapplyStyling()
    }

    // Get called in viewDidLoad
    func applyStyling() {
        view.backgroundColor = .fanatickGrey
    }
    // Get called in viewWillAppear
    func reapplyStyling() {}
    func setupSubviews() {}
    func addObservables() {
        menuBtn.rx.tap
            .subscribe(onNext: { [weak self] (_) in
                self?.apply{ MenuViewController.present(viewController: $0) }
            }).disposed(by: disposeBag)
        
        backBtn.rx.tap
            .subscribe(onNext: { [weak self] (_) in
                self?.backButtonTapped()
            }).disposed(by: disposeBag)
    }
    
    func addBarButton(button: UIBarButtonItem, toRight right:Bool = true, animated: Bool = false) {
        if right {
            var rightBarButtonItems = navigationItem.rightBarButtonItems
            if rightBarButtonItems == nil {
                navigationItem.setRightBarButtonItems([button], animated: animated)
            } else if !rightBarButtonItems!.contains(button) {
                rightBarButtonItems?.insert(button, at: 0)
                navigationItem.setRightBarButtonItems(rightBarButtonItems, animated: animated)
            }
        } else {
            var leftBarButtonItems = navigationItem.leftBarButtonItems
            if leftBarButtonItems == nil {
                navigationItem.setLeftBarButtonItems([button], animated: animated)
            }  else if !leftBarButtonItems!.contains(button) {
                leftBarButtonItems?.insert(button, at: 0)
                navigationItem.setLeftBarButtonItems(leftBarButtonItems, animated: animated)
            }
        }
    }
    
    func removeBarButton(button: UIBarButtonItem, toRight right:Bool = true, animated: Bool = false) {
        if right {
            var rightBarButtonItems = navigationItem.rightBarButtonItems
            rightBarButtonItems?.remove(button)
            navigationItem.setRightBarButtonItems(rightBarButtonItems, animated: animated)
        } else {
            var leftBarButtonItems = navigationItem.leftBarButtonItems
            leftBarButtonItems?.remove(button)
            navigationItem.setLeftBarButtonItems(leftBarButtonItems, animated: animated)
        }
    }
    
    func handleError(error: RuntimeError) {
        let controller = UIAlertController.init(title: "", message: error.localizedDescription, preferredStyle: .alert)
        controller.addAction(UIAlertAction.init(title: LocalizedString("buttonTitle_ok", story: .general), style: .cancel, handler: { (_) in
        }))
        present(controller, animated: true, completion: nil)
    }
    
    func showMessage(title: String, message: String) {
        let controller = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction.init(title: LocalizedString("buttonTitle_ok", story: .general), style: .cancel, handler: { (_) in
        }))
        present(controller, animated: true, completion: nil)
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func dismissButtonTapped() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    // Keyboard
    @objc
    func keyboardWillShow(_ notification: NSNotification) {}
    
    @objc
    func keyboardWillHide(_ notification: NSNotification) {}
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func setCustomNavigationBar() {
        navigationController?.isNavigationBarHidden = true
        customNavigationBar = NavigationBar()
        view.addSubview(customNavigationBar)
        constrain(customNavigationBar) { (customNavigationBar) in
            customNavigationBar.top == customNavigationBar.superview!.top
            customNavigationBar.leading == customNavigationBar.superview!.leading
            customNavigationBar.trailing == customNavigationBar.superview!.trailing
            customNavigationBar.height == K.Dimen.navigationBarHeight
        }
        
        customNavigationBar.rightButton.rx.tap.subscribe(onNext: { [weak self] (_) in
            self?.dismissButtonTapped()
        }).disposed(by: disposeBag)
    }
}

extension UIViewController {
    func showAlertForStripePayment() {
        let alertController = UIAlertController.init(title: nil, message: LocalizedString("payment_not_setup"), preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction.init(title: LocalizedString("cancel"), style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction.init(title: LocalizedString("buttonTitle_ok"), style: .default, handler: { (action) in
            StripeConfig.openStripeAccountVerification()
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    func showAlertForNoProMember() {
           let alertController = UIAlertController.init(title: nil, message: LocalizedString("not_subscribed"), preferredStyle: .alert)
           
           alertController.addAction(UIAlertAction.init(title: LocalizedString("cancel"), style: .cancel, handler: nil))
           alertController.addAction(UIAlertAction.init(title: LocalizedString("buttonTitle_ok"), style: .default, handler: { (action) in
            let vc = MembershipViewController()
            let nc = NavigationController(rootViewController: vc)
            vc.hasCloseButton = true
            self.present(nc, animated: true, completion: nil)
           }))
           present(alertController, animated: true, completion: nil)
       }
}
