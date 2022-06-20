//
//  FirebaseSession.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/15/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import Firebase
import RxCocoa
import RxSwift
import Wires
import Pushwoosh

enum Role: Int {
    case buyer = 0
    case seller = 1
    var value: String {
        switch self {
        case .buyer:
            return "buyer"
        case .seller:
            return "seller"
        }
    }
}

class FirebaseSession: ReactiveCompatible {
    fileprivate struct Constant {
        static let firebaseVerificationIdKey = "FirebaseVerificationId"
        static let isSignInKey = "FanatickIsSignIn"
        static let firebaseUserToken = "FirebaseUserToken"
        static let fanatickUserToken = "FanatickUserToken"
        static let userRole = "UserRole"
        static let phoneNumberKey = "PhoneNumberKey"
    }
    private init() {}
    
    static let shared = FirebaseSession()
    private let firebaseAuth = Auth.auth()
    fileprivate let event = PublishSubject<String>()
    fileprivate var disposeBag = DisposeBag()
    var user: BehaviorRelay<User?> = BehaviorRelay(value: nil)
    var role: Role {
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Constant.userRole)
            UserDefaults.standard.synchronize()
            event.onNext(Constant.userRole)
        }
        
        get {
            return Role(rawValue: UserDefaults.standard.integer(forKey: Constant.userRole)) ?? .buyer
        }
    }
    
    var isSignIn: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: Constant.isSignInKey)
            UserDefaults.standard.synchronize()
        }
        
        get {
            return UserDefaults.standard.bool(forKey: Constant.isSignInKey)
        }
    }
    var verificationId: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: Constant.firebaseVerificationIdKey)
            UserDefaults.standard.synchronize()
            event.onNext(Constant.firebaseVerificationIdKey)
        }
        
        get {
            return UserDefaults.standard.string(forKey: Constant.firebaseVerificationIdKey)
        }
    }
    private(set) var phoneNumber: String {
        set {
            UserDefaults.standard.set(newValue, forKey: Constant.phoneNumberKey)
            UserDefaults.standard.synchronize()
            event.onNext(Constant.phoneNumberKey)
        }
        
        get {
            return UserDefaults.standard.string(forKey: Constant.phoneNumberKey) ?? ""
        }
    }
    var displayedPhoneNumber: String {
        get {
            return StringFormatter.formattedPhoneNumber(
                StringFormatter.deinternalizedPhoneNumber(phoneNumber)
            )
        }
    }
    var firebaseAuthToken: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: Constant.firebaseUserToken)
            UserDefaults.standard.synchronize()
            event.onNext(Constant.firebaseUserToken)
        }
        
        get {
            return UserDefaults.standard.string(forKey: Constant.firebaseUserToken)
        }
    }
    var fanatickAuthToken: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: Constant.fanatickUserToken)
            UserDefaults.standard.synchronize()
            event.onNext(Constant.fanatickUserToken)
        }
        
        get {
            return UserDefaults.standard.string(forKey: Constant.fanatickUserToken)
        }
    }
    // Use to update phone number
    var updatedPhoneNumber: String? = nil
    var updatedFirebaseToken: String? = nil
    var updatedVerificationId: String? = nil
    var displayedUpdatedPhoneNumber: String {
        get {
            return StringFormatter.formattedPhoneNumber(
                StringFormatter.deinternalizedPhoneNumber(updatedPhoneNumber)
            )
        }
    }
}

// MARK: Firebase Auth
extension FirebaseSession {
    func verifyUpdatePhoneNumber(firebaseToken: String, newPhoneNumber: String) -> Single<Result<String>> {
        return Single.create(subscribe: { (event) -> Disposable in
            self.firebaseAuth.signIn(withCustomToken: firebaseToken, completion: { (result, error) in
                if let error = error {
                    event(.success(Result.error(error)))
                } else {
                    PhoneAuthProvider.provider().verifyPhoneNumber(newPhoneNumber, uiDelegate: nil) { (verificationId, error) in
                        self.updatedPhoneNumber = newPhoneNumber
                        self.updatedFirebaseToken = firebaseToken
                        self.updatedVerificationId = verificationId
                        if error == nil {
                            event(.success(Result.value(verificationId ?? "")))
                        } else {
                            event(.success(Result.error(error!)))
                        }
                    }
                }
            })
            return Disposables.create {  }
        })
    }
    
    func verifyUpdatePhoneNumber(with verificationCode: String) -> Single<Result<Void>> {
        return Single.create(subscribe: { (event) -> Disposable in
            let credential = PhoneAuthProvider
                .provider()
                .credential(withVerificationID: self.updatedVerificationId ?? "", verificationCode: verificationCode)
            Auth.auth().currentUser?.updatePhoneNumber(credential, completion: { (error) in
                if let error = error {
                    event(.success(Result<Void>.error(error)))
                } else {
                    self.phoneNumber = self.updatedPhoneNumber!
                    self.verificationId = self.updatedVerificationId
                    self.firebaseAuthToken = self.updatedFirebaseToken
                    event(.success(Result.value(())))
                }
            })
            return Disposables.create { }
        })
    }
    
    func verifyPhoneNumber(phoneNumber: String) -> Single<Result<String>> {
        self.phoneNumber = phoneNumber
        return Single.create(subscribe: { (event) -> Disposable in
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationId, error) in
                self.verificationId = verificationId
                if error == nil {
                    event(.success(Result.value(verificationId ?? "")))
                } else {
                    self.internalLogout()
                    event(.success(Result.error(error!)))
                }
            }
            return Disposables.create { }
        })
    }
    
    func signInWithVerificationCode(verificationCode: String) -> Single<Result<AuthDataResult>> {
        let credential = PhoneAuthProvider
            .provider()
            .credential(withVerificationID: verificationId ?? "", verificationCode: verificationCode)
        return Single.create(subscribe: { (event) -> Disposable in
            self.firebaseAuth.signIn(with: credential) { (result, error) in
                if error != nil {
                    self.internalLogout()
                    event(.success(Result.error(error!)))
                } else {
                    event(.success(Result.value(result!)))
                }
            }
            return Disposables.create { }
        })
    }
    
    func getToken() -> Single<Result<String>> {
        return Single.create(subscribe: { (event) -> Disposable in
            var observable: Disposable? = nil
            self.firebaseAuth.currentUser?.getIDToken(completion: { (token, error) in
                self.firebaseAuthToken = token
                
                if error == nil {
                    let request = AuthenticationRequest(
                        tokenId: token ?? "",
                        deviceToken: Auth.auth().apnsToken?.hexString ?? "",
                        phoneNumber: self.phoneNumber)
                    observable = NetworkManager.rx.send(request: request, clazz: AuthenticationResponse.self)
                        .map{ $0.token }
                        .subscribe(onSuccess: { (token) in
                            self.fanatickAuthToken = token
                            event(.success(Result.value(token ?? "")))
                        }, onError: { (error) in
                            self.internalLogout()
                            event(.success(Result.error(error)))
                        })
                } else {
                    self.internalLogout()
                    event(.success(Result.error(error!)))
                }
            })
            return Disposables.create {
                observable?.dispose()
            }
        })
    }
    
    func getUserDetail() {
        NetworkManager.rx.send(request: GetUserRequest(), clazz: User.self)
            .subscribe(onSuccess: { (user) in
                self.user.accept(user)
            }) { (_) in }
            .disposed(by: disposeBag)
    }
    
    func logout() {
        user.accept(nil)
        phoneNumber = ""
        firebaseAuthToken = nil
        fanatickAuthToken = nil
        verificationId = nil
        isSignIn = false
        internalLogout()
    }
    
    private func internalLogout() {
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
}

extension Reactive where Base: FirebaseSession {
    var isSignIn: Observable<Bool> {
        return UserDefaults.standard
            .rx
            .observe(Bool.self, FirebaseSession.Constant.isSignInKey)
            .map { $0 ?? false }
    }
    
    var role: Observable<Role> {
        return Observable.create({ (observer) -> Disposable in
            let roleDisposable = self.base.event
                .filter{ $0 == FirebaseSession.Constant.userRole }
                .map{ _ in self.base.role }
                .do(onSubscribe: {
                    observer.onNext(self.base.role)
                })
                .bind(to: observer)
            
            return Disposables.create {
                roleDisposable.dispose()
            }
        })
    }
}
