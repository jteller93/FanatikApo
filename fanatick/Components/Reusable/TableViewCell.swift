//
//  TableViewCell.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/8/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cartography
import Foundation
import NutsAndBolts
import RxCocoa
import RxSwift

class TableViewCell: UITableViewCell {
    weak var viewModel : ViewModel?
    var indexPath : IndexPath?
    let separator = Separator()
    var disposeBag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubviews()
        applyStylings()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
        applyStylings()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    func addSeparator(margin: CGFloat) {
        contentView.addSubview(separator)
        constrain(separator) { separator in
            separator.bottom == separator.superview!.bottom
            separator.leading == separator.superview!.leading + margin
            separator.trailing == separator.superview!.trailing - margin
        }
    }
    
    func removeSeparator() {
        separator.removeFromSuperview()
    }
    
    func addSubviews()  {}
    func applyStylings() {
        backgroundColor = .clear
    }
    
    func load<VM: ViewModel>(viewModel: VM?, indexPath: IndexPath) {
        self.viewModel = viewModel
        self.indexPath = indexPath
    }
    
    class func height() -> CGFloat {
        return UITableView.automaticDimension
    }
    
    class func estimatedHeight() ->CGFloat {
        return K.Dimen.cell
    }
    
    class func registerCell(tableView: UITableView) {
        tableView.simpleRegisterClass(cellClass: self)
    }
    
    class func dequeueCell(tableView: UITableView) -> TableViewCell? {
        return tableView.dequeueReusableCell(withIdentifier: defaultReuseIdentifier()) as? TableViewCell
    }
}
