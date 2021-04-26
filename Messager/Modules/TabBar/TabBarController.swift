//
//  TabBarController.swift
//  Messager
//
//  Created by Андрей Журавлев on 02.03.2021.
//

import UIKit

class TabBarController: UITabBarController {
    
    weak var router: TabBarRouting!
    
    override func viewDidLoad() {
        
        router?.profileRouter.presentProfileViewController(nil)
        router?.chatRoomsRouter.presentChatRoomsListScreen()
        router?.contactsRouter.presentContactsViewController(nil)
        
        let profile = router.profileRouter.navigationController
        profile.tabBarItem.image = UIImage(systemName: "gear")
        profile.tabBarItem.title = "Settings"
        
        let contacts = router.contactsRouter.navigationController
        contacts.tabBarItem.image = UIImage(systemName: "person.circle.fill")
        contacts.tabBarItem.title = "Contacts"
        
        let messages = router.chatRoomsRouter.navigationController
        messages.tabBarItem.image = UIImage(systemName: "text.bubble.fill")
        messages.tabBarItem.title = "Messages"
        
        viewControllers = [
            contacts,
            messages,
            profile,
        ]
        selectedIndex = 1
    }
}
