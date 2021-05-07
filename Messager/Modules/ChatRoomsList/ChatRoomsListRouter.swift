//
//  ChatRoomsListRouter.swift
//  Messager
//
//  Created by Андрей Журавлев on 15.04.2021.
//

import UIKit

class ChatRoomsListRouter: BaseRouter {
    
}

extension ChatRoomsListRouter: ChatRoomsListRouting {
    func presentChatRoomsListScreen() {
        let vc = ChatRoomsListViewController.initFromItsStoryboard()
        vc.router = self
        vc.viewModel = ChatRoomsListViewModel()
        navigationController.navigationBar.isHidden = false
        navigationController.navigationBar.isTranslucent = false
        vc.title = "Chats"
        navigationController.pushViewController(vc, animated: false)
    }
    
    func presentChatRoomScreen(model: ChatRoomModel) {
        let vc = ChatRoomViewController.initFromItsStoryboard()
        vc.hidesBottomBarWhenPushed = true
        vc.viewModel = ChatRoomViewModel(room: model)
        let router = ChatRoomRouter()
        router.viewController = vc
        vc.router = router
        navigationController.pushViewController(vc, animated: true)
    }
}
