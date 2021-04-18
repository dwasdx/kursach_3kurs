//
//  TabBarRouter.swift
//  Messager
//
//  Created by Андрей Журавлев on 02.03.2021.
//

import UIKit

protocol TabBarRouting: class {
    
    var profileRouter: ProfileRouting! { get }
    var chatRoomsRouter: ChatRoomsListRouting! { get }
    var contactsRouter: ContactRouting! { get }
}

class TabBarRouter {
    let tabBar: TabBarController
    
    var profileRouter: ProfileRouting!
    var chatRoomsRouter: ChatRoomsListRouting!
    var contactsRouter: ContactRouting!
    
    init() {
        tabBar = TabBarController.initFromItsStoryboard()
        profileRouter = ProfileRouter(tabBarRouter: self)
        contactsRouter = ContactRouter(tabBarRouter: self)
        chatRoomsRouter = ChatRoomsListRouter(tabBarRouter: self)
        tabBar.router = self
    }
}

extension TabBarRouter: TabBarRouting {
    
}
