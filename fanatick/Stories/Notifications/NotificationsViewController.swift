//
//  NotificationsViewController.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/30/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cartography
import UIKit
import RxCocoa
import RxSwift

class NotificationsViewController: TableViewController {
    let viewModel = NotificationsViewModel()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        applyDefaultConstrain()
        
        NotificationsCell.registerCell(tableView: tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func applyStyling() {
        super.applyStyling()
        
        hasMenu = true
        
        navigationItem.title = LocalizedString("notifications", story: .notifications)
    }
    
    override func addObservables() {
        super.addObservables()
        
        viewModel.notificationAction.accept(())
        
        // TODO handle click
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] (_) in
                // TODO route to correct place
//                let viewController = ProTipViewController()
//                self?.present(NavigationController(rootViewController: viewController), animated: true, completion: nil)
            }).disposed(by: disposeBag)
        
        viewModel.notifications.subscribe(onNext: { [weak self] notificatons in
            self?.tableView.reloadData()
        }).disposed(by: disposeBag)
    }
}

extension NotificationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.notifications.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = NotificationsCell.dequeueCell(tableView: tableView) {
            cell.load(viewModel: viewModel, indexPath: indexPath)
            return cell
        }
        return UITableViewCell()
    }
}
