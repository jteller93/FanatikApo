//
//  SettingsViewController.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/30/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cartography
import UIKit
import RxCocoa
import RxSwift

class SettingsViewController: ViewController {
    fileprivate struct Constant {
        static let thumbnailHeight: CGFloat = UIScreen.main.bounds.width / 2
    }
    
    
    let viewModel = SettingsViewModel()
    let thumbnail = UIImageView()
    let cameraButton = Button()
    let nameButton = MaterialButton()
    let mobileButton = MaterialButton()
    let sellerLocationTitle = Label()
    let sellerLocationDescription = Label()
    let sellerLocationSwitch = UISwitch()
    
    let memberShipView     = View()
    let memberShipButton   = Button()
    let memberShipTitle = Label()
    let memberShipDescription = Label()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        view.addSubview(thumbnail)
        view.addSubview(cameraButton)
        view.addSubview(nameButton)
        view.addSubview(mobileButton)
        view.addSubview(sellerLocationTitle)
        view.addSubview(sellerLocationDescription)
        view.addSubview(sellerLocationSwitch)
        view.addSubview(memberShipView)
        
        constrain(thumbnail, cameraButton, nameButton, mobileButton, memberShipView, car_topLayoutGuide, car_bottomLayoutGuide) { thumbnail, cameraButton, nameButton, mobileButton, memberShipView, top, bottom  in
            thumbnail.width == Constant.thumbnailHeight
            thumbnail.height == Constant.thumbnailHeight
            thumbnail.top == top.bottom
            thumbnail.centerX == thumbnail.superview!.centerX
            
            cameraButton.trailing == thumbnail.trailing
            cameraButton.bottom == thumbnail.bottom
            cameraButton.width == 40
            cameraButton.height == 40
            
            nameButton.top == thumbnail.bottom + 50
            nameButton.leading == nameButton.superview!.leading + K.Dimen.smallMargin
            nameButton.trailing == nameButton.superview!.trailing - K.Dimen.smallMargin
            
            mobileButton.top == nameButton.bottom + 30
            mobileButton.leading == nameButton.leading
            mobileButton.trailing == nameButton.trailing
            
            memberShipView.bottom  == bottom.top - 20
            memberShipView.leading == memberShipView.superview!.leading + 16
            memberShipView.trailing == memberShipView.superview!.trailing - 16
        }
        
        constrain(mobileButton, sellerLocationTitle, sellerLocationDescription, sellerLocationSwitch) { mobileButton, sellerLocationTitle, sellerLocationDescription, sellerLocationSwitch in
            sellerLocationTitle.top == mobileButton.bottom + 30
            sellerLocationTitle.leading == sellerLocationTitle.superview!.leading + K.Dimen.smallMargin
            sellerLocationTitle.trailing == sellerLocationSwitch.leading
            
            sellerLocationSwitch.top == sellerLocationTitle.top
            sellerLocationSwitch.trailing == sellerLocationSwitch.superview!.trailing - K.Dimen.smallMargin
            
            sellerLocationDescription.top == sellerLocationTitle.bottom + 10
            sellerLocationDescription.leading == sellerLocationTitle.leading
            sellerLocationDescription.trailing == sellerLocationSwitch.leading - 20
        }
        
    
    }
    
    override func applyStyling() {
        super.applyStyling()
        
        hasMenu = true
        
        thumbnail.layer.cornerRadius = Constant.thumbnailHeight / 2
        thumbnail.layer.masksToBounds = true
        cameraButton.setImage(UIImage(named: "icon_camera"), for: .normal)
        nameButton.title = LocalizedString("name:", story: .settings)
        mobileButton.title = LocalizedString("mobile_number:", story: .settings)
        
        sellerLocationTitle.text = LocalizedString("seller_location_title", story: .settings)
        sellerLocationTitle.textColor = .fanatickWhite
        sellerLocationTitle.font = UIFont.shFont(size: 16, fontType: .helveticaNeue, weight: .light)
        
        sellerLocationDescription.text = LocalizedString("seller_location_description", story: .settings)
        sellerLocationDescription.textColor = .white
        sellerLocationDescription.font = UIFont.shFont(size: 10, fontType: .helveticaNeue, weight: .light)
        sellerLocationDescription.numberOfLines = 0
        
        sellerLocationSwitch.onTintColor = .fanatickYellow
        
        memberShipTitle.textColor = .white
        
        memberShipDescription.numberOfLines = 2
    }
    
    override func reapplyStyling() {
        super.reapplyStyling()
        mobileButton.name = FirebaseSession.shared.displayedPhoneNumber
        sellerLocationSwitch.isOn = GeolocationService.shared.isTurnOn
    }
        
    override func addObservables() {
        super.addObservables()
        
        FirebaseSession.shared.user.subscribe(onNext: { [weak self] (user) in
            self?.nameButton.name = "\(user?.firstName ?? "") \(user?.lastName ?? "")"
            if let url = user?.image?.publicUrl?.absoluteString {
                self?.thumbnail.setImage(urlString: url)
            } else {
                self?.thumbnail.image = UIImage.image(color: .fanatickWhite)
            }
            self?.sellerLocationSwitch.isOn = user?.locationActive ?? false
            self?.applyMembershipStyling(subscriber: user?.membership?.proSubscriptionActive ?? false)
        }).disposed(by: disposeBag)
        
        cameraButton.rx.tap
            .subscribe(onNext: { [weak self] (_) in
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                alert.addAction(
                    UIAlertAction(title: LocalizedString("take_photo",
                                                         story: .settings),
                                  style: .default,
                                  handler: { (_) in
                                    self?.takePhotoButtonTapped()
                    })
                )
                alert.addAction(
                    UIAlertAction(title: LocalizedString("choose_from_library",
                                                         story: .settings),
                                  style: .default
                        ,
                                  handler: { (_) in
                                    self?.choosePhotoButtonTapped()
                    })
                )
                alert.addAction(
                    UIAlertAction(title: LocalizedString("cancel"),
                                  style: .cancel,
                                  handler: nil)
                )
                self?.navigationController?.present(alert,
                                                    animated: true,
                                                    completion: nil)
            }).disposed(by: disposeBag)
        
        nameButton.rx.tap
            .subscribe(onNext: { [weak self] (_) in
                self?.navigationController?.pushViewController(EditNameViewController(), animated: true)
            }).disposed(by: disposeBag)
        
        mobileButton.rx.tap
            .subscribe(onNext: { [weak self] (_) in
                self?.navigationController?.pushViewController(EditPhoneInputViewController(), animated: true)
            }).disposed(by: disposeBag)
        
        viewModel.error.filter{ $0 != nil }
            .subscribe(onNext: { [weak self] (error) in
                self?.handleError(error: error!)
            }).disposed(by: disposeBag)
        
        memberShipButton.rx.tap.subscribe(onNext: { [weak self] (_) in
                   self?.navigationController?.pushViewController(MembershipViewController(), animated: true)
               }).disposed(by: disposeBag)
        
        sellerLocationSwitch.rx
            .controlEvent(.valueChanged)
            .withLatestFrom(sellerLocationSwitch.rx.value)
            .subscribe(onNext : { [weak self] bool in
                self?.viewModel.sellerLocationAction.accept(bool)
            }) .disposed(by: disposeBag)
    }
    
    func applyMembershipStyling(subscriber: Bool) {
        memberShipView.subviews.forEach { $0.removeFromSuperview() }
        if subscriber {
            memberShipView.addSubview(memberShipButton)
            memberShipView.addSubview(memberShipTitle)
            memberShipView.addSubview(memberShipDescription)
            constrain(memberShipButton, memberShipTitle, memberShipDescription) {
                memberShipButton, memberShipTitle, memberShipDescription in
                
                memberShipTitle.top == memberShipTitle.superview!.top
                memberShipTitle.leading == memberShipTitle.superview!.leading
                
                memberShipDescription.top ==  memberShipTitle.bottom + 8
                memberShipDescription.leading == memberShipTitle.superview!.leading
                memberShipDescription.bottom == memberShipTitle.superview!.bottom
                
                memberShipButton.trailing == memberShipTitle.superview!.trailing
                memberShipButton.bottom == memberShipTitle.superview!.bottom
            }
            
            memberShipTitle.font = UIFont.shFont(size: 16, fontType: .helveticaNeue, weight: .light)
            memberShipTitle.text = LocalizedString("membership:", story: .settings)
            
            memberShipButton.setImage(UIImage(named: "edit"), for: .normal)
            
            let str = LocalizedString("pro_member", story: .settings)
//            str += "\n(\(LocalizedString("renews", story: .settings)) \("04/15/2019"))"
            let attributedString = NSMutableAttributedString(string: str, attributes: [
                .font: UIFont.shFont(size: 14, fontType: .helveticaNeue, weight: .light),
                .foregroundColor: UIColor(red: 252.0 / 255.0, green: 208.0 / 255.0, blue: 0.0, alpha: 1.0)
            ])
            attributedString.addAttribute(.font, value: UIFont.shFont(size: 20, fontType: .helveticaNeue, weight: .light), range: NSRange(location: 0, length: LocalizedString("pro_member", story: .settings).count))
            
            memberShipDescription.attributedText = attributedString

        } else {
            memberShipView.addSubview(memberShipTitle)
            memberShipView.addSubview(memberShipDescription)
            memberShipView.addSubview(memberShipButton)
            
            constrain(memberShipTitle, memberShipDescription,memberShipButton) {
                      memberShipTitle, memberShipDescription, memberShipButton in
                
                memberShipTitle.top == memberShipTitle.superview!.top
                memberShipTitle.centerX == memberShipTitle.superview!.centerX
                
                memberShipDescription.top ==  memberShipTitle.bottom
                memberShipDescription.centerX == memberShipTitle.superview!.centerX
                memberShipDescription.bottom == memberShipTitle.superview!.bottom
                
                memberShipButton.top      == memberShipTitle.superview!.top
                memberShipButton.leading  == memberShipTitle.superview!.leading
                memberShipButton.trailing == memberShipTitle.superview!.trailing
                memberShipButton.bottom   == memberShipTitle.superview!.bottom
            }
            
            memberShipTitle.font = UIFont.shFont(size: 14, fontType: .helveticaNeue, weight: .regular)
            memberShipTitle.text = LocalizedString("tired_of_buying", story: .settings)
            
            memberShipDescription.textColor = .fanatickYellow
            memberShipDescription.font = UIFont.shFont(size: 20, fontType: .sfProDisplay, weight: .medium)
            memberShipDescription.text = LocalizedString("upgrade_to_pro!", story: .settings)
            
            memberShipButton.setTitle("", for: .normal)
        }
    }
    
    
    @objc func takePhotoButtonTapped() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .camera
        imagePickerController.cameraDevice = .front
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc func choosePhotoButtonTapped() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
}

extension SettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
            let file = UploadFile(type: .image, image: pickedImage, sourceUrl: nil)
            AWSImageUploader.rx.uploadFile(folder: .profile, file: file)
                .do(onCompleted: {
                    ActivityIndicator.shared.stop()
                }, onSubscribed: {
                    ActivityIndicator.shared.start()
                }).subscribe(onNext: { [weak self] (result) in
                    if let error = result.error {
                        self?.handleError(error: error.runtimeError)
                    } else if let value = result.value  {
                        self?.viewModel.uploadedData.accept(value)
                    }
                }).disposed(by: disposeBag)
        }
    }
}
