//
//  ContactProfileViewModel.swift
//  Messager
//
//  Created by Андрей Журавлев on 30.05.2021.
//

import Foundation

//class ContactProfileViewModel: BaseViewModel {
//
//}
//
//extension ContactProfileViewModel {
//
//}

class ContactProfileViewModel: ObservableObject {
    
    @Published var name: String = ""
    @Published var nickname: String = ""
    @Published var phoneNumber: String = ""
//    @Published var imageUrl: String = ""
    @Published var imageData: Data?
    @Published var userInfo: String = ""
    
    private var router: ContactProfileRouting?
    
    private var contact: ContactModel
    private var user: UserObject?
    
    let firestoreService: FirestoreUserServiceable & FirestoreChatServiceable
    let storageService: FirebaseStorageServiceable
    let phoneFormatter: PhoneNumberFormatting
    
    init(router: ContactProfileRouting?,
         contact: ContactModel,
         firestoreService: FirestoreUserServiceable & FirestoreChatServiceable = FirestoreService.shared,
         storageService: FirebaseStorageServiceable = FirebaseStorageService.shared,
         phoneFormatter: PhoneNumberFormatting = PhoneNumbersFormattingManager.shared) {
        self.router = router
        self.contact = contact
        self.firestoreService = firestoreService
        self.phoneFormatter = phoneFormatter
        self.storageService = storageService
        firestoreService.getUsersByPhoneNumbers([contact.phoneNumber.decimalString]) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
                case .success(let users):
                if let user = users.first {
                    self.user = user
                    self.name = user.name ?? ""
                    self.nickname = user.nickname ?? ""
                    self.userInfo = user.userInfo ?? ""
                    if let number = user.phoneNumber {
                        self.phoneNumber = phoneFormatter.parseDecimalNumber(number)
                    }
                    if user.imageUrl != nil {
//                            storageService.getDownloadUrl(forAvatarImageUrl: <#T##String#>, completion: <#T##((URL?, Error?) -> Void)##((URL?, Error?) -> Void)##(URL?, Error?) -> Void#>)
                        storageService.downloadUserAvatar(userId: user.id) { [weak self] result in
                            switch result {
                            case .success(let data):
                                self?.imageData = data
                            case .failure(let error):
                                print(error)
                            }
                        }
                    }
                } else {
                    self.name = contact.name
                    self.phoneNumber = phoneFormatter.parseDecimalNumber(contact.phoneNumber.decimalString)
                    
                }
                case.failure(let error):
                    print(error)
            }
        }
    }
}

extension ContactProfileViewModel {
    func didTapChat() {
        guard let id = user?.id else {
            return
        }
        firestoreService.getChatRoom(oponentId: id) { [weak self] model in
            self?.router?.presentChatRoomScreen(model: model)
        }
    }
}
