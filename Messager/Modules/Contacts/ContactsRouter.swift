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
}

class ContactRouter: BaseRouter {
    
}

extension ContactRouter: ContactRouting {
    func presentContactsViewController(_ completion: (() -> Void)?) {
        let view = ContactsViewController()
        view.router = self
        let vc = UIHostingController<ContactsViewController>(rootView: view)
        navigationController.pushViewController(vc, animated: false, completion)
    }
}
