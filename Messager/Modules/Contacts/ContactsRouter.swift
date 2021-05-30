//
//  ContactsRouter.swift
//  Messager
//
//  Created by Андрей Журавлев on 02.03.2021.
//

import UIKit
import SwiftUI

protocol ContactRouting: BaseRouting {
    func presentContactsViewController(_ completion: (() -> Void)?)
    func presentContactProfileViewController(contact: ContactModel, completion: (() -> Void)?)
}

class ContactRouter: BaseRouter {
    
}

extension ContactRouter: ContactRouting {
    func presentContactsViewController(_ completion: (() -> Void)?) {
        let view = ContactsViewController()
        view.router = self
        let vc = UIHostingController<ContactsViewController>(rootView: view)
        vc.title = "Contacts"
        navigationController.navigationBar.isHidden = false
        navigationController.navigationBar.isTranslucent = false
        navigationController.pushViewController(vc, animated: false, completion)
    }
    
    func presentContactProfileViewController(contact: ContactModel, completion: (() -> Void)?) {
        let view = ContactProfileViewController()
        view.contact = contact
        let router = ContactProfileRouter()
        router.viewController = view
        router.navigationVC = navigationController
        view.router = router
        let vc = UIHostingController<ContactProfileViewController>(rootView: view)
        
        navigationController.pushViewController(vc, animated: true, completion)
    }
}
