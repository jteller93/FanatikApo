//
//  HomeTodayCell.swift
//  fanatick
//
//  Created by Vincent Ngo on 5/3/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cartography
import UIKit
import RxCocoa
import RxSwift

class BuyerHomeTodayCell: TableViewCell {
    let titleLabel = Label()
    let collectionView = UICollectionView(frame: .zero,
                                          collectionViewLayout: UICollectionViewFlowLayout()
                                            .apply({ (layout) in
                                                layout.scrollDirection = .horizontal
                                            }))
    
    override func addSubviews() {
        super.addSubviews()
        
        HomeTodayDetailCell.registerCell(collectionView: collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(collectionView)
        
        constrain(titleLabel, collectionView) { titleLabel, collectionView in
            titleLabel.top == titleLabel.superview!.top + K.Dimen.smallMargin
            titleLabel.leading == titleLabel.superview!.leading + K.Dimen.defaultMargin
            
            collectionView.height == 180
            collectionView.leading == collectionView.superview!.leading
            collectionView.trailing == collectionView.superview!.trailing
            collectionView.top == titleLabel.bottom + K.Dimen.smallMargin
            collectionView.bottom == collectionView.superview!.bottom - K.Dimen.smallMargin ~ UILayoutPriority(750)
        }
    }
    
    override func applyStylings() {
        super.applyStylings()
        
        titleLabel.textColor = .fanatickWhite
        titleLabel.text = LocalizedString("today")
        titleLabel.font = UIFont.shFont(size: 18,
                                        fontType: .sfProDisplay,
                                        weight: .bold)
        
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
    }
    
    override func load<VM: ViewModel>(viewModel: VM?, indexPath: IndexPath) {
        guard let viewModel = viewModel as? BuyerHomeViewModel else { return }
        super.load(viewModel: viewModel, indexPath: indexPath)
        
        collectionView.reloadData()
    }
}

extension BuyerHomeTodayCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 124, height: 179)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return K.Dimen.smallMargin
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return K.Dimen.defaultMargin
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0,
                            left: K.Dimen.defaultMargin,
                            bottom: 0,
                            right: K.Dimen.defaultMargin)
    }
}

extension BuyerHomeTodayCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (viewModel as? BuyerHomeViewModel)?.todayEvents.value.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = HomeTodayDetailCell.dequeueCell(collectionView: collectionView, indexPath: indexPath) {
            cell.load(viewModel: viewModel, indexPath: indexPath)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if let viewModel = viewModel as? BuyerHomeViewModel {
            viewModel.todayCellAction.accept(indexPath)
        }
    }
}

fileprivate class HomeTodayDetailCell: CollectionViewCell {
    let thumbnail = UIImageView()
    let titleLabel = Label()
    let venueLabel = Label()
    let locationLabel = Label()
    let timeLabel = Label()
    
    override func addSubviews() {
        super.addSubviews()
        
        contentView.addSubview(thumbnail)
        contentView.addSubview(venueLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(locationLabel)
        contentView.addSubview(timeLabel)
        
        constrain(thumbnail, venueLabel, titleLabel, locationLabel, timeLabel) { thumbnail, venueLabel, titleLabel, locationLabel, timeLabel in
            thumbnail.top == thumbnail.superview!.top
            thumbnail.leading == thumbnail.superview!.leading
            thumbnail.trailing == thumbnail.superview!.trailing
            thumbnail.height == thumbnail.width
            
            titleLabel.top == thumbnail.bottom + 3
            titleLabel.leading == thumbnail.leading
            titleLabel.trailing == thumbnail.trailing
            
            venueLabel.top == titleLabel.bottom
            venueLabel.leading == titleLabel.leading
            venueLabel.trailing == titleLabel.trailing
            
            locationLabel.top == venueLabel.bottom
            locationLabel.leading == venueLabel.leading
            locationLabel.trailing == timeLabel.leading
            locationLabel.width == timeLabel.width
            
            timeLabel.top == locationLabel.top
            timeLabel.trailing == venueLabel.trailing
        }
    }
    
    override func applyStylings() {
        super.applyStylings()
        
        thumbnail.layer.cornerRadius = 3
        thumbnail.layer.masksToBounds = true
        
        titleLabel.font = UIFont.shFont(size: 18, fontType: .sfProDisplay, weight: .medium)
        titleLabel.textColor = .fanatickWhite
        
        venueLabel.font = UIFont.shFont(size: 10, fontType: .sfProDisplay, weight: .bold)
        venueLabel.textColor = .fanatickLightGrey
        
        locationLabel.font = UIFont.shFont(size: 10, fontType: .sfProDisplay, weight: .regular)
        locationLabel.textColor = .fanatickLightGrey
        
        timeLabel.font = UIFont.shFont(size: 10, fontType: .sfProDisplay, weight: .regular)
        timeLabel.textColor = .fanatickLightGrey
        timeLabel.textAlignment = .right
    }
    
    override func load<VM: ViewModel>(viewModel: VM?, indexPath: IndexPath) {
        guard let viewModel = viewModel as? BuyerHomeViewModel else { return }
        super.load(viewModel: viewModel, indexPath: indexPath)
        
        if indexPath.section == 0 {
            let event = viewModel.todayEvents.value[indexPath.row]
            if let imageUrl = event.image?.publicUrl {
                thumbnail.setImage(urlString: imageUrl.absoluteString)
            } else {
                thumbnail.backgroundColor = .white
            }
            if let startAt = event.startAt, let date = Date.init(fromString: startAt, format: .isoDateTimeMilliSec) {
                timeLabel.text = date.toString(format: DateFormatType.custom("MM/dd HH:mm"))
            } else {
                timeLabel.text = ""
            }
            
            titleLabel.text = event.name
            venueLabel.text = event.venue?.name
            locationLabel.text = event.location?.cityAndState
            
        } else {
            thumbnail.backgroundColor = .white
            
            titleLabel.text = ""
            venueLabel.text = ""
            locationLabel.text = ""
            timeLabel.text = ""
        }
    }
}
