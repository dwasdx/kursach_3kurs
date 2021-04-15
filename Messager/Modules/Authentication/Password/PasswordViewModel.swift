//
//  PasswordViewModel.swift
//  Messager
//
//  Created by Андрей Журавлев on 12.04.2021.
//

import Foundation

class PasswrodViewModel: BaseViewModel {
    var password: String?
    
    let userManager: CurrentUserManaging
    
    init(
        userManager: CurrentUserManaging = CurrentUserManager.shared
    ) {
        self.userManager = userManager
    }
}

extension PasswrodViewModel: PasswordViewModeling {
    func login(_ completion: ((Bool, String?) -> Void)?) {
        completion?(false, nil)
    }
}
