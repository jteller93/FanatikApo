//
//  HomeHeaderCell.swift
//  fanatick
//
//  Created by Vincent Ngo on 5/3/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cartography
import UIKit
import RxCocoa
import RxSwift
import Segmentio

class BuyerHomeHeaderCell: View {
    let backgroundImage = UIImageView()
    let searchView = UISearchBar()
    let titleLabel = Label()
    let segmentio = Segmentio()
    var valueDidChange: ((_ title :String, _ index: Int) -> Void)? = nil
    
    override func setupSubviews() {
        super.setupSubviews()
        
        addSubview(backgroundImage)
        addSubview(searchView)
        addSubview(titleLabel)
        addSubview(segmentio)
        
        constrain(backgroundImage, searchView, titleLabel, segmentio) { backgroundImage, searchView, titleLabel, segmentio in
            backgroundImage.edges == backgroundImage.superview!.edges ~ UILayoutPriority(750)
            backgroundImage.height == backgroundImage.width * 248 / 375
            
            searchView.leading == searchView.superview!.leading + 10
            searchView.trailing == searchView.superview!.trailing - 10
            searchView.height == 40
            
            segmentio.leading == searchView.leading
            segmentio.trailing == searchView.trailing
            segmentio.top == searchView.bottom + 10
            segmentio.height == 24
            segmentio.bottom == searchView.superview!.bottom - 10
            
            titleLabel.bottom == searchView.top - 23
            titleLabel.leading == titleLabel.superview!.leading + 10
            titleLabel.trailing == titleLabel.superview!.trailing - 10
            
        }
    }
    
    override func applyStyling() {
        super.applyStyling()
        
        backgroundImage.image = UIImage(named: "welcome")
        
        titleLabel.text = LocalizedString("home_title", story: .home)
        titleLabel.font = UIFont.shFont(size: 18, fontType: .sfProDisplay, weight: .bold)
        titleLabel.textColor = .fanatickWhite
        titleLabel.numberOfLines = 0
        
        searchView.applyDefaultStyling()
        searchView.placeholder = LocalizedString("search_place_holder")
    }
    
    func setupSegmentio(titles: [String]) {
        var segments = [SegmentioItem]()
        let indicatorOption = SegmentioIndicatorOptions(type: SegmentioIndicatorType.bottom,
                                                        ratio: 0.5,
                                                        height: 1,
                                                        color: .fanatickYellow)
        let states = SegmentioStates(
            defaultState: SegmentioState(
                backgroundColor: .clear,
                titleFont: UIFont.shFont(size: 14, fontType: .helveticaNeue, weight: .regular),
                titleTextColor: .fanatickWhite
            ),
            selectedState: SegmentioState(
                backgroundColor: .clear,
                titleFont: UIFont.shFont(size: 14, fontType: .helveticaNeue, weight: .regular),
                titleTextColor: .fanatickYellow
            ),
            highlightedState: SegmentioState(
                titleFont: UIFont.shFont(size: 14, fontType: .helveticaNeue, weight: .regular),
                titleTextColor: .fanatickYellow
            )
        )
        let option = SegmentioOptions(backgroundColor: .clear,
                                      segmentPosition: SegmentioPosition.dynamic,
                                      scrollEnabled: true,
                                      indicatorOptions: indicatorOption,
                                      horizontalSeparatorOptions: SegmentioHorizontalSeparatorOptions(type: .none,
                                                                                                      height: 0,
                                                                                                      color: .clear),
                                      verticalSeparatorOptions: nil,
                                      labelTextAlignment: .center,
                                      labelTextNumberOfLines: 0,
                                      segmentStates: states)
        titles.forEach { (title) in
            segments.append(SegmentioItem(title: title, image: nil))
        }
        segmentio.setup(content: segments, style: .onlyLabel, options: option)
        segmentio.valueDidChange = { segment, index in
            if let title = segment.segmentioItems[index].title {
                self.valueDidChange?(title, index)
            }
        }
    }
}
