//
//  MyTicketsViewController.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/30/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cartography
import UIKit
import RxCocoa
import RxSwift
import Segmentio

class MyTicketsViewController: TableViewController {
    
    let viewModel = MyTicketsViewModel()
    let segmentio = Segmentio()
    let segmentedControl = SegmentedControl()
    let gradientView = View()
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
        super.viewWillAppear(animated)
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        view.addSubview(segmentio)
        view.addSubview(gradientView)
        view.addSubview(segmentedControl)
        
        
        tableView.dataSource = self
        tableView.delegate = self
        MyTicketsCell.registerCell(tableView: tableView)
        MyTicketViewOfferCell.registerCell(tableView: tableView)
        
        constrain(segmentio, tableView, gradientView, segmentedControl) { (segmentio, tableView, gradientView, segmentedControl) in
            segmentio.top == segmentio.superview!.safeAreaLayoutGuide.top + K.Dimen.smallMargin
            segmentio.leading == segmentio.superview!.leading
            segmentio.trailing == segmentio.superview!.trailing
            segmentio.height == 24
            
            tableView.top == segmentio.bottom + K.Dimen.defaultMargin
            tableView.leading == tableView.superview!.leading
            tableView.trailing == tableView.superview!.trailing
            tableView.bottom == segmentedControl.top
            
            gradientView.leading == gradientView.superview!.leading
            gradientView.trailing == gradientView.superview!.trailing
            gradientView.bottom == gradientView.superview!.bottom
            gradientView.top == segmentedControl.top - 69
            
            segmentedControl.width == segmentedControl.superview!.width * 2 / 4
            segmentedControl.bottom == segmentedControl.superview!.safeAreaLayoutGuide.bottom - K.Dimen.defaultMargin
            segmentedControl.centerX == segmentedControl.superview!.centerX
            segmentedControl.height == 30
        }
        
    }
    
    override func applyStyling() {
        super.applyStyling()
        
        hasMenu = true
        
        navigationItem.title = LocalizedString("mytickets", story: .myTickets)
        
        setupSegmentio()
        
        segmentedControl.insertSegment(withTitle: LocalizedString("buyer", story: .authentication), at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: LocalizedString("seller", story: .authentication), at: 1, animated: false)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.updateCorner(cornerRadius: 30 / 2)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.gradientView.setGradientBackground(colorTop: UIColor.init(white: 0, alpha: 0), colorBottom: .fanatickGrey)
        }
    }
    
    fileprivate func setupSegmentio() {
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
        
        MyTicketsViewModel.Segment.allCases.forEach { (segment) in
            segments.append(
                SegmentioItem(title: segment.title(), image: nil)
            )
        }
        
        segmentio.setup(content: segments, style: .onlyLabel, options: option)
    }
    
    override func addObservables() {
        super.addObservables()
        
        segmentio.valueDidChange = { [weak self](_, index) in
            self?.viewModel.selectedSegment.accept(MyTicketsViewModel.Segment(rawValue: index)!)
            self?.getMyTicketsListings()
        }
        
        viewModel.selectedSegment
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] (segment) in
                self?.segmentio.selectedSegmentioIndex = segment.rawValue
            }).disposed(by: disposeBag)
        
        viewModel.transactions.subscribe(onNext: { [weak self] _ in
            self?.tableView.reloadData()
        }).disposed(by: disposeBag)
        
        viewModel.openNegotiations.subscribe(onNext: { [weak self] (_, section) in
            if section == nil {
                self?.tableView.reloadData()
            }
        }).disposed(by: disposeBag)
        
        viewModel.expanded.subscribe(onNext: { [weak self] section in
            guard let section = section else { return }
            self?.viewModel.expandAction.accept(section)
            self?.tableView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
        }).disposed(by: disposeBag)
        
        viewModel.expandAction.map { [weak self] section -> ([OpenNegotiations], Int?) in
            guard let section = section else { return ([], nil) }
            var negotiations = self?.viewModel.openNegotiations.value.0
            let expanded = negotiations?[section].isExpanded ?? false
            negotiations![section].isExpanded = !expanded
            return (negotiations ?? [], section)
            }.bind(to: viewModel.openNegotiations).disposed(by: disposeBag)
        
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
        
        viewModel.role.subscribe(onNext: { [weak self] _ in
            self?.getMyTicketsListings()
        }).disposed(by: disposeBag)
        
        viewModel.viewTickets.subscribe(onNext: { [weak self] transaction in
            guard let transaction = transaction else {return}
            let viewController = MyTicketsDetailsViewController()
            viewController.viewModel.selectedListing.accept(transaction.listing)
            let navigationController = NavigationController(rootViewController: viewController)
            self?.navigationController?.present(navigationController, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        viewModel.viewOffers.subscribe(onNext:{ [weak self] transaction in
            guard let transaction = transaction else {return}
            let viewController = ListingDetailsViewController()
            viewController.viewModel.list.accept(transaction.listing)
            let navigationController = NavigationController(rootViewController: viewController)
            navigationController.setViewControllers([viewController], animated: true)
            self?.navigationController?.present(navigationController, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        viewModel.viewHardcopyTickets.subscribe(onNext:{ [weak self] transaction in
            guard let transaction = transaction else {return}
            let viewController = BuyerNegotiationsViewController()
            viewController.viewModel.list.accept(transaction.listing)
            let navigationController = NavigationController(rootViewController: viewController)
            self?.navigationController?.present(navigationController, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        viewModel.openNegotiationsViewOffer.subscribe(onNext: { [weak self] negotiations in
            guard let negotiations = negotiations else { return }
            
            var selectedNegotiation = negotiations
            let event = selectedNegotiation.event
            selectedNegotiation.listing?.event = event
            
            if let role = self?.viewModel.role.value {
                switch role {
                case .buyer:
                    let viewController = BuyerNegotiationsViewController()
                    viewController.viewModel.list.accept(selectedNegotiation.listing)
                    let navigationController = NavigationController(rootViewController: viewController)
                    self?.navigationController?.present(navigationController, animated: true, completion: nil)
                case .seller:
                    let viewController = ViewOfferViewController()
                    viewController.viewModel.list.accept(selectedNegotiation.listing)
                    viewController.viewModel.selectedNegotiation.accept(selectedNegotiation)
                    self?.navigationController?.pushViewController(viewController, animated: true)
                }
            }
        }).disposed(by: disposeBag)
        
        viewModel.pickupMap.subscribe(onNext: { [weak self] listing in
            guard let listing = listing else { return }
            let viewController = SellerLocationViewController()
            viewController.viewModel.listing.accept(listing)
            let controller = NavigationController(rootViewController: viewController)
            self?.navigationController?.present(controller, animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }
    
    fileprivate func getMyTicketsListings() {
        switch viewModel.selectedSegment.value {
        case .openNegotiations:
            viewModel.openNegotiaions.accept(())
            break
        case .transactions:
            viewModel.transacitons.accept(())
            break
        }
    }
}

extension MyTicketsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch viewModel.selectedSegment.value {
        case .openNegotiations:
            return viewModel.openNegotiations.value.0.count
        case .transactions:
            return viewModel.transactions.value.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch viewModel.selectedSegment.value {
        case .openNegotiations:
            let negotiation = viewModel.openNegotiations.value.0[section]
            
            return viewModel.role.value == .buyer || negotiation.isExpanded ? negotiation.negotiations?.count ?? 0 : 0
        case .transactions:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = MyTicketViewOfferCell.dequeueCell(tableView: tableView) {
            cell.load(viewModel: viewModel, indexPath: indexPath)
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let cell = MyTicketsCell.dequeueCell(tableView: tableView) {
            cell.load(viewModel: viewModel, section: section)
            return cell
        }
        return UITableViewHeaderFooterView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
}

