//
//  MyTicketsDetailsViewController.swift
//  fanatick
//
//  Created by Yashesh on 09/07/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import UIKit
import Cartography
import RxSwift
import RxCocoa

class MyTicketsDetailsViewController: ViewController {
    
    let viewModel = MyTicketsViewModel()
    let buttonDownload = Button()
    let pageControl = UIPageControl()
    let collectionView = UICollectionView(frame: .zero,
                                          collectionViewLayout: UICollectionViewFlowLayout()
                                            .apply({ (layout) in
                                                layout.scrollDirection = .horizontal
                                                layout.minimumLineSpacing = 0.0;
                                                layout.minimumInteritemSpacing = 0.0;
                                            }))
    
    override func setupSubviews() {
        super.setupSubviews()
        
        MyTicketDetailsCell.registerCell(collectionView: collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(buttonDownload)
        view.addSubview(pageControl)
        view.addSubview(collectionView)
        
        constrain(buttonDownload, pageControl, collectionView) { (buttonDownload, pageControl, collectionView) in
            buttonDownload.leading == buttonDownload.superview!.leading + 16
            buttonDownload.trailing == buttonDownload.superview!.trailing - 16
            buttonDownload.height == K.Dimen.button
            buttonDownload.bottom == buttonDownload.superview!.safeAreaLayoutGuide.bottom - 17
            
            pageControl.centerX == buttonDownload.centerX
            pageControl.bottom == buttonDownload.top
            
            collectionView.top == collectionView.superview!.top
            collectionView.bottom == pageControl.top
            collectionView.leading == collectionView.superview!.leading
            collectionView.trailing == collectionView.superview!.trailing
            
        }
    }
    
    override func applyStyling() {
        super.applyStyling()
        
        hasCloseButton = true
        
        buttonDownload.defaultYellowStyling(fontSize: 16,
                                            cornerRadius: K.Dimen.button / 2)
        buttonDownload.setTitle(LocalizedString("download_tickets", story: .general), for: .normal)
        
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .clear
    }
    
    override func addObservables() {
        super.addObservables()
        
        viewModel.selectedListing.map { (listing) -> String in
            return listing?.id ?? ""
        }.bind(to: viewModel.downloadTickets).disposed(by: disposeBag)
        
        buttonDownload.rx.tap.subscribe(onNext: { [weak viewModel] _ in
            guard viewModel?.tickets.value.count ?? 0 > 0 else {
                return
            }
            ActivityIndicator.shared.start()
            // tickets will be accepted here when get from my tickets list.
            viewModel?.ticketsToDownlaod.accept(viewModel?.tickets.value ?? [])
        }).disposed(by: disposeBag)
        
        viewModel.downloadedTickets.subscribe(onNext: { [weak self] tickets in
            guard let tickets = tickets, tickets.count > 0 else { return }
            self?.showDownloadCompletedPopup(tickets: tickets)
        }).disposed(by: disposeBag)
        
        
        collectionView.rx.didEndDecelerating.subscribe(onNext: { [weak self] _ in
            guard let visibleCell = self?.collectionView.visibleCells.first else { return }
            guard let indexPath = self?.collectionView.indexPath(for: visibleCell) else { return }
            self?.pageControl.currentPage = indexPath.row
        }).disposed(by: disposeBag)
        
        viewModel.tickets.subscribe(onNext: { [weak self] tickets in
            self?.collectionView.reloadData()
            self?.pageControl.numberOfPages = tickets.count
        }).disposed(by: disposeBag)
    }
    
    fileprivate func showDownloadCompletedPopup(tickets: [Any]) {
        let confirmationView = ConfirmationView()
        navigationController?.view.addSubview(confirmationView)
        DispatchQueue.main.async {
            confirmationView.frame = self.navigationController?.view.bounds ?? .zero
        }
        confirmationView.setText(string: LocalizedString("download_completed", story: .general))
        confirmationView.dismissPopup {
            UIActivityViewController.openActivityViewController(vc: self, items: tickets)
        }
    }
}

extension MyTicketsDetailsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.tickets.value.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = MyTicketDetailsCell.dequeueCell(collectionView: collectionView, indexPath: indexPath) {
            cell.load(viewModel: viewModel, indexPath: indexPath)
            return cell
        }
        return UICollectionViewCell()
    }
}

extension MyTicketsDetailsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
}
