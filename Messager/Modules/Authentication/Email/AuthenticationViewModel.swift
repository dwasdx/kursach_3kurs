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
//    let firestoreService: FirestoreUserServiceable
    
    init(
        userManager: CurrentUserManaging = CurrentUserManager.shared
//        firestoreService: FirestoreUserServiceable = FirestoreService.shared
    ) {
        self.userManager = userManager
//        self.firestoreService = firestoreService
    }
}

extension AuthenticationViewModel: AuthenticationViewModeling {
    func login(_ completion: ((Any?, String?) -> Void)?) {
        guard let email = email else {
            completion?(nil, "Please enter the email")
            return
        }
        isLoading = true
        userManager.authanticate(email: email) { [weak self] (result) in
            self?.isLoading = false
            switch result {
                case .success(let user):
                    completion?(user ?? email, nil)
                case .failure(let error):
                    completion?(nil, error.localizedDescription)
            }
        }
//        firestoreService.isUserWithEmailExist(email) { [weak self] (result) in
//            self?.isLoading = false
//            switch result {
//                case .success(let user):
//                    completion?(user, nil)
//                case .failure(let error):
//                    completion?(nil, error.localizedDescription)
//            }
//        }
    }
}
