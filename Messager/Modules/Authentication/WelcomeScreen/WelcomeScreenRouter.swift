//
//  WelcomeScreenRouter.swift
//  Messager
//
//  Created by Андрей Журавлев on 18.04.2021.
//

import UIKit

class WelcomeScreenRouter {
    weak var viewController: UIViewController?
}

extension WelcomeScreenRouter: WelcomeScreenRouting {
    func openTabBarScreen() {
        let router = TabBarRouter()
        let vc = router.tabBar
        viewController?.view.window?.rootViewController = vc
    }
}
