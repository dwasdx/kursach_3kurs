//
//  ChatRoomsListViewModel.swift
//  Messager
//
//  Created by Андрей Журавлев on 15.04.2021.
//

import Foundation

enum ChatRoomsSection: Hashable {
    case single
}

class ChatRoomsListViewModel: BaseViewModel {
    
    var items: [ChatRoomModel] = [
        ChatRoomModel(roomId: UUID().uuidString,
                      creatorId: "CiBy6h9km4g03FOFycIRCpxLQ7r2",
                      recipientId: "XHsJ5u0vkqZgV6N3PifpxscStcF3",
                      messages: [MessageModel(messageId: UUID().uuidString,
                                              senderId: "CiBy6h9km4g03FOFycIRCpxLQ7r2",
                                              createdAt: 1619444637,
                                              isRead: false,
                                              text: "bla bla",
                                              imageUrl: nil,
                                              location: nil)]),
        ChatRoomModel(roomId: UUID().uuidString,
                      creatorId: "Y9OS4Bp1dZOPnH5hTPo4gwBNWDM2",
                      recipientId: "CiBy6h9km4g03FOFycIRCpxLQ7r2",
                      messages: [MessageModel(messageId: UUID().uuidString,
                                              senderId: "CiBy6h9km4g03FOFycIRCpxLQ7r2",
                                              createdAt: 1619444737,
                                              isRead: false,
                                              text: "bla bla",
                                              imageUrl: nil,
                                              location: nil)]),
    ]
}

extension ChatRoomsListViewModel: ChatRoomsListViewModeling {
    var sections: [ChatRoomsSection] {
        [.single]
    }
    
}
