//
//  SellerSearchEventViewController.swift
//  fanatick
//
//  Created by Vincent Ngo on 5/9/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cartography
import UIKit
import RxCocoa
import RxSwift

class SellerSearchEventViewController: TableViewController, GeolocationServiceDelegate {
    let viewModel = SearchViewModel()
    let searchViewHolder = View()
    let searchView = UISearchBar()
    let cancelBtn: UIBarButtonItem = UIBarButtonItem(title: LocalizedString("cancel"),
                                                     style: .plain, target: nil, action: nil)
    let searchBtn: UIBarButtonItem = UIBarButtonItem(title: LocalizedString("search"),
                                                     style: .plain, target: nil, action: nil)
    var locationService = GeolocationService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationService.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchView.becomeFirstResponder()
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        HomeEventCell.registerCell(tableView: tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(searchViewHolder)
        
        searchViewHolder.addSubview(searchView)
        
        addBarButton(button: cancelBtn, toRight: false)
        addBarButton(button: searchBtn, toRight: true)
        
        constrain(searchViewHolder, tableView, car_topLayoutGuide, car_bottomLayoutGuide) {searchViewHolder, tableView, top, bottom in
            searchViewHolder.top == top.bottom
            searchViewHolder.leading == searchViewHolder.superview!.leading
            searchViewHolder.trailing == searchViewHolder.superview!.trailing
            
            tableView.leading == tableView.superview!.leading
            tableView.trailing == tableView.superview!.trailing
            tableView.top == searchViewHolder.bottom
            tableView.bottom == bottom.top
        }
        
        constrain(searchView) { searchView in
            searchView.top == searchView.superview!.top + 10
            searchView.bottom == searchView.superview!.bottom - 10
            searchView.leading == searchView.superview!.leading + 10
            searchView.trailing == searchView.superview!.trailing - 10
            searchView.height == 40
        }
    }
    
    override func applyStyling() {
        super.applyStyling()
        
        searchViewHolder.backgroundColor = .fanatickGrey
        
        searchView.applyDefaultStyling()
        searchView.placeholder = LocalizedString("search_place_holder")
        
        title = LocalizedString("add_new_listing", story: .home)
    }
    
    override func addObservables() {
        super.addObservables()
        
        cancelBtn.rx.tap
            .subscribe(onNext: { [weak self] (_) in
                self?.navigationController?.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)
        
        searchBtn.rx
            .tap
            .do(onNext: { [weak self] (_) in
                self?.viewModel.page.accept(nil)
                self?.viewModel.hasNext.accept(true)
            }).bind(to: viewModel.loadNextAction)
            .disposed(by: disposeBag)
        
        searchView.rx
            .text
            .orEmpty
            .distinctUntilChanged()
            .throttle(0.5, scheduler: MainScheduler.instance)
            .bind(to: viewModel.query)
            .disposed(by: disposeBag)
        
        tableView.rx
            .willDisplayCell
            .asSignal()
            .map { [weak self] (_, indexPath) -> Bool in
                guard let `self` = self else { return false }
                return self.viewModel.events.value.count == indexPath.row + 1
            }.distinctUntilChanged()
            .emit(to: viewModel.isEndReached)
            .disposed(by: disposeBag)
        
        tableView.rx
            .itemSelected
            .bind(to: viewModel.cellAction)
            .disposed(by: disposeBag)
        
        viewModel.error
            .filter{ $0 != nil }
            .subscribe(onNext: { [weak self] (error) in
                self?.handleError(error: error!.runtimeError)
            }).disposed(by: disposeBag)
        
        viewModel.events
            .skip(1)
            .subscribe(onNext: { [weak self] (_) in
                self?.tableView.reloadData()
            }).disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] (indexPath) in
                let event = self?.viewModel.events.value[indexPath.row]
                self?.presentEventDetail(event: event)
            }).disposed(by: disposeBag)
    }
    
    func presentEventDetail(event: Event?) {
        let viewController = AddNewListingViewController()
        viewController.viewModel.event.accept(event)
        let navigationController = NavigationController(rootViewController: viewController)
        self.navigationController?.present(navigationController, animated: true, completion: nil)
    }
}

extension SellerSearchEventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.events.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = HomeEventCell.dequeueCell(tableView: tableView) {
            cell.load(viewModel: viewModel, indexPath: indexPath)
            return cell
        }
        return UITableViewCell()
    }
}
