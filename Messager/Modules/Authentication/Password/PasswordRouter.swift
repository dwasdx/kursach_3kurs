//
//  PasswordRouter.swift
//  Messager
//
//  Created by Андрей Журавлев on 12.04.2021.
//

import UIKit

class PasswordRouter {
    weak var viewController: UIViewController?
}

extension PasswordRouter: PasswordRouting {
    func openTabBarScreen() {
        let router = TabBarRouter()
        let vc = router.tabBar
        viewController?.view.window?.rootViewController = vc
    }
    
    func openCreateProfileScreen(userObject: UserObject?) {
        let router = CreateProfileRouter()
        let vc = CreateProfileViewController.initFromItsStoryboard()
        let viewModel = CreateProfileViewModel(userObject: userObject)
        vc.router = router
        vc.viewModel = viewModel
        router.viewController = vc
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
}
