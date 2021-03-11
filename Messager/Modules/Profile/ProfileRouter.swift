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
}

class ProfileRouter: BaseRouter {
    
}

extension ProfileRouter: ProfileRouting {
    func presentProfileViewController(_ completion: (() -> Void)?) {
        let view = ProfileViewController()
        view.router = self
        let vc = UIHostingController<ProfileViewController>(rootView: view)
        navigationController.pushViewController(vc, animated: false, completion)
    }
}
