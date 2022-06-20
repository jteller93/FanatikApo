//
//  MenuHeaderCell.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/19/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cartography
import UIKit

class MenuHeaderCell: TableViewCell {
    let thumbnail = UIImageView()
    let nameLabel = Label()
    let separator1 = View()
    let separator2 = View()
    let segmentedControl = SegmentedControl()
    
    override func addSubviews() {
        super.addSubviews()
        
        contentView.addSubview(thumbnail)
        contentView.addSubview(nameLabel)
        contentView.addSubview(separator1)
        contentView.addSubview(separator2)
        contentView.addSubview(segmentedControl)
        
        constrain(thumbnail, nameLabel, separator1, separator2, segmentedControl) { thumbnail, nameLabel, separator1, separator2, segmentedControl in
            thumbnail.width == menuWidth / 2
            thumbnail.height == thumbnail.width
            thumbnail.centerX == thumbnail.superview!.centerX
            thumbnail.top == thumbnail.superview!.top + 40
            
            nameLabel.top == thumbnail.bottom + K.Dimen.smallMargin
            nameLabel.leading == nameLabel.superview!.leading + K.Dimen.defaultMargin
            nameLabel.trailing == nameLabel.superview!.trailing - K.Dimen.defaultMargin
            
            separator1.top == nameLabel.bottom + K.Dimen.smallMargin
            separator1.leading == separator1.superview!.leading
            separator1.trailing == separator1.superview!.trailing
            separator1.height == 1
            
            segmentedControl.width == segmentedControl.superview!.width * 2 / 3
            segmentedControl.top == separator1.bottom + K.Dimen.smallMargin
            segmentedControl.centerX == segmentedControl.superview!.centerX
            segmentedControl.height == 30
            
            separator2.top == segmentedControl.bottom + K.Dimen.smallMargin
            separator2.leading == separator2.superview!.leading
            separator2.trailing == separator2.superview!.trailing
            separator2.height == 1
            separator2.bottom == separator2.superview!.bottom
        }
    }
    
    override func applyStylings() {
        super.applyStylings()
        
        thumbnail.layer.cornerRadius = menuWidth / 4
        thumbnail.layer.masksToBounds = true
        
        segmentedControl.insertSegment(withTitle: LocalizedString("buyer", story: .authentication), at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: LocalizedString("seller", story: .authentication), at: 1, animated: false)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.updateCorner(cornerRadius: 30 / 2)
        
        nameLabel.font = UIFont.shFont(size: 21, fontType: .helveticaNeue, weight: .regular)
        nameLabel.textAlignment = .center
        nameLabel.textColor = .fanatickWhite
        
        separator2.backgroundColor = .fanatickWhite
        separator1.backgroundColor = .fanatickWhite
        
        selectionStyle = .none
    }
    
    override func load<VM: ViewModel>(viewModel: VM?, indexPath: IndexPath) {
        guard let viewModel = viewModel as? MenuViewModel else { return }
        super.load(viewModel: viewModel, indexPath: indexPath)
        
        FirebaseSession.shared.user.subscribe(onNext: { [weak self] (user) in
            self?.nameLabel.text = "\(user?.firstName ?? "") \(user?.lastName ?? "")"
            if let url = user?.image?.publicUrl?.absoluteString {
                self?.thumbnail.setImage(urlString: url)
            } else {
                self?.thumbnail.image = UIImage.image(color: .fanatickWhite)
            }
        }).disposed(by: disposeBag)
        
        viewModel.role.map{ $0.rawValue }
            .distinctUntilChanged()
            .bind(to: segmentedControl.rx.selectedSegmentIndex)
            .disposed(by: disposeBag)
        
        segmentedControl.rx
            .selectedSegmentIndex
            .distinctUntilChanged()
            .map{ Role(rawValue: $0)! }
            .bind(to: viewModel.role)
            .disposed(by: disposeBag)
    }
}
