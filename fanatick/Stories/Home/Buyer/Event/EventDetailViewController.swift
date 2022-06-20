//
//  EventDetailViewController.swift
//  fanatick
//
//  Created by Vincent Ngo on 5/6/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cartography
import UIKit
import RxCocoa
import RxSwift

class EventDetailViewController: TableViewController {
    let viewModel = EventDetailViewModel()
    let dateLabel = Label()
    let venueNameLabel = Label()
    let mapImage = UIImageView()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        EventDetailCell.registerCell(tableView: tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(dateLabel)
        view.addSubview(venueNameLabel)
        view.addSubview(mapImage)
        
        constrain(tableView, mapImage, car_bottomLayoutGuide) { tableView, mapImage, bottom in
            tableView.top == mapImage.bottom
            tableView.leading == tableView.superview!.leading
            tableView.trailing == tableView.superview!.trailing
            tableView.bottom == bottom.top
        }

        constrain(dateLabel, venueNameLabel, mapImage, car_topLayoutGuide) { dateLabel, venueNameLabel, mapImage, top in
            dateLabel.top == top.bottom - 2
            dateLabel.leading == dateLabel.superview!.leading + K.Dimen.defaultMargin
            dateLabel.trailing == dateLabel.superview!.trailing - K.Dimen.defaultMargin
            
            venueNameLabel.top == dateLabel.bottom + K.Dimen.smallMargin
            venueNameLabel.leading == dateLabel.leading
            venueNameLabel.trailing == dateLabel.trailing
            
            mapImage.top == venueNameLabel.bottom + K.Dimen.smallMargin
            mapImage.leading == mapImage.superview!.leading
            mapImage.trailing == mapImage.superview!.trailing
            mapImage.height == mapImage.width * 228 / 375
        }
    }
    
    override func applyStyling() {
        super.applyStyling()
        
        hasCloseButton = true
        
        dateLabel.font = UIFont.shFont(size: 14, fontType: .helveticaNeue, weight: .regular)
        dateLabel.textColor = .fanatickWhite
        dateLabel.textAlignment = .center
        
        venueNameLabel.font = UIFont.shFont(size: 17, fontType: .helveticaNeue, weight: .regular)
        venueNameLabel.textColor = .fanatickWhite
        venueNameLabel.textAlignment = .center
    }
    
    override func addObservables() {
        super.addObservables()
        
        tableView.rx
            .willDisplayCell
            .asSignal()
            .map { [weak self] (_, indexPath) -> Bool in
                guard let `self` = self else { return false }
                return self.viewModel.listings.value.count == indexPath.row + 1
            }.distinctUntilChanged()
            .emit(to: viewModel.isEndReached)
            .disposed(by: disposeBag)
        
        viewModel.event
            .subscribe(onNext: { [weak self] (event) in
                self?.title = event?.name
                self?.venueNameLabel.text = event?.venue?.name
                if let startAt = event?.startAt, let date = Date.init(fromString: startAt, format: DateFormatType.isoDateTimeMilliSec) {
                    self?.dateLabel.text = date.toString(format: DateFormatType.custom(K.DateFormat.eventDetail.rawValue))
                }
                
                if let imageUrl = event?.image?.url {
//                    print(imageUrl)
                    self?.mapImage.setImage(urlString: imageUrl)
                } else {
                    self?.mapImage.backgroundColor = .white
                }
            }).disposed(by: disposeBag)
        
        viewModel.listings
            .subscribe(onNext: { [weak self] (_) in
                self?.tableView.reloadData()
            }).disposed(by: disposeBag)
        
        viewModel.error
            .filter{ $0 != nil }
            .subscribe(onNext: { [weak self] (error) in
                self?.handleError(error: error!.runtimeError)
            }).disposed(by: disposeBag)
        
        //TODO: Using for testing "1LYdbL6kTUBUSXt1NjFGE4bMIaP" it will be blank once event listing working properly
        viewModel.eventID.map { [weak self] (_) -> String in
            return self?.viewModel.event.value?.id ?? ""
            }.bind(to: viewModel.eventDetails).disposed(by: disposeBag)
        
        viewModel.selectedListing.subscribe(onNext:{ [weak self] indexPath in
            let viewController = BuyerNegotiationsViewController()
            viewController.viewModel.list.accept(self?.viewModel.listings.value[indexPath.row])
            let navigationController = NavigationController(rootViewController: viewController)
            self?.navigationController?.present(navigationController, animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }
}

extension EventDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.listings.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = EventDetailCell.dequeueCell(tableView: tableView) {
            cell.load(viewModel: viewModel, indexPath: indexPath)
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        viewModel.selectedListing.accept(indexPath)
    }
}
