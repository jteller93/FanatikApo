//
//  ProTipViewController.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/30/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cartography
import UIKit
import RxCocoa
import RxSwift

class ProTipViewController: TableViewController {
    let viewModel = ProTipViewModel()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        applyDefaultConstrain()
        
        ProTipCell.registerCell(tableView: tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        
    }

    override func applyStyling() {
        super.applyStyling()
        
        hasCloseButton = true
        navigationController?.navigationBar.isTranslucent = true
    }
}

extension ProTipViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = ProTipCell.dequeueCell(tableView: tableView) {
            cell.load(viewModel: viewModel, indexPath: indexPath)
            return cell
        }
        return UITableViewCell()
    }
}
