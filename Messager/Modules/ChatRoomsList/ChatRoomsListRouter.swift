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
        navigationController.pushViewController(vc, animated: false)
    }
}
