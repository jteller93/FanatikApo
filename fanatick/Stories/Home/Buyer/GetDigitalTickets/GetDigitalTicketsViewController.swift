//
//  GetDigitalTicketsViewController.swift
//  fanatick
//
//  Created by Yashesh on 28/06/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Cartography
import SideMenu

class GetDigitalTicketsViewController: ViewController {

    let labelDescription = Label()
    let imageView = UIImageView()
    let buttonDownload = Button()
    let buttonNotNow = Button()
    let imageSize = CGSize.init(width: 144, height: 166)
    let imageTickSize = CGSize.init(width: 109, height: 86.4)
    var downloadCompletedView = View()
    let imageViewTick = UIImageView()
    let labelDownloadcomplete = Label()
    let viewModel = DigitalTicketViewModel()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        view.addSubview(labelDescription)
        view.addSubview(imageView)
        view.addSubview(buttonDownload)
        view.addSubview(buttonNotNow)
        navigationController?.view.addSubview(downloadCompletedView)
        downloadCompletedView.addSubview(imageViewTick)
        downloadCompletedView.addSubview(labelDownloadcomplete)
        
        constrain(labelDescription, imageView, buttonDownload, buttonNotNow) { (labelDescription, imageView, buttonDownload, buttonNotNow) in
            labelDescription.leading == labelDescription.superview!.leading + 42
            labelDescription.trailing == labelDescription.superview!.trailing - 42
            labelDescription.top == labelDescription.superview!.top + 42
            
            imageView.height == imageSize.height
            imageView.width == imageSize.width
            imageView.centerX == imageView.superview!.centerX
            imageView.centerY == imageView.superview!.centerY
            
            buttonDownload.leading == buttonDownload.superview!.leading + K.Dimen.smallMargin
            buttonDownload.trailing == buttonDownload.superview!.trailing - K.Dimen.smallMargin
            buttonDownload.height == K.Dimen.button
            buttonDownload.bottom == buttonDownload.superview!.safeAreaLayoutGuide.bottom - 74
            
            buttonNotNow.leading == buttonDownload.leading
            buttonNotNow.trailing == buttonDownload.trailing
            buttonNotNow.top == buttonDownload.bottom
            buttonNotNow.height == buttonDownload.height
        }
        
        downloadCompletedView.frame = view.bounds
        
        constrain(imageViewTick, labelDownloadcomplete) { (imageViewTick, labelDownloadcomplete) in
            
            imageViewTick.height == imageTickSize.height
            imageViewTick.width == imageTickSize.width
            imageViewTick.centerX == imageViewTick.superview!.centerX
            imageViewTick.centerY == imageViewTick.superview!.centerY - imageTickSize.height
            
            labelDownloadcomplete.centerX == labelDownloadcomplete.superview!.centerX
            labelDownloadcomplete.top == imageViewTick.bottom + K.Dimen.largeMargin
        }
    }
    
    override func applyStyling() {
        super.applyStyling()
        
        hasCloseButton = true
        
        labelDescription.font = UIFont.shFont(size: 16, fontType: .helveticaNeue, weight: .regular)
        labelDescription.textColor = .fanatickWhite
        labelDescription.textAlignment = .center
        labelDescription.numberOfLines = 0
        labelDescription.text = LocalizedString("your_purchase_is_complete_go_to_my_tickets_to_view_your_tickets_or_download_them_to_your_device_below", story: .general)
        
        imageView.image = UIImage.init(named: "icon_download")
        
        buttonDownload.defaultYellowStyling(fontSize: 16, cornerRadius: K.Dimen.button / 2)
        buttonDownload.setTitle(LocalizedString("download_tickets", story: .general), for: .normal)
        
        buttonNotNow.setTitle(LocalizedString("not_now", story: .general), for: .normal)
        buttonNotNow.titleLabel?.font = UIFont.shFont(size: 16, fontType: .helveticaNeue, weight: .regular)
        buttonNotNow.setTitleColor(.fanatickWhite, for: .normal)
        
        downloadCompletedView.backgroundColor = .fanatickblack_alpa_70
        downloadCompletedView.alpha = 0
        
        imageViewTick.image = UIImage.init(named: "checkIconWhite")
        
        labelDownloadcomplete.font = UIFont.shFont(size: 24, fontType: .helveticaNeue, weight: .regular)
        labelDownloadcomplete.textColor = .fanatickWhite
        labelDownloadcomplete.textAlignment = .center
        labelDownloadcomplete.numberOfLines = 0
        labelDownloadcomplete.text = LocalizedString("download_completed", story: .general)
    }
    
    override func addObservables() {
        super.addObservables()
        
        buttonDownload.rx.tap.subscribe(onNext: { [weak self] in
            self?.downloadAllTickets()
        }).disposed(by: disposeBag)
        
        buttonNotNow.rx.tap.subscribe(onNext: { [weak self] in
            self?.dismissButtonTapped()
        }).disposed(by: disposeBag)
        
        viewModel.downloadedTickets.subscribe(onNext:{ [weak self] tickets in
            guard let tickets = tickets, tickets.count > 0 else {
                return
            }
            self?.displayDownloadCopmletedPopup(tickets: tickets)
        }).disposed(by: disposeBag)
    }
    
    
    fileprivate func displayDownloadCopmletedPopup(tickets: [Any]) {
        
        downloadCompletedView.transform = CGAffineTransform.init(scaleX: 1.5, y: 1.5)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.showDownloadCompletedviewAlpha()
            self.downloadCompletedView.transform = CGAffineTransform.identity
            UIActivityViewController.openActivityViewController(vc: self, items: tickets)
        }) { (completion) in
            UIView.animate(withDuration: 0.3, delay: 5, animations: {
                self.showDownloadCompletedviewAlpha()
            }, completion: nil)
        }
    }
    
    fileprivate func showDownloadCompletedviewAlpha() {
        downloadCompletedView.alpha = downloadCompletedView.alpha == 1 ? 0 : 1
    }
    
    override func dismissButtonTapped() {
        if viewModel.transactions.value?.rating == nil {
            let viewController = RateSellerViewController()
            viewController.viewModel.listing.accept(self.viewModel.listing.value)
            let controller = NavigationController(rootViewController: viewController)
            navigationController?.present(controller, animated: true, completion: nil)
        } else {
            super.dismissButtonTapped()
        }
    }
    
    fileprivate func downloadAllTickets() {
        guard let listID = viewModel.listing.value?.id else {
            return
        }
        viewModel.downloadTickets.accept(listID)
    }
}
