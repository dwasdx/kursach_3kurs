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
    
    func openWelcomeScreen(imageData: Data?) {
        let router = WelcomeScreenRouter()
        let vc = WelcomeScreenViewController.initFromItsStoryboard()
        let viewModel = WelcomeScreenViewModel(imageData: imageData)
        router.viewController = vc
        vc.router = router
        vc.viewModel = viewModel
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        viewController?.present(vc, animated: true, completion: nil)
    }
}
