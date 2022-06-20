//
//  TutorialViewController.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/11/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cartography
import UIKit
import ActiveLabel

class TutorialViewController: ViewController {
    var viewModel: TutorialViewModel = TutorialViewModel()
    
    class func showIfNeeded(sender: ViewController) {
        if !AppData.shared.didShowTutorial {
            let viewController =  NavigationController(rootViewController: TutorialViewController())
            sender.present(viewController, animated: true, completion: nil)
            AppData.shared.didShowTutorial = true
        }
    }
    
    let getStartedButton = Button()
    let collectionView = UICollectionView(frame: .zero,
                                          collectionViewLayout: UICollectionViewFlowLayout().apply({ (flowLayout) in
                                            flowLayout.scrollDirection = .horizontal
                                          }))
    let pageControl = UIPageControl()
    let termLabel = ActiveLabel()
    let termCustomType = ActiveType.custom(pattern: LocalizedString("terms_of_service_regex", story: .tutorial))
    let privacyCustomType = ActiveType.custom(pattern: LocalizedString("privacy_policy_regex", story: .tutorial))

  override func viewDidLoad() {
    super.viewDidLoad()
      hasCloseButton = true
  }
    override func setupSubviews() {
        super.setupSubviews()
        
        TutorialCell.registerCell(collectionView: collectionView)
        
        view.addSubview(collectionView)
        view.addSubview(getStartedButton)
        view.addSubview(pageControl)
        view.addSubview(termLabel)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        constrain(collectionView, getStartedButton, pageControl, termLabel, car_topLayoutGuide, car_bottomLayoutGuide) {
            collectionView, getStartedButton, pageControl, termLabel, top, bottom in
            collectionView.top == top.bottom
            collectionView.leading == collectionView.superview!.leading 
            collectionView.trailing == collectionView.superview!.trailing
            
            pageControl.top == collectionView.bottom + 10
            pageControl.centerX == pageControl.superview!.centerX
            pageControl.bottom == getStartedButton.top - 10
            
            getStartedButton.height == K.Dimen.button
            getStartedButton.leading == getStartedButton.superview!.leading + K.Dimen.smallMargin
            getStartedButton.trailing == getStartedButton.superview!.trailing - K.Dimen.smallMargin
            
            termLabel.centerX == termLabel.superview!.centerX
            termLabel.bottom == bottom.top - 20
            termLabel.top == getStartedButton.bottom + 20
        }
    }
    
    override func applyStyling() {
        super.applyStyling()
        
        collectionView.apply{
            $0.isPagingEnabled = true
            $0.showsHorizontalScrollIndicator = false
            $0.showsVerticalScrollIndicator = false
            $0.backgroundColor = .fanatickGrey
        }
        
        termLabel.apply {
            $0.enabledTypes = [termCustomType, privacyCustomType]
            $0.customColor[termCustomType] = .fanatickLightGrey
            $0.customColor[privacyCustomType] = .fanatickLightGrey
            $0.numberOfLines = 2
            $0.textAlignment = .center
            $0.textColor = .fanatickLightGrey
            $0.font = UIFont.shFont(size: 12,
                                           fontType: .helveticaNeue,
                                           weight: .light)
            $0.highlightFontSize = 14
            $0.configureLinkAttribute = { (type, attributes, isSelected) in
                var attrs = attributes
                switch type {
                case self.privacyCustomType, self.termCustomType:
                    attrs[NSAttributedString.Key.font] = UIFont.shFont(size: 12,
                                                                       fontType: .helveticaNeue,
                                                                       weight: .medium)
                default: ()
                }
                return attrs
            }
            $0.text = LocalizedString("terms", story: .tutorial)
        }
        
        
        pageControl.currentPageIndicatorTintColor = .fanatickYellow
        pageControl.pageIndicatorTintColor = .fanatickLightGrey
        
        getStartedButton.defaultYellowStyling(cornerRadius: K.Dimen.button / 2, borderColor: .fanatickLightGrey)
        getStartedButton.setTitle(LocalizedString("get_started", story: .tutorial), for: .normal)
    }
    
    override func addObservables() {
        super.addObservables()
        
        getStartedButton.rx.tap.subscribe(onNext: { [weak self] (_) in
            self?.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        termLabel.handleCustomTap(for: termCustomType) { (_) in
            UIApplication.shared.open(URL(string: K.URL.termOfUseUrl)!,
                                      options: [:],
                                      completionHandler: nil)
        }
        
        termLabel.handleCustomTap(for: privacyCustomType) { (_) in
            UIApplication.shared.open(URL(string: K.URL.privacyUrl)!,
                                      options: [:],
                                      completionHandler: nil)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
    }
}

extension TutorialViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = viewModel.tutorials.count
        pageControl.numberOfPages = count
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = TutorialCell.dequeueCell(collectionView: collectionView, indexPath: indexPath) {
            cell.load(viewModel: viewModel, indexPath: indexPath)
            return cell
        }
        return UICollectionViewCell()
    }
}

extension TutorialViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height - 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
}
