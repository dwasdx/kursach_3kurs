//
//  AuthenticationViewModel.swift
//  Messager
//
//  Created by Андрей Журавлев on 05.04.2021.
//

import Foundation

class AuthenticationViewModel: BaseViewModel {
    var email: String? {
        didSet {
            didChange?()
        }
    }
    
    let userManager: CurrentUserManaging
    
    init(
        userManager: CurrentUserManaging = CurrentUserManager.shared
    ) {
        self.userManager = userManager
    }
}

extension AuthenticationViewModel: AuthenticationViewModeling {
    
    func login(_ completion: ((String?) -> Void)?) {
        completion?(nil)
    }
}
