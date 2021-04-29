//
//  TabBarViewModel.swift
//  Messager
//
//  Created by Андрей Журавлев on 29.04.2021.
//

import Foundation

class TabBarViewModel: BaseViewModel {
    
    var didSignOut: (() -> Void)?
    
    let userManager: CurrentUserManaging
    
    var userListenerToken: SignalSubscriptionToken?
    
    init(userManager: CurrentUserManaging = CurrentUserManager.shared) {
        self.userManager = userManager
        super.init()
        userListenerToken = userManager.currentUser.signal.addListener(listenerBlock: { [weak self] user in
            if user == nil {
                self?.didSignOut?()
            }
        })
    }
}

extension TabBarViewModel: TabBarViewModeling {
    
}
