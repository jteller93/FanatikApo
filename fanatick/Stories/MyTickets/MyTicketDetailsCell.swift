//
//  MyTicketDetailsCell.swift
//  fanatick
//
//  Created by Yashesh on 09/07/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import UIKit
import Cartography

class MyTicketDetailsCell: CollectionViewCell {

    let imageView = UIImageView()
    
    override func addSubviews() {
        super.addSubviews()
        
        contentView.addSubview(imageView)
        
        constrain(imageView) { (imageView) in
            imageView.top == imageView.superview!.top
            imageView.bottom == imageView.superview!.bottom
            imageView.leading == imageView.superview!.leading + 29
            imageView.trailing == imageView.superview!.trailing - 29
        }
    }
    
    override func load<VM: ViewModel>(viewModel: VM?, indexPath: IndexPath) {
        guard let viewModel = viewModel as? MyTicketsViewModel else { return }
        super.load(viewModel: viewModel, indexPath: indexPath)
        guard viewModel.tickets.value.count  > 0, let url = viewModel.tickets.value[indexPath.row].ticket?.publicUrl?.absoluteString else { return }
        imageView.setImage(urlString: url)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
    }
}
