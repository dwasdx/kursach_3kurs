//
//  UserProfileModel.swift
//  Messager
//
//  Created by Андрей Журавлев on 16.04.2021.
//

import Foundation

struct UserProfileModel: Codable {
    let name: String
    let nickname: String
    let phoneNumber: String?
    let userInfo: String?
    var avatarUrl: String?
}
