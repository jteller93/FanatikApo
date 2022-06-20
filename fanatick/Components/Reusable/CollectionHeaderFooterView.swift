//
//  CollectionHeaderFooterView.swift
//  fanatick
//
//  Created by Yashesh on 01/06/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NutsAndBolts

class CollectionHeaderFooterView: UICollectionReusableView {
    
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
        collectionView.register(self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: defaultReuseIdentifier())
    }
    
    class func dequeueCell(collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> CollectionHeaderFooterView? {
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: defaultReuseIdentifier(), for: indexPath) as? CollectionHeaderFooterView
    }
    
    func defaultReuseIdentifier() -> String {
        return String(describing: self)
    }
}
