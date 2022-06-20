//
//  RootViewController.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/11/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cartography
import UIKit

class BuyerHomeViewController: TableViewController {
    var viewModel = BuyerHomeViewModel()
    let header = BuyerHomeHeaderCell()
    let searchViewController = HomeSearchViewController()
    let searchHolder = View()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        BuyerHomeTodayCell.registerCell(tableView: tableView)
        HomeEventCell.registerCell(tableView: tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.tableHeaderView = header
        header.setNeedsLayout()
        header.layoutIfNeeded()
        header.searchView.delegate = self
        
        view.addSubview(searchHolder)
        searchHolder.isHidden = true
        
        constrain(tableView, searchHolder, car_bottomLayoutGuide) { tableView, searchHolder, bottom in
            tableView.top == tableView.superview!.top
            tableView.leading == tableView.superview!.leading
            tableView.trailing == tableView.superview!.trailing
            tableView.bottom == bottom.top
            
            searchHolder.top == searchHolder.superview!.top
            searchHolder.leading == searchHolder.superview!.leading
            searchHolder.trailing == searchHolder.superview!.trailing
            searchHolder.bottom == bottom.top
        }
        
        header.setupSegmentio(titles: [
            "All Events"
        ])
        header.segmentio.selectedSegmentioIndex = 0
    }
    
    override func addObservables() {
        super.addObservables()
        
        header.valueDidChange = { title, index in
            if let facet = self.viewModel.facets.value.first(where: { (f) -> Bool in
                return f.value?.capitalized == title
            }) {
                self.viewModel.selectedFacet.accept(facet)
            } else {
                self.viewModel.selectedFacet.accept(nil)
            }
        }
        
        searchViewController.cancelButton.rx
            .tap
            .subscribe(onNext: { [weak self](_) in
                self?.dismissSearchView()
            }).disposed(by: disposeBag)
        
        searchViewController.searchView.rx
            .text
            .bind(to: header.searchView.rx.text)
            .disposed(by: disposeBag)
        
        searchViewController.viewModel.cellAction
            .subscribe(onNext: { [weak self] (indexPath) in
                let event = self?.searchViewController.viewModel.events.value[indexPath.row]
                self?.dismissSearchView()
                self?.presentEventDetail(event: event)
            }).disposed(by: disposeBag)
        
        tableView.rx
            .willDisplayCell
            .asSignal()
            .map { [weak self] (_, indexPath) -> Bool in
                guard let `self` = self else { return false }
                return indexPath.section == 1 && self.viewModel.futureEvents.value.count == indexPath.row + 1
            }.distinctUntilChanged()
            .emit(to: viewModel.isEndReached)
            .disposed(by: disposeBag)
        
        viewModel.facets
            .subscribe(onNext: { [weak self] (facets) in
                var titles = ["All Events"]
                facets.forEach { (facet) in
                    if let name = facet.value {
                        titles.append(name.capitalized)
                    }
                }
                self?.header.setupSegmentio(titles: titles)
            }).disposed(by: disposeBag)
        
        viewModel.cellAction
            .subscribe(onNext: { [weak self] (indexPath) in
                let event = self?.viewModel.futureEvents.value[indexPath.row]
                self?.presentEventDetail(event: event)
            }).disposed(by: disposeBag)
        
        viewModel.todayCellAction
            .subscribe(onNext: { [weak self] (indexPath) in
                let event = self?.viewModel.todayEvents.value[indexPath.row]
                self?.presentEventDetail(event: event)
            }).disposed(by: disposeBag)
        
        viewModel.error
            .filter{ $0 != nil }
            .subscribe(onNext: { [weak self] (error) in
                self?.handleError(error: error!.runtimeError)
            }).disposed(by: disposeBag)
        
        viewModel.todayEvents
            .skip(1)
            .subscribe(onNext: { [weak self] (_) in
                self?.tableView.reloadData()
            }).disposed(by: disposeBag)
        
        viewModel.futureEvents
            .skip(1)
            .subscribe(onNext: { [weak self] (_) in
                self?.tableView.reloadData()
            }).disposed(by: disposeBag)
    }
    
    func showSearchView() {
        navigationController?.navigationBar.isHidden = true
        searchHolder.isHidden = false
        searchHolder.addSubview(searchViewController.view)
        searchViewController.didMove(toParent: self)
    }
    
    func dismissSearchView() {
        navigationController?.navigationBar.isHidden = false
        searchViewController.willMove(toParent: nil)
        searchViewController.view.removeFromSuperview()
        searchViewController.removeFromParent()
        searchHolder.isHidden = true
    }
    
    func presentEventDetail(event: Event?) {
        let viewController = EventDetailViewController()
        viewController.viewModel.event.accept(event)
        let controller = NavigationController(rootViewController: viewController)
        self.navigationController?
            .present(controller,
                     animated: true,
                     completion: nil)
    }
}

extension BuyerHomeViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        showSearchView()
        return false
    }
}

extension BuyerHomeViewController: UITableViewDataSource {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        if indexPath.section == 1 {
            viewModel.cellAction.accept(indexPath)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // 0th section for today cell, 1st section for future cell
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return (viewModel.todayEvents.value.count > 0) ? 1 : 0
        } else {
            return viewModel.futureEvents.value.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0, let cell = BuyerHomeTodayCell.dequeueCell(tableView: tableView) {
            cell.load(viewModel: viewModel, indexPath: indexPath)
            return cell
        } else if let cell = HomeEventCell.dequeueCell(tableView: tableView) {
            cell.load(viewModel: viewModel, indexPath: indexPath)
            return cell
        }
        return UITableViewCell()
    }
}
