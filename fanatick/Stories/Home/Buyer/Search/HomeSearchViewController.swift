//
//  SearchViewController.swift
//  fanatick
//
//  Created by Vincent Ngo on 5/8/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cartography
import UIKit
import RxCocoa
import RxSwift

class HomeSearchViewController: TableViewController {
    let viewModel = SearchViewModel()
    let buttonViewHolder = View()
    let searchViewHolder = View()
    let cancelButton = Button()
    let searchButton = Button()
    let searchView = UISearchBar()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchView.becomeFirstResponder()
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        HomeEventCell.registerCell(tableView: tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(buttonViewHolder)
        view.addSubview(searchViewHolder)
        
        buttonViewHolder.addSubview(cancelButton)
        buttonViewHolder.addSubview(searchButton)
        
        searchViewHolder.addSubview(searchView)
        
        constrain(buttonViewHolder, searchViewHolder, tableView, car_bottomLayoutGuide) { buttonViewHolder, searchViewHolder, tableView, bottom in
            buttonViewHolder.top == buttonViewHolder.superview!.top
            buttonViewHolder.leading == buttonViewHolder.superview!.leading
            buttonViewHolder.trailing == buttonViewHolder.superview!.trailing
            buttonViewHolder.height == 80
            
            searchViewHolder.top == buttonViewHolder.bottom
            searchViewHolder.leading == searchViewHolder.superview!.leading
            searchViewHolder.trailing == searchViewHolder.superview!.trailing
            
            tableView.leading == tableView.superview!.leading
            tableView.trailing == tableView.superview!.trailing
            tableView.top == searchViewHolder.bottom
            tableView.bottom == bottom.top
        }
        
        constrain(cancelButton, searchButton, searchView) { cancelButton, searchButton, searchView in
            cancelButton.leading == cancelButton.superview!.leading + 10
            cancelButton.bottom == cancelButton.superview!.bottom
            
            searchButton.trailing == searchButton.superview!.trailing - 10
            searchButton.bottom == cancelButton.bottom
            
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
        
        buttonViewHolder.backgroundColor = .fanatickGrey
        
        cancelButton.setTitle(LocalizedString("cancel"), for: .normal)
        cancelButton.setTitleColor(.fanatickWhite, for: .normal)
        cancelButton.titleLabel?.font = UIFont.shFont(size: 16, fontType: .sfProDisplay, weight: .medium)
        
        searchButton.setTitle(LocalizedString("search"), for: .normal)
        searchButton.setTitleColor(.fanatickWhite, for: .normal)
        searchButton.titleLabel?.font = UIFont.shFont(size: 16, fontType: .sfProDisplay, weight: .medium)
        
        searchView.applyDefaultStyling()
        searchView.placeholder = LocalizedString("search_place_holder")
    }
    
    override func addObservables() {
        super.addObservables()
        
        searchButton.rx
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
    }
}

extension HomeSearchViewController: UITableViewDataSource {
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
