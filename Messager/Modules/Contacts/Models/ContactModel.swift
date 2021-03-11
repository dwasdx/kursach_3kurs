//
//  ContactModel.swift
//  Messager
//
//  Created by Андрей Журавлев on 08.03.2021.
//

import Foundation

struct ContactModel: Hashable, Identifiable {
    let id: String
    var name: String
    var phoneNumber: String
    var avatarUrl: String? = "person"
}
