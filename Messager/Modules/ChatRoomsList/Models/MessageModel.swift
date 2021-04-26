//
//  MessageModel.swift
//  Messager
//
//  Created by Андрей Журавлев on 21.04.2021.
//

import Foundation

struct MessageModel: Hashable, Codable {
    let messageId: String
    let senderId: String
    let createdAt: Int
    let isRead: Bool
    let text: String?
    let imageUrl: String?
    let location: LocationCoordinates?
}
