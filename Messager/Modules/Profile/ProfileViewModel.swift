//
//  ProfileViewModel.swift
//  Messager
//
//  Created by Андрей Журавлев on 02.03.2021.
//

import Foundation
import SDWebImage

final class ProfileViewModel: ObservableObject {
    
    weak var router: ProfileRouting?
    
    var userObject: UserObject!
    
    @Published var username: String?
    @Published var name: String?
    @Published var avatarUrl: URL?
    
    var avatarData: Data?
    
    let userManager: CurrentUserManaging
    let storageService: FirebaseStorageServiceable
    
    init(
        router: ProfileRouting?,
        userManager: CurrentUserManaging = CurrentUserManager.shared,
        storageService: FirebaseStorageServiceable = FirebaseStorageService.shared
    ) {
        self.router = router
        self.userManager = userManager
        self.storageService = storageService
        userManager.currentUser.signal.addListener(skipCurrent: false, skipRepeats: false) { [weak self] userObject in
            self?.userObject = userObject
            self?.username = userObject?.nickname
            self?.name = userObject?.name
            if let avatarString = userObject?.imageUrl {
                self?.getAvatarURL(avatarUrlString: avatarString)
            }
//            self?.avatarUrl = userObject?.imageUrl
            
        }
    }
    
    private func getAvatarURL(avatarUrlString: String) {
        storageService.getDownloadUrl(forAvatarImageUrl: avatarUrlString) { [weak self] url, error in
            if let error = error {
                print(error)
                return
            }
            
            self?.avatarUrl = url
        }
    }
}

extension ProfileViewModel {
    func updateProfile() {
        userManager.updateCurrentUser(completion: {_, _ in})
    }
    
    func profileTapped() {
        router?.openEditProfile(userObject: userObject)
    }
    
    func logoutTapped() {
        userManager.logOut { _ in
            
        }
    }
}
