//
//  SellerListingBuyerStatusViewController.swift
//  fanatick
//
//  Created by Yashesh on 12/06/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Cartography


class SellerListingBuyerStatusViewController: TableViewController {

    var viewModel = ListingDetailsViewModel()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        hasYellowNavigation = true
        
        ListingHeaderCell.registerCell(tableView: tableView)
        ListingDetailBuyerStatusCell.registerCell(tableView: tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        tableView.isScrollEnabled = false
        
        constrain(tableView, customNavigationBar) { (tableView, customNavigationBar) in
            tableView.top == customNavigationBar.bottom
            tableView.leading == tableView.superview!.leading
            tableView.trailing == tableView.superview!.trailing
            tableView.bottom == tableView.superview!.safeAreaLayoutGuide.bottom
        }
    }
    
    override func applyStyling() {
        super.applyStyling()
        
        customNavigationBar.set(title: nil, subtitle: LocalizedString("listing_details", story: .listingdetail).addColon())
    }
    
    override func addObservables() {
        super.addObservables()
        
        getBuyerDetails()
        
        viewModel.selectedNegotiation.subscribe(onNext:{ [weak self] _ in
            self?.tableView.reloadData()
        }).disposed(by: disposeBag)
        
        viewModel.startScanner.subscribe(onNext: { [weak self] startScanner in
            guard startScanner != nil, startScanner == true else { return }
            let viewController = ScannerViewController()
            viewController.delegate = self
            let controller = NavigationController(rootViewController: viewController)
            self?.navigationController?.present(controller, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        viewModel.paymentVerified.subscribe(onNext: { [weak self] success in
            guard let success = success, success == true else { return }
            self?.setupConfirmationView()
        }).disposed(by: disposeBag)

        PushWooshObserver.shared.notificationReceiver.subscribe(onNext: { [weak self] notify in
            if notify == true {
                self?.getBuyerDetails()
            }
        }).disposed(by: disposeBag)
        
        viewModel.cancelPayment.subscribe(onNext:{ [weak self] negotiation in
            guard let negotiation = negotiation else { return }
            if negotiation.transaction?.state ?? .exception == .canceled {
                self?.dismissButtonTapped()
            }
        }).disposed(by: disposeBag)
    }
    
    func getBuyerDetails() {
        if let userid = viewModel.selectedNegotiation.value?.transaction?.userId, viewModel.selectedNegotiation.value?.buyer == nil {
            viewModel.getBuyerDetail.accept(userid)
        }
    }
    
    override func dismissButtonTapped() {
        presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func setupConfirmationView() {
        let confirmationView = ConfirmationView()
        navigationController?.view.addSubview(confirmationView)
        confirmationView.frame = view.bounds
        confirmationView.setText(string: "Scan successful!\nYour transaction\nis now complete.")
        confirmationView.dismissPopup {
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            NotificationCenter.default.post(name: Notification.Name.ReloadListing, object: nil)
        }
    }
}

extension SellerListingBuyerStatusViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            if let cell = ListingHeaderCell.dequeueCell(tableView: tableView) as? ListingHeaderCell {
                cell.load(viewModel: viewModel, indexPath: indexPath)
                return cell
            }
        } else {
            if let cell = ListingDetailBuyerStatusCell.dequeueCell(tableView: tableView) as? ListingDetailBuyerStatusCell {
                 cell.load(viewModel: viewModel, indexPath: indexPath)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        } else  {
            return getStatusCellHeight()
        }
    }
    
    fileprivate func getStatusCellHeight() -> CGFloat {
        
        let tableViewHeight = tableView.frame.size.height
        // Calculat Height of row at section and row 0
        let firstCellHeight = tableView.rectForRow(at: IndexPath.init(row: 0, section: 0)).size.height
        return tableViewHeight - firstCellHeight
    }
}

extension SellerListingBuyerStatusViewController: QRScannerDelegate {
    
    func codeFound(_ string: String?) {
        guard let qrcodeDetails = string else { return }
        
        customNavigationBar.labelTitle.text = LocalizedString("scan_successful", story: .listingdetail)
        customNavigationBar.labelDetailTitle.text = LocalizedString("transaction_recap", story: .listingdetail)
        
        var negotiation = viewModel.selectedNegotiation.value
        negotiation?.transaction?.state = .scanSuccess
        viewModel.selectedNegotiation.accept(negotiation)
        
        if let qrCodeJson = qrcodeDetails.getJsonObject() {
            let code = QRCode.init(dictionary: qrCodeJson)
            if let transactionId = code?.transactionId {
                viewModel.qrcodeDetails.accept((transactionId, QRCode.init(code: code?.code,
                                                                           transactionId: nil)))
            }
        }
    }
}
