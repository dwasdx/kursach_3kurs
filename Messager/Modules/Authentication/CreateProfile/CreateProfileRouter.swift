//
//  CreateProfileRouter.swift
//  Messager
//
//  Created by Андрей Журавлев on 14.04.2021.
//

import UIKit

class CreateProfileRouter {
    weak var viewController: UIViewController?
}

extension CreateProfileRouter: CreateProfileRouting {
    func openTabBarScreen() {
        let router = TabBarRouter()
        let vc = router.tabBar
        viewController?.view.window?.rootViewController = vc
    }
}
