//
//  PasswordViewModel.swift
//  Messager
//
//  Created by Андрей Журавлев on 12.04.2021.
//

import Foundation

class PasswrodViewModel: BaseViewModel {
    var password: String? {
        didSet {
            didChange?()
        }
    }
    let email: String?
    var avatarData: Data?
    
    let userObject: UserObject?
    let userManager: CurrentUserManaging
    let storageService: FirebaseStorageServiceable
    
    init(
        userObject: UserObject?,
        email: String? = nil,
        userManager: CurrentUserManaging = CurrentUserManager.shared,
        storageService: FirebaseStorageServiceable = FirebaseStorageService.shared
    ) {
        self.userObject = userObject
        self.email = email
        self.userManager = userManager
        self.storageService = storageService
        super.init()
        
        if let id = userObject?.id {
            storageService.downloadUserAvatar(userId: id) { [weak self] (result) in
                switch result {
                    case .success(let data):
                        self?.avatarData = data
                        self?.didChange?()
                    case .failure(let error):
                        self?.didGetError?(error.localizedDescription)
                }
            }
        }
    }
    
    private func login(_ password: String, _ completion: ((UserObject?, String?) -> Void)?) {
        isLoading = true
        userManager.login(email: userObject?.email,
                          password: password) { [weak self] (error) in
            self?.isLoading = false
            if let error = error {
                completion?(self?.userObject, error.localizedDescription)
                return
            }
//            if let isFilled = self?.userObject?.isFilled, isFilled {
//                completion?(true, nil)
//            } else {
//                completion?(false, nil)
//            }
            completion?(self?.userObject, nil)
        }
    }
    
    private func register(_ password: String, _ completion: ((UserObject?, String?) -> Void)?) {
        isLoading = true
        userManager.createUser(name: nil,
                               email: userObject?.email ?? email,
                               password: password) { [weak self] (error) in
            self?.isLoading = false
            if let error = error {
                completion?(self?.userObject, error.localizedDescription)
                return
            }
            completion?(self?.userObject, nil)
        }
    }
}

extension PasswrodViewModel: PasswordViewModeling {
    var greetingsText: String {
        userObject == nil ? "Register" : "Login As \(userObject!.name ?? userObject!.email ?? "NA")"
    }
    
    var buttonText: String {
        userObject == nil ? "Sign up" : "Log in"
    }
    
    func authenticate(_ completion: ((UserObject?, String?) -> Void)?) {
        guard let password = password else {
            completion?(userObject, "Please enter your password")
            return
        }
        userObject == nil ? register(password, completion) : login(password, completion)
    }
}
