//
//  AuthenticationRouter.swift
//  Messager
//
//  Created by Андрей Журавлев on 12.04.2021.
//

import UIKit

class AuthenticationRouter {
    weak var viewController: UIViewController?
}

extension AuthenticationRouter: AuthenticationRouting {
    func openContinueAsScreen() {
        let router = PasswordRouter()
        let viewModel = PasswrodViewModel()
        let vc = PasswordViewController.initFromItsStoryboard()
        vc.router = router
        router.viewController = vc
        vc.viewModel = viewModel
        
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func openCreateProfileScreen() {
        
    }
}
