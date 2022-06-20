//
//  DigitalTicketCell.swift
//  fanatick
//
//  Created by Yashesh on 03/06/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import UIKit
import Cartography
import RxSwift

class DigitalTicketCell: TableViewCell {

    let labelSeatNumber = Label()
    let buttonUpload    = Button()
    let imageTick       = UIImageView()
    
    override func addSubviews() {
        super.addSubviews()
        
        addSubview(labelSeatNumber)
        addSubview(buttonUpload)
        addSubview(imageTick)
        
        constrain(labelSeatNumber, buttonUpload, imageTick) { (labelSeatNumber, buttonUpload, imageTick) in
            
            labelSeatNumber.centerY == labelSeatNumber.superview!.centerY
            labelSeatNumber.leading == labelSeatNumber.superview!.leading + 40
            
            
            buttonUpload.trailing == buttonUpload.superview!.trailing - 62
            buttonUpload.top == buttonUpload.superview!.top + 14
            buttonUpload.bottom == buttonUpload.superview!.bottom - 14
            buttonUpload.height == 31
            buttonUpload.width == 80
            
            imageTick.width == 17
            imageTick.height == 13
            imageTick.leading == buttonUpload.trailing + 17
            imageTick.centerY == buttonUpload.centerY
        }
    }
    
    override func applyStylings() {
        super.applyStylings()

        labelSeatNumber.text = "Seat 0"
        labelSeatNumber.font = UIFont.shFont(size: 16, fontType: .helveticaNeue, weight: .regular)
        labelSeatNumber.textColor = .fanatickWhite
        
        buttonUpload.setTitle("Upload", for: UIControl.State.normal)
        buttonUpload.defaultWhiteStyling(fontSize: 16, cornerRadius: 15.5, borderColor: .fanatickGray_151_151_151)
        
        imageTick.image = UIImage.init(named: "check")
        imageTick.isHidden = true
    }
    
    override func load<VM: ViewModel>(viewModel: VM?, indexPath: IndexPath) {
        guard let viewModel = viewModel as? AddTicketInfoViewModel else { return }
        super.load(viewModel: viewModel, indexPath: indexPath)
        
        if let ticket = viewModel.ticketListing.value?.tickets?[indexPath.row] {
            
            labelSeatNumber.text = "\(LocalizedString("seat", story: .ticketinfo)) \(ticket.seat ?? "")"
            
            if ticket.ticketUpload?.publicUrl == nil {
                setUpUploadButton(tickHide: true, title: LocalizedString("upload", story: .ticketinfo))
            } else {
                setUpUploadButton(tickHide: false , title: LocalizedString("change", story: .ticketinfo))
            }
            addobserverForUloadButton(viewModel: viewModel)
        }
    }
    
    fileprivate func setUpUploadButton(tickHide: Bool, title: String) {
        imageTick.isHidden = tickHide
        tickHide == true ? buttonUpload.defaultWhiteStyling(fontSize: 15, cornerRadius: 15.5, borderColor: .fanatickGray_151_151_151) : buttonUpload.defaultYellowStyling(fontSize: 15, cornerRadius: 15.5, borderColor: .fanatickGray_151_151_151)
        buttonUpload.setTitle(title, for: UIControl.State.normal)
    }
    
    fileprivate func addobserverForUloadButton(viewModel: AddTicketInfoViewModel?) {
        
        buttonUpload.rx.tap.subscribe({ [weak self] _ in
            guard let `self` = self else { return }
            viewModel?.ticketIndexPath.accept(self.indexPath)
        }).disposed(by: disposeBag)
        
        viewModel?.uploadAction.map{ [weak viewModel] (indexPath, ticketData) -> Listing? in
            guard let indexPath = indexPath else { return nil }
            guard let viewModel = viewModel else { return nil }
            var listing = viewModel.ticketListing.value
            if listing == nil, listing?.tickets == nil { return nil }
            var ticket = listing!.tickets![indexPath.row]
            let image = TicketImage.init(key: ticketData?.0, bucket: ticketData?.1)
            ticket.ticketUpload = image
            listing!.tickets![indexPath.row] = ticket
            return listing
            }.filter{ $0 != nil }.bind(to: viewModel!.ticketListing)
            .disposed(by: disposeBag)
    }
}
