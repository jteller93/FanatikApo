//
//  GetQRCodeViewController.swift
//  fanatick
//
//  Created by Yashesh on 02/07/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import UIKit
import Cartography
import RxSwift
import RxCocoa

class GetQRCodeViewController: ViewController {
    
    let closeButton = Button()
    let imageView = UIImageView()
    let labelName = UILabel()
    let imageViewQRCode = UIImageView()
    let imageViewSize = CGSize.init(width: 85, height: 85)
    let viewModel = GetQrCodeViewModel()

    override func setupSubviews() {
        super.setupSubviews()
        
        view.addSubview(closeButton)
        view.addSubview(imageView)
        view.addSubview(labelName)
        view.addSubview(imageViewQRCode)
        
        constrain(closeButton, imageView, labelName, imageViewQRCode) { (closeButton, imageView, labelName, imageViewQRCode) in
            closeButton.top == closeButton.superview!.top + K.Dimen.topPadding + 3
            closeButton.trailing == closeButton.superview!.trailing - 10
            closeButton.height == 40
            closeButton.width == 40
            
            imageView.width == imageViewSize.width
            imageView.height == imageViewSize.height
            imageView.centerX == imageView.superview!.centerX
            imageView.top == closeButton.bottom + 30
            
            labelName.centerX == imageView.centerX
            labelName.top == imageView.bottom + 12
            
            imageViewQRCode.leading == imageViewQRCode.superview!.leading + 30
            imageViewQRCode.trailing == imageViewQRCode.superview!.trailing - 30
            imageViewQRCode.top == labelName.bottom + 50
            imageViewQRCode.bottom <= imageViewQRCode.superview!.bottom - 50
        }
    }
    
    override func applyStyling() {
        super.applyStyling()
        
        view.backgroundColor = .fanatickWhite
        hasCloseButton = true
        closeButton.setImage(UIImage.init(named: "icon_close_black"), for: .normal)
        
        imageView.layer.cornerRadius = imageViewSize.height / 2
        imageView.clipsToBounds = true
        imageView.backgroundColor = .fanatickBlack
        
        labelName.font = UIFont.shFont(size: 20, fontType: .helveticaNeue, weight: .light)
        labelName.textColor = .fanatickGrey
        
        imageViewQRCode.contentMode = .scaleAspectFit
    }
    
    override func addObservables() {
        super.addObservables()
        
        viewModel.transactionId.map { (transactionID) -> String in
            return transactionID ?? ""
        }.bind(to: viewModel.qrCodeAction).disposed(by: disposeBag)
        
        FirebaseSession.shared.user.subscribe(onNext: { [weak self] (user) in
            self?.labelName.text = "\(user?.firstName ?? "") \(user?.lastName ?? "")"
            if let url = user?.image?.publicUrl?.absoluteString {
                self?.imageView.setImage(urlString: url)
            } else {
                self?.imageView.image = UIImage.image(color: .fanatickWhite)
            }
        }).disposed(by: disposeBag)
        
        viewModel.qrCode.subscribe(onNext: { [weak self] (qrCode) in
            guard var qrCode = qrCode, let transactionId = self?.viewModel.transactionId.value  else { return }
            qrCode.transactionId = transactionId
            guard let qrCodeString = qrCode.getString() else { return }
            self?.imageViewQRCode.image = UIImage.generateQRcode(qrCodeString: qrCodeString)
        }).disposed(by: disposeBag)
        
        closeButton.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }
}
