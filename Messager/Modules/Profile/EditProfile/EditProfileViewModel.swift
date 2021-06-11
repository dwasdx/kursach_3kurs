//
//  EditProfileViewModel.swift
//  Messager
//
//  Created by Андрей Журавлев on 19.05.2021.
//

import Foundation
import PhoneNumberKit

class EditProfileViewModel: BaseViewModel {
    var userObject: UserObject {
        didSet {
            didChange?()
        }
    }
    
    private var newName: String?
    private var newProfileInfo: String?
    private var newPhoneNumber: String?
    private var newImageData: Data?
    
    let storageService: FirebaseStorageServiceable
    let firestoreUserService: FirestoreUserServiceable
    let userManager: CurrentUserManaging
    
    init(userObject: UserObject,
         storageService: FirebaseStorageServiceable = FirebaseStorageService.shared,
         firestoreUserService: FirestoreUserServiceable = FirestoreService.shared,
         userManager: CurrentUserManaging = CurrentUserManager.shared) {
        self.userObject = userObject
        self.storageService = storageService
        self.firestoreUserService = firestoreUserService
        self.userManager = userManager
        super.init()
        
        storageService.downloadUserAvatar(userId: userObject.id) { [weak self] result in
            switch result {
            case .success(let data):
                self?.userObject.avatarData = data
            case .failure(_):
                break
            }
        }
    }
    
}

extension EditProfileViewModel: EditProfileViewModeling {
    var name: String? {
        get {
            newName ?? userObject.name
        }
        set {
            newName = newValue
        }
    }
    
    var nickname: String {
        userObject.nickname ?? ""
    }
    
    var profileInfo: String? {
        get {
            newProfileInfo ?? userObject.userInfo
        }
        set {
            newProfileInfo = newValue
        }
    }
    
    var phoneNumber: String? {
        get {
            newPhoneNumber ?? userObject.phoneNumber
        }
        set {
            newPhoneNumber = newValue
        }
    }
    
    var imageData: Data? {
        get {
            newImageData ?? userObject.avatarData
        }
        set {
            newImageData = newValue
        }
    }
    
    var imageUrl: URL? {
        nil
    }
    
    func saveProfile(completion: ((Error?) -> Void)?) {
        let dispatchGroup = DispatchGroup()
        if let data = newImageData {
            dispatchGroup.enter()
            storageService.uploadUserAvatar(data, userId: userObject.id) { [weak self] imagePath, error in
                if let error = error {
                    self?.didGetError?(error.localizedDescription)
                    return
                }
                dispatchGroup.leave()
                self?.userObject.imageUrl = imagePath
                self?.uploadNewProfile(self!.userObject, completion: completion)
            }
            return
        }
        uploadNewProfile(userObject, completion: completion)
    }
    
    private func uploadNewProfile( _ userObject: UserObject, completion: ((Error?) -> Void)?) {
        var userObject = userObject
        userObject.name = name
        userObject.phoneNumber = phoneNumber?.decimalString
        userObject.userInfo = profileInfo
        let model = UserProfileModel(name: userObject.name ?? "",
                                     nickname: userObject.nickname ?? "",
                                     phoneNumber: userObject.phoneNumber,
                                     userInfo: userObject.userInfo,
                                     avatarUrl: userObject.imageUrl)
        firestoreUserService.setUserProfileInfo(info: model) { error in
            completion?(error)
        }
    }
}
