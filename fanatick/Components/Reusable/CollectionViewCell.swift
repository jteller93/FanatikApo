//
//  CollectionViewCell.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/8/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import UIKit
import NutsAndBolts
import RxCocoa
import RxSwift

class CollectionViewCell: UICollectionViewCell {
    weak var viewModel : ViewModel?
    var indexPath : IndexPath?
    var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        applyStylings()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubviews()
        applyStylings()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    func applyStylings() {}
    
    func addSubviews() {}
    
    func load<VM: ViewModel>(viewModel: VM?, indexPath: IndexPath) {
        self.viewModel = viewModel
        self.indexPath = indexPath
    }
   
    class func height() -> CGFloat {
        return UITableView.automaticDimension
    }
    
    class func estimatedHeight() ->CGFloat {
        return self.height()
    }
    
    class func registerCell(collectionView: UICollectionView) {
        collectionView.simpleRegisterClass(cellClass: self)
    }
    
    class func dequeueCell(collectionView: UICollectionView, indexPath: IndexPath) -> CollectionViewCell? {
        return collectionView.dequeueReusableCell(withReuseIdentifier: defaultReuseIdentifier(), for: indexPath) as? CollectionViewCell
    }
}
