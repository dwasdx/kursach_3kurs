//
//  ProfileRouter.swift
//  Messager
//
//  Created by Андрей Журавлев on 02.03.2021.
//

import UIKit
import SwiftUI

protocol ProfileRouting: BaseRouting {
    func presentProfileViewController(_ completion: (() -> Void)?)
    
    func openEditProfile(userObject: UserObject)
}

class ProfileRouter: BaseRouter {
    
}

extension ProfileRouter: ProfileRouting {
    func presentProfileViewController(_ completion: (() -> Void)?) {
        let view = ProfileViewController()
        view.router = self
        let vc = UIHostingController<ProfileViewController>(rootView: view)
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().backgroundColor = .secondarySystemBackground
        navigationController.navigationBar.isHidden = true
        navigationController.pushViewController(vc, animated: false, completion)
    }
    
    func openEditProfile(userObject: UserObject) {
        let vc = EditProfileViewController.initFromItsStoryboard()
        let router = EditProfileRouter()
        router.viewController = vc
        vc.router = router
        vc.viewModel = EditProfileViewModel(userObject: userObject)
        navigationController.pushViewController(vc, animated: true)
    }
}
