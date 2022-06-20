//
//  MenuViewController.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/19/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cartography
import SideMenu
import RxCocoa
import RxSwift

let menuWidth = UIScreen.main.bounds.width * 282 / 375

class MenuViewController: TableViewController {
    let viewModel = MenuViewModel.shared
    let closeButton = Button()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        MenuHeaderCell.registerCell(tableView: tableView)
        MenuCell.registerCell(tableView: tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.bounces = false
        
        applyDefaultConstrain()
        
        view.addSubview(closeButton)
        
        constrain(closeButton, tableView, car_topLayoutGuide) { closeButton, tableView, top in
            closeButton.top == top.bottom + K.Dimen.smallMargin
            closeButton.trailing == closeButton.superview!.trailing - K.Dimen.smallMargin
            closeButton.width == 40
            closeButton.height == 40
        }
    }
    
    override func applyStyling() {
        super.applyStyling()
        
        closeButton.setImage(UIImage(named: "icon_close"), for: .normal)
        closeButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 0)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    override func addObservables() {
        super.addObservables()
        
        closeButton.rx.tap
            .subscribe(onNext: { (_) in
                MenuViewController.dismiss()
            }).disposed(by: disposeBag)
        
        viewModel.refreshAction
            .subscribe(onNext: { (_) in
                self.tableView.reloadData()
            }).disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .map{ self.viewModel.items.value[$0.row - 1] }
            .bind(to: viewModel.selectAction)
            .disposed(by: disposeBag)
    }
}

extension MenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.value.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0, let cell = MenuHeaderCell.dequeueCell(tableView: tableView) {
            cell.load(viewModel: viewModel, indexPath: indexPath)
            return cell
        } else if indexPath.row > 0, let cell = MenuCell.dequeueCell(tableView: tableView) {
            cell.load(viewModel: viewModel, indexPath: indexPath)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath.row == 0 ? nil : indexPath
    }
}

// MARK: Static Function
extension MenuViewController {
    static func configure() {
        let leftNavigationController =
            UISideMenuNavigationController(rootViewController: MenuViewController())
        SideMenuManager.default.menuLeftNavigationController = leftNavigationController
        SideMenuManager.default.menuFadeStatusBar = false
        SideMenuManager.default.menuWidth = menuWidth
        SideMenuManager.default.menuPresentMode = .menuSlideIn
    }
    
    static func addGesture(viewController: ViewController) {
        SideMenuManager.default.menuAddPanGestureToPresent(toView: viewController.navigationController!.navigationBar)
        SideMenuManager.default.menuAddPanGestureToPresent(toView: viewController.navigationController!.view)
    }
    
    static func addGesture(navigationController: NavigationController) {
//        SideMenuManager.default.menuAddPanGestureToPresent(toView: navigationController.navigationBar)
//        SideMenuManager.default.menuAddPanGestureToPresent(toView: navigationController.view)
    }
    
    static func present(viewController: ViewController) {
        viewController.present(SideMenuManager.default.menuLeftNavigationController!,
                               animated: true,
                               completion: nil)
    }
    
    static func dismiss(completion: (() -> Void)? = nil) {
        SideMenuManager.default.menuLeftNavigationController?.dismiss(animated: true, completion: completion)
    }
}
