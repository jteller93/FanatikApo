//
//  IAPSession.swift
//  fanatick
//
//  Created by Essam on 1/8/20.
//  Copyright © 2020 Fanatick. All rights reserved.
//

import RxCocoa
import RxSwift
import StoreKit

struct FanaticMemberShip {
    static let ProSubscription = "MONTHLYPROSUBSCRIPTION"
    static let Manage = "https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions"
}

class IAPHelper: NSObject {
    // MARK:  Rx
    var product =  BehaviorSubject<SKProduct?>(value: nil)
    var receipt =  BehaviorSubject<Data>(value: Data())
    var error = BehaviorSubject<Error?>(value: nil)
    
    fileprivate var currentTransaction: SKPaymentTransaction?
    fileprivate var disposeBag = DisposeBag()
    
    private let productRequest = SKProductsRequest(productIdentifiers: [FanaticMemberShip.ProSubscription])
    
    var isEligible: Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    override init() {
        super.init()
        productRequest.delegate = self
        productRequest.start()
    }
}

// MARK: IAP Methods
extension IAPHelper {
    public func subscribe() {
        SKPaymentQueue.default().add(self)
        product.filter{ $0 != nil }
            .take(1)
            .map({ (product) -> Void in
                let payment =  SKPayment(product: product!)
                SKPaymentQueue.default().add(payment)
            })
            .catchError{ _ in Observable.empty() }
            .subscribe(onNext: { _ in})
            .disposed(by: disposeBag)
    }
    
    public func finalizeSubscription() {
        if let currentTransaction = currentTransaction {
            SKPaymentQueue.default().finishTransaction(currentTransaction)
        }
    }
}

// MARK: IAP SKProductsRequestDelegate
extension IAPHelper: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        for p in response.products {
            debugPrint("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
        }
        if let product = response.products.first {
            self.product.onNext(product)
        }
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        debugPrint("Error: \(error.localizedDescription)")
        self.error.onNext(error)
    }
}


// MARK: IAP SKPaymentTransactionObserver
extension IAPHelper: SKPaymentTransactionObserver {
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchased:
                completed(transaction: transaction)
                break
            case .failed:
                failed(transaction: transaction)
                break
            case .restored:
                restored(transaction: transaction)
                break
            case .deferred:
                break
            case .purchasing:
                break
            @unknown default:
                break
            }
        }
    }
    
    private func completed(transaction: SKPaymentTransaction) {
        if let error = transaction.error {
            self.error.onNext(error)
            SKPaymentQueue.default().finishTransaction(transaction)
            return
        }
        if let receiptUrl = Bundle.main.appStoreReceiptURL,
            let receiptData = try? Data(contentsOf: receiptUrl) {
            self.currentTransaction = transaction
            self.receipt.onNext(receiptData)
        }
    }
    
    private func restored(transaction: SKPaymentTransaction) {
        if let error = transaction.error {
            self.error.onNext(error)
            SKPaymentQueue.default().finishTransaction(transaction)
            return
        }
        guard let _ = transaction.original?.payment.productIdentifier else { return }
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func failed(transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
        self.error.onNext(transaction.error)
    }
}

extension Error {
    func isSKPaymentCanceled() -> Bool {
        if let skError = self as? SKError, skError.code == .paymentCancelled {
            return true
        }
        return false
    }
}
