//
//  SellerHomeViewController.swift
//  fanatick
//
//  Created by Vincent Ngo on 5/7/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cartography
import UIKit
import RxCocoa
import RxSwift
import Segmentio

class SellerHomeViewController: TableViewController {
    let viewModel = SellerHomeViewModel()
    let segmentio = Segmentio()
    let separator1 = View()
    let addNewListing = Button()
    let separator2 = View()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        SellerHomeTicketCell.registerCell(tableView: tableView)
        tableView.dataSource = self
        tableView.delegate = self
        

        view.addSubview(segmentio)
        view.addSubview(separator1)
        view.addSubview(addNewListing)
        view.addSubview(separator2)
        
        constrain(segmentio, separator1, addNewListing, separator2, car_topLayoutGuide) { segmentio, separator1, addNewListing, separator2, top in
            
            segmentio.top == top.bottom + 24
            segmentio.leading == segmentio.superview!.leading
            segmentio.trailing == segmentio.superview!.trailing
            segmentio.height == 24
            
            separator1.top == segmentio.bottom + 32
            separator1.leading == separator1.superview!.leading
            separator1.trailing == separator1.superview!.trailing
            separator1.height == 9
            
            addNewListing.top == separator1.bottom
            addNewListing.leading == addNewListing.superview!.leading
            addNewListing.trailing == addNewListing.superview!.trailing
            addNewListing.height == 47
            
            separator2.top == addNewListing.bottom
            separator2.leading == separator2.superview!.leading
            separator2.trailing == separator2.superview!.trailing
            separator2.height == 9
        }
        
        constrain(separator2, tableView, car_bottomLayoutGuide) { separator2, tableView, bottom in
            tableView.top == separator2.bottom
            tableView.leading == tableView.superview!.leading
            tableView.trailing == tableView.superview!.trailing
            tableView.bottom == bottom.top
        }
    }
    
    override func applyStyling() {
        super.applyStyling()
        
        separator1.addBorders(.fanatickWhite)
        
        addNewListing.setTitle(LocalizedString("add_new_listing", story: .home), for: .normal)
        addNewListing.setTitleColor(.fanatickBlack, for: .normal)
        addNewListing.setBackgroundImage(UIImage.image(color: .fanatickYellow), for: .normal)
        addNewListing.setImage(UIImage(named: "icon_add"), for: .normal)
        addNewListing.titleLabel?.font = UIFont.shFont(size: 16, fontType: .helveticaNeue, weight: .regular)
        addNewListing.titleEdgeInsets.left = 10
        
        separator2.addBorders(.fanatickWhite)
        
        var segments = [SegmentioItem]()
        let indicatorOption = SegmentioIndicatorOptions(type: SegmentioIndicatorType.bottom,
                                                        ratio: 0.5,
                                                        height: 1,
                                                        color: .fanatickYellow)
        let states = SegmentioStates(
            defaultState: SegmentioState(
                backgroundColor: .clear,
                titleFont: UIFont.shFont(size: 14, fontType: .helveticaNeue, weight: .regular),
                titleTextColor: .fanatickWhite
            ),
            selectedState: SegmentioState(
                backgroundColor: .clear,
                titleFont: UIFont.shFont(size: 14, fontType: .helveticaNeue, weight: .regular),
                titleTextColor: .fanatickYellow
            ),
            highlightedState: SegmentioState(
                titleFont: UIFont.shFont(size: 14, fontType: .helveticaNeue, weight: .regular),
                titleTextColor: .fanatickYellow
            )
        )
        let option = SegmentioOptions(backgroundColor: .clear,
                                      segmentPosition: SegmentioPosition.fixed(maxVisibleItems: 4),
                                      scrollEnabled: false,
                                      indicatorOptions: indicatorOption,
                                      horizontalSeparatorOptions: SegmentioHorizontalSeparatorOptions(type: .none,
                                                                                                      height: 0,
                                                                                                      color: .clear),
                                      verticalSeparatorOptions: nil,
                                      labelTextAlignment: .center,
                                      labelTextNumberOfLines: 0,
                                      segmentStates: states)
        
        SellerHomeViewModel.Segment.allCases.forEach { (segment) in
            segments.append(
                SegmentioItem(title: segment.title(), image: nil)
            )
        }
        
        segmentio.setup(content: segments, style: .onlyLabel, options: option)
    }
    
    override func addObservables() {
        super.addObservables()
        
        NotificationCenter.default.addObserver(forName:Notification.Name.ReloadListing, object: nil, queue: nil) { (_) in
            self.reloadHomeScreen()
        }
        
        tableView.rx
            .willDisplayCell
            .asSignal()
            .map { [weak self] (_, indexPath) -> Bool in
                guard let `self` = self else { return false }
                return self.viewModel.listings.value.count == indexPath.row + 1
            }.distinctUntilChanged()
            .emit(to: viewModel.isEndReached)
            .disposed(by: disposeBag)
        
        addNewListing.rx.tap
            .subscribe(onNext: { [weak self](_) in
                if FirebaseSession.shared.user.value?.stripeID == nil {
                    self?.showAlertForStripePayment()
                    return
                } else {
                    let viewController = SellerSearchEventViewController()
                    let navigationController = NavigationController(rootViewController: viewController)
                    self?.navigationController?.present(navigationController, animated: true, completion: nil)
                }
            }).disposed(by: disposeBag)
        
        segmentio.valueDidChange = { [weak self](_, index) in
            self?.viewModel.selectedSegment.accept(SellerHomeViewModel.Segment(rawValue: index)!)
        }
        
        viewModel.selectedSegment
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] (segment) in
                self?.segmentio.selectedSegmentioIndex = segment.rawValue
                self?.tableView.reloadData()
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
    
        viewModel.cellAction
            .subscribe(onNext: { [weak self] (indexPath) in
                let viewController = ListingDetailsViewController()
                viewController.viewModel.list.accept(self?.viewModel.listings.value[indexPath.row])
                viewController.viewModel.reloadList.subscribe(onNext: { [weak self] _ in
                    self?.reloadHomeScreen()
                }).disposed(by: viewController.disposeBag)
                let navigationController = NavigationController(rootViewController: viewController)
                navigationController.setViewControllers([viewController], animated: true)
                self?.navigationController?.present(navigationController, animated: true, completion: nil)
            }).disposed(by: disposeBag)
        
        viewModel.listingId.subscribe(onNext:{ [weak self] listingId in
            guard let listingId = listingId else { return }
            
            let alertController = UIAlertController.init(title: LocalizedString("delete_Listing", story: .home), message: LocalizedString("this_cannot_be_undone_and_any_offres_will_be_automatically_declined", story: .home), preferredStyle: .alert)
            
            let cancel = UIAlertAction.init(title: LocalizedString("cancel", story: .general), style: .default, handler: nil)
            
            let delete = UIAlertAction.init(title: LocalizedString("delete", story: .general), style: .default, handler: { (_) in
                self?.viewModel.deleteAction.accept(listingId)
            })
            
            alertController.addAction(cancel)
            alertController.addAction(delete)
            self?.navigationController?.present(alertController, animated: true, completion: nil)
            
        }).disposed(by: disposeBag)
        
    }
    
    fileprivate func reloadHomeScreen() {
        self.viewModel.selectedSegment.accept(SellerHomeViewModel.Segment(rawValue: segmentio.selectedSegmentioIndex)!)
    }
}

extension SellerHomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.listings.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = SellerHomeTicketCell.dequeueCell(tableView: tableView) {
            cell.load(viewModel: viewModel, indexPath: indexPath)
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        viewModel.cellAction.accept(indexPath)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            if let listingId = viewModel.listings.value[indexPath.row].id {
                viewModel.listingId.accept(listingId)
            }
        }
    }

}
