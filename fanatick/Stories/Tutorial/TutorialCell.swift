//
//  TutorialCollectionView.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/11/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cartography
import UIKit

class TutorialCell: CollectionViewCell {
  let stackView = UIStackView()
  let imageView = UIImageView()
  let titleLabel = Label()
  let spacer1 = UIView()
  let spacer2 = UIView()
  let descriptionLabel = Label()
  
  override func addSubviews() {
    super.addSubviews()
    
    addSubview(stackView)
    
    stackView.addArrangedSubview(titleLabel)
    stackView.addArrangedSubview(descriptionLabel)
    stackView.addArrangedSubview(spacer2)
    stackView.addArrangedSubview(imageView)
    
    constrain(imageView, stackView) { imageView, stackView in
      stackView.edges == stackView.superview!.edges
    }
  }
  
  override func applyStylings() {
    super.applyStylings()
    
    stackView.axis = .vertical
    stackView.alignment = .fill
    stackView.distribution = .fill
    stackView.spacing = 16
    
    titleLabel.textColor = .fanatickYellow
    titleLabel.numberOfLines = 0
    titleLabel.textAlignment = .center
    titleLabel.font = UIFont.shFont(size: 32, fontType: .staatliches, weight: .regular)
    
    descriptionLabel.textColor = .fanatickWhite
    descriptionLabel.numberOfLines = 0
    descriptionLabel.textAlignment = .center
    descriptionLabel.font = UIFont.shFont(size: 18, fontType: .staatliches, weight: .regular)
    
    imageView.contentMode = .bottom
  }
  
    override func load<VM: ViewModel>(viewModel: VM?, indexPath: IndexPath) {
        guard let viewModel = viewModel as? TutorialViewModel else { return }
    super.load(viewModel: viewModel, indexPath: indexPath)
    
    let tutorial = viewModel.tutorials[indexPath.row]
    
    imageView.image = tutorial.image
    
    titleLabel.text = tutorial.title
    titleLabel.isHidden = tutorial.title == nil
    
    descriptionLabel.text = tutorial.description
    descriptionLabel.isHidden = tutorial.description == nil
  }
}
