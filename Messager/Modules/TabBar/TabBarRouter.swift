//
//  TabBarRouter.swift
//  Messager
//
//  Created by Андрей Журавлев on 02.03.2021.
//

import UIKit

protocol TabBarRouting: AnyObject {
    
    var profileRouter: ProfileRouting! { get }
    var chatRoomsRouter: ChatRoomsListRouting! { get }
    var contactsRouter: ContactRouting! { get }
    
    func setAuthenticationScreen()
}

class TabBarRouter {
    let tabBar: TabBarController
    
    var profileRouter: ProfileRouting!
    var chatRoomsRouter: ChatRoomsListRouting!
    var contactsRouter: ContactRouting!
    
    init() {
        tabBar = TabBarController.initFromItsStoryboard()
        tabBar.viewModel = TabBarViewModel()
        profileRouter = ProfileRouter(tabBarRouter: self)
        contactsRouter = ContactRouter(tabBarRouter: self)
        chatRoomsRouter = ChatRoomsListRouter(tabBarRouter: self)
        tabBar.router = self
    }
}

extension TabBarRouter: TabBarRouting {
    func setAuthenticationScreen() {
        let vc = AuthenticationViewController.initFromItsStoryboard()
        vc.viewModel = AuthenticationViewModel()
        let router = AuthenticationRouter()
        router.viewController = vc
        vc.router = router
        tabBar.view.window?.rootViewController = vc
    }
}
