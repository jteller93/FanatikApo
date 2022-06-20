//
//  AddTicketInfoViewController.swift
//  fanatick
//
//  Created by Vincent Ngo on 5/10/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cartography
import UIKit
import RxCocoa
import RxSwift

class AddTicketInfoViewController: ViewController {
    let viewModel = AddTicketInfoViewModel()
    let collectionViewTicketInfo = UICollectionView(frame: .zero,
                                                    collectionViewLayout: UICollectionViewFlowLayout()
                                                        .apply({ (layout) in
                                                            layout.scrollDirection = .vertical
                                                            layout.minimumLineSpacing = 0
                                                            layout.minimumInteritemSpacing = 0
                                                        }))
    let buttonListTicket              = Button()
    var seatInfosection               : String?
    var seatInfoRow                   : String?
    
    override func setupSubviews() {
        super.setupSubviews()
        setupCollectionView()
    }
    
    func setupCollectionView() {
        
        TicketInfoCell.registerCell(collectionView: collectionViewTicketInfo)
        TicketInfoHeaderCell.registerCell(collectionView: collectionViewTicketInfo)
        collectionViewTicketInfo.delegate = self
        collectionViewTicketInfo.dataSource = self
        view.addSubview(collectionViewTicketInfo)
        view.addSubview(buttonListTicket)
        
        constrain(collectionViewTicketInfo, buttonListTicket) { (collectionViewTicketInfo, buttonListTicket) in
            
            collectionViewTicketInfo.top == collectionViewTicketInfo.superview!.top
            collectionViewTicketInfo.leading == collectionViewTicketInfo.superview!.leading + 7
            collectionViewTicketInfo.trailing == collectionViewTicketInfo.superview!.trailing - 7
            collectionViewTicketInfo.bottom == collectionViewTicketInfo.superview!.bottom - 100
            
            buttonListTicket.leading == buttonListTicket.superview!.leading + 16
            buttonListTicket.trailing == buttonListTicket.superview!.trailing - 16
            buttonListTicket.bottom == buttonListTicket.superview!.safeAreaLayoutGuide.bottom - 30
            buttonListTicket.height == K.Dimen.textFieldHeight
            
        }
    }
    
    override func applyStyling() {
        super.applyStyling()
        
        hasCloseButton = true
        navigationController?.navigationBar.isTranslucent = true
        title = LocalizedString("seat_info", story: .ticketinfo)
        collectionViewTicketInfo.backgroundColor = .clear
        
        buttonListTicket.defaultYellowStyling(cornerRadius: K.Dimen.button / 2, borderColor: .fanatickLightGrey)
        buttonListTicket.setTitle(LocalizedString("list_tickets", story: .ticketinfo), for: .normal)

        collectionViewTicketInfo.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 100, right: 0)
    }
    
    override func addObservables() {
        super.addObservables()
        
        viewModel.sectionSelecion.subscribe(onNext: { [weak self] (section) in
            self?.seatInfosection = section
        }).disposed(by: disposeBag)
        
        viewModel.rowValue.subscribe(onNext: { [weak self] (rowValue) in
            self?.seatInfoRow = rowValue
        }).disposed(by: disposeBag)
        
        viewModel.listingAction.map { [weak viewModel, weak self] listing -> Listing? in
            guard let viewModel = viewModel else { return nil }
            var listing = viewModel.ticketListing.value
            if listing == nil { return nil }
            listing!.section = self?.seatInfosection
            listing!.row = self?.seatInfoRow
            return listing
            }.filter{ $0 != nil }.bind(to: viewModel.ticketListing)
            .disposed(by: disposeBag)
        
        buttonListTicket.rx.tap.subscribe(onNext: { [weak viewModel, weak self] (_) in
            if viewModel?.ticketListing.value?.deliveryMethod == .hardcopy {
                self?.dismissKeyboard()
                viewModel?.listTicketAction.accept(())
            } else {
                let viewController = UploadDigitalTicketViewController()
                viewController.viewModel.setTicketDatatoModel(listing: viewModel?.ticketListing.value)
                let navigationController = NavigationController(rootViewController: viewController)
                self?.navigationController?.present(navigationController, animated: true, completion: nil)
            }
            
        }).disposed(by: disposeBag)
        
        viewModel.error
            .filter{ $0 != nil }
            .subscribe(onNext: { [weak self] (error) in
                self?.handleError(error: error!.runtimeError)
            }).disposed(by: disposeBag)
        
        viewModel.success.subscribe(onNext: { [weak self] (_) in
            NotificationCenter.default.post(name: Notification.Name.ReloadListing, object: nil)
            self?.presentingViewController?
                .presentingViewController?
                .presentingViewController?
                .dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        viewModel.isValid
            .bind(to: buttonListTicket.rx.isEnabled)
            .disposed(by: disposeBag)
    }
}

extension AddTicketInfoViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.ticketListing.value?.tickets?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = TicketInfoCell.dequeueCell(collectionView: collectionView, indexPath: indexPath) {
            cell.load(viewModel: viewModel, indexPath: indexPath)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            if let cell = TicketInfoHeaderCell.dequeueCell(collectionView: collectionView, kind: UICollectionView.elementKindSectionHeader, indexPath: indexPath) {
                cell.load(viewModel: viewModel, indexPath: indexPath)
                return cell
            }
        }
        return UICollectionReusableView()
    }
    
}

extension AddTicketInfoViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 2, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.init(width: collectionView.frame.size.width, height: 196)
    }
}
