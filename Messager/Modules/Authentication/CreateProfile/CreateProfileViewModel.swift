//
//  CreateProfileViewModel.swift
//  Messager
//
//  Created by Андрей Журавлев on 14.04.2021.
//

import Foundation

class CreateProfileViewModel: BaseViewModel {
    var name: String? {
        didSet {
            didChange?()
        }
    }
    var nickname: String? {
        didSet {
            didChange?()
        }
    }
    var phoneNumber: String?
    var userInfo: String? {
        didSet {
            didChange?()
        }
    }
    var imageData: Data?
    
    let userObject: UserObject?
    
    let userManager: CurrentUserManaging
    let firestoreService: FirestoreUserServiceable
    let storageService: FirebaseStorageServiceable
    
    init(
        userObject: UserObject?,
        userManager: CurrentUserManaging = CurrentUserManager.shared,
        firestoreService: FirestoreUserServiceable = FirestoreService.shared,
        storageService: FirebaseStorageServiceable = FirebaseStorageService.shared
    ) {
        self.userObject = userObject
        self.userManager = userManager
        self.firestoreService = firestoreService
        self.storageService = storageService
    }
    
    private func updateUserInfo(_ info: UserProfileModel, completion: ((String?) -> Void)?) {
        firestoreService.setUserProfileInfo(info: info) { [weak self] (error) in
            self?.isLoading = false
            completion?(error?.localizedDescription)
        }
    }
    
    private func uploadAvatarAndInfo(_ info: UserProfileModel, completion: ((String?) -> Void)?) {
        var info = info
        if let data = imageData, let id = userObject?.id {
            storageService.uploadUserAvatar(data, userId: id) {[weak self] (path, error) in
                if let error = error {
                    self?.isLoading = false
                    completion?(error.localizedDescription)
                    return
                }
                info.avatarUrl = path
                self?.updateUserInfo(info, completion: completion)
            }
            return
        }
        self.updateUserInfo(info, completion: completion)
    }
}

extension CreateProfileViewModel: CreateProfileViewModeling {
    var wordsCount: Int {
        userInfo?.count ?? 0
    }
    
    var maximumWordsCount: Int {
        250
    }
    
    var isAllowedToContinue: Bool {
        name != nil && nickname != nil && !name!.isEmpty && !nickname!.isEmpty
    }
    
    func setProfileInfo(completion: ((String?) -> Void)?) {
        guard let name = name else {
            completion?("Please enter your name")
            return
        }
        
        guard let nickname = nickname else {
            completion?("Please enter your nickname")
            return
        }
        
        if let number = phoneNumber, !number.isEmpty , number.count < 10 {
            completion?("Please enter full phone number if you intend to use it in your profile")
            return
        }
        
        var phoneNumber: String? = self.phoneNumber ?? ""
        if phoneNumber!.isEmpty {
            phoneNumber = nil
        }
        
        let info = UserProfileModel(name: name,
                                    nickname: nickname,
                                    phoneNumber: phoneNumber,
                                    userInfo: userInfo,
                                    avatarUrl: nil)
        isLoading = true
        
        
        firestoreService.isUserWithNicknameExist(nickname) { [weak self] (result) in
            switch result {
                case .success(let exist):
                    if exist {
                        self?.didGetError?("User with nickname \"\(nickname)\" already exists. Please, pick another nickname")
                        return
                    }
                    self?.uploadAvatarAndInfo(info, completion: completion)
                case .failure(let error):
                    self?.isLoading = false
                    completion?(error.localizedDescription)
                    return
            }
        }
        
        
    }
}
