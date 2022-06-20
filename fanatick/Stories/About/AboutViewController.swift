//
//  AboutViewController.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/30/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cartography
import UIKit
import RxCocoa
import RxSwift

class AboutViewController: TableViewController {
    let viewModel = AboutViewModel()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        AboutTextCell.registerCell(tableView: tableView)
        AboutHeaderCell.registerCell(tableView: tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
    
        applyDefaultConstrain()
    }
    
    override func applyStyling() {
        super.applyStyling()
        
        hasMenu = true
    }
}

extension AboutViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.abouts.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0, let cell = AboutHeaderCell.dequeueCell(tableView: tableView) {
            return cell
        } else if let cell = AboutTextCell.dequeueCell(tableView: tableView) {
            cell.load(viewModel: viewModel, indexPath: indexPath)
            return cell
        }
        return UITableViewCell()
    }
}
