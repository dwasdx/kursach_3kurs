//
//  TabBarController.swift
//  Messager
//
//  Created by Андрей Журавлев on 02.03.2021.
//

import UIKit

class TabBarController: UITabBarController {
    
    var router: TabBarRouting!
    
    override func viewDidLoad() {
        
        router?.profileRouter.presentProfileViewController(nil)
        router?.contactsRouter.presentContactsViewController(nil)
        
        let profile = router.profileRouter.navigationController
        profile.tabBarItem.image = UIImage(systemName: "gear")
        profile.tabBarItem.title = "Settings"
        
        let contacts = router.contactsRouter.navigationController
        contacts.tabBarItem.image = UIImage(systemName: "person")
        contacts.tabBarItem.title = "Contacts"
        viewControllers = [
            contacts,
            profile,
        ]
    }
}
