//
//  TableViewHeaderFooterView.swift
//  fanatick
//
//  Created by Vincent Ngo on 5/3/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NutsAndBolts

class TableViewHeaderFooterView: UITableViewHeaderFooterView {
    weak var viewModel : ViewModel?
    var section : Int?
    var disposeBag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
        applyStyling()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupSubviews()
        applyStyling()
    }
    
    func setupSubviews()  {}
    func applyStyling() {}
    
    func load<VM: ViewModel>(viewModel: VM?, section: Int) {
        self.viewModel = viewModel
        self.section = section
    }
    
    class func height() -> CGFloat {
        return UITableView.automaticDimension
    }
    
    class func estimatedHeight() ->CGFloat {
        return K.Dimen.cell
    }
    
    class func registerCell(tableView: UITableView) {
        tableView.simpleRegisterClassForHeaderFooterView(viewClass: self)
    }
    
    class func dequeueCell(tableView: UITableView) -> TableViewHeaderFooterView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: defaultReuseIdentifier()) as? TableViewHeaderFooterView
    }
    
    class func defaultReuseIdentifier() -> String {
        return String(describing: self)
    }
}
