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
    let authenticationService: FirebaseAuthenticationServiceable
    
    var userListenerToken: SignalSubscriptionToken?
    var authStateToken: SignalSubscriptionToken?
    
    init(userManager: CurrentUserManaging = CurrentUserManager.shared,
         authenticationService: FirebaseAuthenticationServiceable = FirebaseAuthenticationService.shared) {
        self.userManager = userManager
        self.authenticationService = authenticationService
        super.init()
        
        userListenerToken = userManager.currentUser.signal.addListener(listenerBlock: { [weak self] user in
            if user == nil {
                self?.didSignOut?()
            }
        })
        authStateToken = authenticationService.authenticationChanged.signal.addListener(skipCurrent: true, skipRepeats: true, listenerBlock: { authenticated in
            if authenticated {
//                self.didSignOut?()
            }
        })
        
    }
    
    deinit {
        userManager.currentUser.signal.removeListener(userListenerToken)
        authenticationService.authenticationChanged.signal.removeListener(authStateToken)
    }
}

extension TabBarViewModel: TabBarViewModeling {
    
}
