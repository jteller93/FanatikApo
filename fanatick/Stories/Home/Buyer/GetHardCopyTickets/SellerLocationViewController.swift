//
//  SellerLocationViewController.swift
//  fanatick
//
//  Created by Yashesh on 01/07/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import UIKit
import MapKit
import Cartography
import MessageUI

class SellerLocationViewController: ViewController, GeolocationServiceDelegate {
    
    let imageViewSeller = UIImageView()
    let labelName = Label()
    let labelDesription = Label()
    let seperator = View()
    let stackView = UIStackView()
    let buttonCall = Button()
    let buttonText = Button()
    let buttonCancel = Button()
    let mapView = MKMapView()
    let buttonDisplayQrCode = Button()
    let imageSize = CGSize.init(width: 60, height: 60)
    let timerView = TimerView()
    let viewModel = GetHardCopyViewModel()
    var locationService = GeolocationService.shared
    let delta = 0.0275
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationService.delegate = self
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        view.addSubview(imageViewSeller)
        view.addSubview(labelName)
        view.addSubview(labelDesription)
        view.addSubview(seperator)
        view.addSubview(stackView)
        stackView.addArrangedSubview(buttonCall)
        stackView.addArrangedSubview(buttonText)
        stackView.addArrangedSubview(buttonCancel)
        view.addSubview(mapView)
        view.addSubview(buttonDisplayQrCode)
        view.addSubview(timerView)
        
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        
        mapView.delegate = self
        navigationController?.navigationBar.isTranslucent = true
        
        constrain(imageViewSeller, labelName, labelDesription, seperator, mapView, buttonDisplayQrCode, stackView, timerView) { (imageViewSeller, labelName, labelDesription, seperator, mapView, buttonDisplayQrCode, stackView, timerView) in
            imageViewSeller.top == imageViewSeller.superview!.safeAreaLayoutGuide.top - 35
            imageViewSeller.width == imageSize.width
            imageViewSeller.height == imageSize.height
            imageViewSeller.centerX == imageViewSeller.superview!.centerX
            
            labelName.centerX == imageViewSeller.centerX
            labelName.top == imageViewSeller.bottom + 3
            labelDesription.top == labelName.bottom + 4
            labelDesription.centerX == labelName.centerX
            
            seperator.top == labelDesription.bottom + 24
            seperator.leading == seperator.superview!.leading + 19
            seperator.trailing == seperator.superview!.trailing - 19
            seperator.height == 1
            
            stackView.leading == seperator.leading
            stackView.trailing == seperator.trailing
            stackView.height == 54
            stackView.top == seperator.bottom + 13
            
            mapView.bottom == mapView.superview!.bottom
            mapView.leading == mapView.superview!.leading
            mapView.trailing == mapView.superview!.trailing
            mapView.top == seperator.bottom + 71
            
            buttonDisplayQrCode.leading == buttonDisplayQrCode.superview!.leading + 19
            buttonDisplayQrCode.trailing == buttonDisplayQrCode.superview!.trailing - 19
            buttonDisplayQrCode.height == K.Dimen.button
            buttonDisplayQrCode.bottom == buttonDisplayQrCode.superview!.safeAreaLayoutGuide.bottom - 30
            
            timerView.trailing == timerView.superview!.trailing - 20
            timerView.top == mapView.top + 20
            timerView.height == 50
            timerView.width == 94
        }
    }
    
    override func applyStyling() {
        super.applyStyling()
        hasCloseButton = true
        imageViewSeller.layer.cornerRadius = 30
        imageViewSeller.clipsToBounds = true
        imageViewSeller.backgroundColor = .white
        
        if let seller = viewModel.listing.value?.seller {
            labelName.text = "\(seller.firstName ?? "") \(seller.lastName ?? "")"
            imageViewSeller.setImage(urlString: seller.image?.publicUrl?.absoluteString)
        }
        
        labelName.font = UIFont.shFont(size: 18, fontType: .sfProDisplay, weight: .medium)
        labelName.textColor = .fanatickWhite
        
        labelDesription.font = UIFont.shFont(size: 12, fontType: .sfProDisplay, weight: .medium)
        labelDesription.textColor = .fanatickWhite
        
        seperator.backgroundColor = .fanatickWhite
        
        buttonDisplayQrCode.setTitle(LocalizedString("display_my_qr_code", story: .general), for: .normal)
        buttonDisplayQrCode.defaultYellowStyling(fontSize: 16, cornerRadius: K.Dimen.button / 2, borderColor: .fanatickGray_151_151_151)
        
        buttonCall.setImage(UIImage.init(named: "phone"), for: .normal)
        buttonCall.setTitle(LocalizedString("call", story: .general), for: .normal)
        // TODO: Update asset for text
        buttonText.setImage(UIImage.init(named: "comment"), for: .normal)
        buttonText.setTitle(LocalizedString("text", story: .general), for: .normal)
        buttonCancel.setImage(UIImage.init(named: "cancel"), for: .normal)
        buttonCancel.setTitle(LocalizedString("cancel", story: .general), for: .normal)
        
        buttonText.alignTextBelow(leftSpacing: -8)
        buttonCall.alignTextBelow(leftSpacing: -8)
        buttonCancel.alignTextBelow(leftSpacing: -16)
        
        buttonText.setTitleColor(.fanatickWhite, for: .normal)
        buttonCall.setTitleColor(.fanatickWhite, for: .normal)
        buttonCancel.setTitleColor(.fanatickWhite, for: .normal)
        
        buttonText.titleLabel?.font = UIFont.shFont(size: 12, fontType: .sfProDisplay, weight: .medium)
        buttonCall.titleLabel?.font = UIFont.shFont(size: 12, fontType: .sfProDisplay, weight: .medium)
        buttonCancel.titleLabel?.font = UIFont.shFont(size: 12, fontType: .sfProDisplay, weight: .medium)
        
        timerView.layer.cornerRadius = K.Dimen.button / 2
        timerView.backgroundColor = .fanatickGrey
        timerView.clipsToBounds = true
        timerView.layer.borderColor = UIColor.fanatickGray_151_151_151.cgColor
        timerView.layer.borderWidth = 1
        timerView.isHidden = true
        
        mapView.showsUserLocation = true
    }
    
    override func addObservables() {
        super.addObservables()
    
        viewModel.userId.map { [weak self] (_) -> String in
            return self?.viewModel.listing.value?.id ?? ""
        }.bind(to: viewModel.sellerLocationAction).disposed(by: disposeBag)
        
        buttonDisplayQrCode.rx.tap.subscribe(onNext:{ [weak self] _ in
            guard let transactionID = self?.viewModel.listing.value?.transaction?.id else {
                return
            }
            let viewController = GetQRCodeViewController()
            viewController.viewModel.transactionId.accept(transactionID)
            self?.navigationController?.present(viewController, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        viewModel.location.subscribe(onNext:{ [weak self] location in
            guard let location = location else { return }
            self?.addAnnonation(userLocation: location)
        }).disposed(by: disposeBag)
        
        locationService.viewModel.locationUpdate.subscribe(onNext: { [weak self] coordinates in
            self?.setMileLabel(coordinates: coordinates)
        }).disposed(by: disposeBag)
        
        buttonCall.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let phoneNumber = self?.viewModel.phoneNumber.value?.number else { return }
            self?.callSeller(number: phoneNumber)
        }).disposed(by: disposeBag)
        
        buttonText.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let phoneNumber = self?.viewModel.phoneNumber.value?.number else {
                return
            }
            self?.textSeller(number: phoneNumber)
            }).disposed(by: disposeBag)
        
        buttonCancel.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        if let transactionId = viewModel.listing.value?.transaction?.id {
            viewModel.getSellerCallNumber.accept(transactionId)
        }
    }
    
    fileprivate func setMileLabel(coordinates: CLLocationCoordinate2D) {
        
        guard let sellerLocation = self.viewModel.location.value else { return }
        
        let sourceLocaiton = CLLocation.init(latitude: coordinates.latitude,
                                             longitude: coordinates.longitude)
        
        let destinationLocation = CLLocation.init(latitude: sellerLocation.latitude ?? 0.0,
                                                  longitude: sellerLocation.longitude ?? 0.0)
        
        let distance = sourceLocaiton.distance(from: destinationLocation) * K.miles
        
        labelDesription.text = "\(String.init(format: "%.1f", distance)) \(LocalizedString("mi_from_you", story: .general))"
    }
    
    fileprivate func addAnnonation(userLocation: UserLocation?) {
        
        guard let userLocation = userLocation else { return }
        let annotation = ImageAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(userLocation.latitude ?? 0.0,
                                                           userLocation.longitude ?? 0.0)
        annotation.image = UIImage.init(named: "icon_pin")
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
        let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    fileprivate func callSeller(number: String) {
        if let url = URL.init(string: "tel://\(number)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    fileprivate func textSeller(number:String) {
        if MFMessageComposeViewController.canSendText() {
            let messageController = MFMessageComposeViewController()
            messageController.recipients = [number]
            messageController.messageComposeDelegate = self
            present(messageController, animated: true, completion: nil)
        }
    }
}

extension SellerLocationViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: MKUserLocation.self) {  //Handle user location annotation..
            return nil  //Default is to let the system handle it.
        }
        
        var view: ImageAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: "imageAnnotation") as? ImageAnnotationView
        if view == nil {
            view = ImageAnnotationView(annotation: annotation, reuseIdentifier: "imageAnnotation")
        }
        
        let annotation = annotation as! ImageAnnotation
        view?.image = annotation.image
        view?.annotation = annotation
        
        return view
    }
}

class ImageAnnotation : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var image: UIImage?
    
    override init() {
        self.coordinate = CLLocationCoordinate2D()
        self.image = nil
    }
}

class ImageAnnotationView: MKAnnotationView {
    private var imageView: UIImageView!
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        self.frame = CGRect(x: 0, y: 0, width: 29, height: 40)
        self.imageView = UIImageView(frame: CGRect(x: 0, y: -(self.frame.height / 2), width: 29, height: 40))
        self.addSubview(self.imageView)
        
        self.imageView.layer.cornerRadius = 5.0
        self.imageView.layer.masksToBounds = true
    }
    
    override var image: UIImage? {
        get {
            return imageView.image
        }
        
        set {
            imageView.image = newValue
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SellerLocationViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
