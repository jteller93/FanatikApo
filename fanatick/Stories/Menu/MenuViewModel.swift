//
//  MenuViewModel.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/19/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class MenuViewModel: ViewModel {
    static let shared = MenuViewModel()
    
    let role = BehaviorRelay<Role>(value: .buyer)
    let items = BehaviorRelay<[MenuItem]>(value: [])
    let selectedItem = BehaviorRelay<MenuItem>(value: .home)
    
    // MARK: Action
    let selectAction = PublishRelay<MenuItem>()
    let refreshAction = PublishRelay<()>()
    
    private override init() {
        super.init()
        
        FirebaseSession.shared.rx.role.bind(to: role)
            .disposed(by: disposeBag)
        
        role.distinctUntilChanged()
            .subscribe(onNext: { (role) in
                FirebaseSession.shared.role = role
            }).disposed(by: disposeBag)
        
        role.distinctUntilChanged()
            .map{ MenuItem.items(for: $0) }
            .bind(to: items)
            .disposed(by: disposeBag)
        
        items.map{ _ in () }
            .bind(to: refreshAction)
            .disposed(by: disposeBag)
        
        selectedItem
            .distinctUntilChanged()
            .map{ _ in () }
            .bind(to: refreshAction)
            .disposed(by: disposeBag)
        
        selectAction
            .filter { (item) -> Bool in
                return item != MenuItem.wallet && item != MenuItem.tips
        }.bind(to: selectedItem)
        .disposed(by: disposeBag)
    }
}
