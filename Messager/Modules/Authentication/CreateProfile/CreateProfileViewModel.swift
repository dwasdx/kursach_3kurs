//
//  CreateProfileViewModel.swift
//  Messager
//
//  Created by Андрей Журавлев on 14.04.2021.
//

import Foundation

class CreateProfileViewModel: BaseViewModel {
    var name: String?
    var nickname: String?
    var phoneNumber: String?
    var userInfo: String? {
        didSet {
            didChange?()
        }
    }
    
    let userManager: CurrentUserManaging
    let firestoreService: FirestoreUserServiceable
    
    init(
        userManager: CurrentUserManaging = CurrentUserManager.shared,
        firestoreService: FirestoreUserServiceable = FirestoreService.shared
    ) {
        self.userManager = userManager
        self.firestoreService = firestoreService
    }
}

extension CreateProfileViewModel: CreateProfileViewModeling {
    var wordsCount: Int {
        userInfo?.count ?? 0
    }
    
    var maximumWordsCount: Int {
        250
    }
    
    func setProfileInfo(completion: ((String?) -> Void)?) {
        completion?(nil)
    }
}
