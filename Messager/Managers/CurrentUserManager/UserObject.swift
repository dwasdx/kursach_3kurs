//
//  UserObject.swift
//  iBench
//
//  Created by Андрей Журавлев on 13.11.2020.
//  Copyright © 2020 Андрей Журавлев. All rights reserved.
//

import Foundation
import Firebase

struct UserObject: Codable {
    var id: String
    var name: String?
    var nickname: String?
    var email: String?
    var userInfo: String?
    var phoneNumber: String?
    var imageUrl: String?
    var chats: [String]?
    
    var isFilled: Bool {
        name != nil && nickname != nil
    }
    var avatarData: Data?
    
    enum CodingKeys: CodingKey {
        case id, name, nickname, email, userInfo, phoneNumber, imageUrl, chats
    }
    
    init(id: String,
         name: String?,
         nickname: String?,
         email: String?,
         userInfo: String?,
         phoneNumber: String?,
         imageUrl: String?) {
        self.id = id
        self.name = name
        self.nickname = nickname
        self.email = email
        self.userInfo = userInfo
        self.phoneNumber = phoneNumber
        self.imageUrl = imageUrl
    }
    
    init(firebaseUser: User) {
        self.id = firebaseUser.uid
        self.name = firebaseUser.displayName
        self.nickname = ""
        self.email = firebaseUser.email
        self.userInfo = nil
        self.phoneNumber = nil
        self.imageUrl = nil
    }
    
    mutating func setUserProfileInfo(info: UserProfileModel) {
        self.name = info.name
        self.nickname = info.nickname
        self.userInfo = info.userInfo
        self.phoneNumber = info.phoneNumber?.decimalString
        self.imageUrl = info.avatarUrl
    }
    
}

extension UserObject: Equatable {
    
}
