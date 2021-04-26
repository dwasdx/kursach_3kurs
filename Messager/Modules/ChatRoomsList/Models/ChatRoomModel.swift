//
//  ChatRoomModel.swift
//  Messager
//
//  Created by Андрей Журавлев on 21.04.2021.
//

import Foundation

struct ChatRoomModel: Hashable, Codable {
    let roomId: String
    let creatorId: String
    let recipientId: String
    let messages: [MessageModel]
}
