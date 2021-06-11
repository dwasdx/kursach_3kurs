//
//  ChatRoomModel.swift
//  Messager
//
//  Created by Андрей Журавлев on 21.04.2021.
//

import Foundation

enum ChatType: Int {
    case publ = 0
    case personal = 1
    case unknown = -1
}

struct ChatRoomModel: Hashable, Codable {
    let chatId: String
    let createdBy: String
    let createdAt: TimeInterval
    var updatedAt: TimeInterval
    var lastMessage: ShortMessageModel?
    let members: [String]
    let type: Int
    
    var chatType: ChatType {
        ChatType(rawValue: type) ?? .unknown
    }
}

extension ChatRoomModel: Comparable {
    static func < (lhs: ChatRoomModel, rhs: ChatRoomModel) -> Bool {
        lhs.updatedAt > rhs.updatedAt
    }
}
