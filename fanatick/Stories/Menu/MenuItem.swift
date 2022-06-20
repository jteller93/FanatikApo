//
//  MenuItem.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/19/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import UIKit

enum MenuItem {
    case home
    case myTickets
    case notifications
    case settings
    case about
    case wallet
    case tips
    case logout
    
    var item: MenuModel {
        switch self {
        case .home:
            return MenuModel(unselectedIcon: UIImage(named: "home_unselected")!,
                            selectedIcon: UIImage(named: "home_selected")!,
                            title: LocalizedString("home", story: .menu))
        case .myTickets:
            return MenuModel(unselectedIcon: UIImage(named: "my_tickets_unselected")!,
                            selectedIcon: UIImage(named: "my_tickets_selected")!,
                            title: LocalizedString("my_tickets", story: .menu))
        case .notifications:
            return MenuModel(unselectedIcon: UIImage(named: "notifications_unselected")!,
                             selectedIcon: UIImage(named: "notifications_selected")!,
                            title: LocalizedString("notifications", story: .menu))
        case .settings:
            return MenuModel(unselectedIcon: UIImage(named: "settings_unselected")!,
                            selectedIcon: UIImage(named: "settings_selected")!,
                            title: LocalizedString("settings", story: .menu))
        case .about:
            return MenuModel(unselectedIcon: UIImage(named: "about_unselected")!,
                            selectedIcon: UIImage(named: "about_selected")!,
                            title: LocalizedString("about", story: .menu))
        case .tips:
            return MenuModel(unselectedIcon: UIImage(named: "tips_unselected")!,
            selectedIcon: UIImage(named: "tips_selected")!,
            title: LocalizedString("tips", story: .menu))
        case .wallet:
            return MenuModel(unselectedIcon: UIImage(named: "withdraw_unselected")!,
                            selectedIcon: UIImage(named: "withdraw_selected")!,
                            title: LocalizedString("wallet", story: .menu))
            
        case .logout:
            return MenuModel(unselectedIcon: UIImage(named: "logout_unselected")!,
                             selectedIcon: UIImage(named: "logout_selected")!,
                             title: LocalizedString("logout", story: .menu))
        }
    }
    
    static func items(for role: Role) -> [MenuItem] {
        var items: [MenuItem] = [
            .home,
            .myTickets,
            .notifications,
            .settings,
            .about
        ]
        if role == .seller {
            items.append(.wallet)
        }
        items.append(.tips)
        items.append(.logout)
        return items
    }
}

struct MenuModel {
    var unselectedIcon: UIImage
    var selectedIcon: UIImage
    var title: String
}
