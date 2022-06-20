//
//  GeolocationService.swift
//  fanatick
//
//  Created by Yashesh on 28/06/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import RxSwift
import RxCocoa

fileprivate struct Constants {
    static let isTurnOn = "LocationServiceOnKey"
}

protocol GeolocationServiceDelegate: class {
    func openLocationSettingsForApp()
}

extension GeolocationServiceDelegate where Self: ViewController {
    func openLocationSettingsForApp() {
        let alertController = UIAlertController.init(title: nil, message: LocalizedString("turn_on_location_service_to_allow_fanatick_to_determine_your_location"), preferredStyle: .alert)
        
        let okAction = UIAlertAction.init(title: LocalizedString("allow", story: .general), style: .default) { (_) in
            if let bundleId = Bundle.main.bundleIdentifier,
                let url = URL(string: "\(UIApplication.openSettingsURLString)&path=LOCATION/\(bundleId)") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        alertController.addAction(okAction)
        alertController.addAction(UIAlertAction.init(title: LocalizedString("dont_allow", story: .general), style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}

class GeolocationService: NSObject {
    static let shared = GeolocationService()
    fileprivate let locationManager = CLLocationManager()
    fileprivate let disposable = DisposeBag()
    let viewModel = LocationViewModel()
    weak var delegate: GeolocationServiceDelegate? = nil {
        didSet {
            if delegate != nil {
                checkAuthorizationStatus()
            }
        }
    }
    var isTurnOn: Bool {
        get {
            return FirebaseSession.shared.user.value?.locationActive ?? false
        }
    }
    
    override init() {
        super.init()
        
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        
        UserDefaults.standard.register(defaults: [Constants.isTurnOn: true])
        
        FirebaseSession.shared.rx.isSignIn
            .filter{ $0 && self.isTurnOn }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] (on) in
                self?.locationService(enable: on)
            }).disposed(by: disposable)
    }
    
    fileprivate func checkAuthorizationStatus() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            break
        case .denied:
            delegate?.openLocationSettingsForApp()
        case .notDetermined:
            locationManager
                .requestWhenInUseAuthorization()
        case .restricted:
            break
        @unknown default:
            break
        }
    }
    
    func locationService(enable: Bool) {
        enable ? locationManager.startUpdatingLocation() : locationManager.stopUpdatingLocation()
    }
}

extension GeolocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let currentLocationCoordinate = locations.last?.coordinate, isTurnOn else {
            return
        }
        viewModel.locationUpdate.accept(currentLocationCoordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .notDetermined {
            checkAuthorizationStatus()
        } else if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationService(enable: true)
        }
    }
}

