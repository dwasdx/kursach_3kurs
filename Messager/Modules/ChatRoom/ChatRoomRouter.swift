//
//  ChatRoomRouter.swift
//  Messager
//
//  Created by Андрей Журавлев on 21.04.2021.
//

import UIKit
import SwiftUI

class ChatRoomRouter {
    weak var viewController: UIViewController?
}

extension ChatRoomRouter: ChatRoomRouting {
    func presentContactProfileViewController(contact: ContactModel, completion: (() -> Void)?) {
        let view = ContactProfileViewController()
        view.contact = contact
        view.shouldShowChatButton = false
        let router = ContactProfileRouter()
        router.viewController = view
        router.navigationVC = viewController?.navigationController
        view.router = router
        let vc = UIHostingController<ContactProfileViewController>(rootView: view)
        
        viewController?.navigationController?.pushViewController(vc, animated: true, completion)
    }
}
