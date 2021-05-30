//
//  ContactProfileRouter.swift
//  Messager
//
//  Created by Андрей Журавлев on 30.05.2021.
//

import UIKit

protocol ContactProfileRouting: AnyObject {
    func presentChatRoomScreen(model: ChatRoomModel)
}

class ContactProfileRouter {
    weak var viewController: UIViewController?
    weak var navigationVC: UINavigationController?
}

extension ContactProfileRouter: ContactProfileRouting {
    func presentChatRoomScreen(model: ChatRoomModel) {
        if let vc = navigationVC?.viewControllers.first(where: { $0 is ChatRoomViewController }) {
            navigationVC?.popToViewController(vc, animated: true)
        }
        let vc = ChatRoomViewController.initFromItsStoryboard()
        vc.hidesBottomBarWhenPushed = true
        vc.viewModel = ChatRoomViewModel(room: model)
        let router = ChatRoomRouter()
        router.viewController = vc
        vc.router = router
        navigationVC?.pushViewController(vc, animated: true)
    }
}
