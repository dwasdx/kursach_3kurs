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
    
    var currentUser: UserObject?
    
    var items: [ChatRoomModel] = []
    
//    var items: [ChatRoomModel] = [
//        ChatRoomModel(chatId: UUID().uuidString,
//                      createdBy: "CiBy6h9km4g03FOFycIRCpxLQ7r2",
//                      createdAt: 1619628514,
//                      updatedAt: 1619628514,
//                      lastMessage: ShortMessageModel(sentAt: 1619628514, sentBy: "CiBy6h9km4g03FOFycIRCpxLQ7r2", text: "shit"),
//                      members: [
//                        "CiBy6h9km4g03FOFycIRCpxLQ7r2",
//                        "XHsJ5u0vkqZgV6N3PifpxscStcF3"
//                      ],
//                      type: 1),
//        ChatRoomModel(chatId: UUID().uuidString,
//                      createdBy: "Y9OS4Bp1dZOPnH5hTPo4gwBNWDM2",
//                      createdAt: 1619628520,
//                      updatedAt: 1619628520,
//                      lastMessage: ShortMessageModel(sentAt: 1619628520, sentBy: "CiBy6h9km4g03FOFycIRCpxLQ7r2", text: "shit2"),
//                      members: [
//                        "CiBy6h9km4g03FOFycIRCpxLQ7r2",
//                        "Y9OS4Bp1dZOPnH5hTPo4gwBNWDM2"
//                      ],
//                      type: 1)
//    ]
    
    let firestoreService: FirestoreChatServiceable
    let userManager: CurrentUserManaging
    
    var userSubscriptionToken: SignalSubscriptionToken?
    
    init(firestoreService: FirestoreChatServiceable = FirestoreService.shared,
         userManager: CurrentUserManaging = CurrentUserManager.shared) {
        self.firestoreService = firestoreService
        self.userManager = userManager
        super.init()
        
        userSubscriptionToken = userManager.currentUser.signal.addListener(skipCurrent: false, skipRepeats: true) { [weak self] userObject in
            self?.currentUser = userObject
            
            firestoreService.getChatRooms(chatIds: userObject?.chats ?? []) { [weak self] result in
                switch result {
                    case .success(let models):
                        self?.items = models
                        self?.items.sort()
                        self?.didChange?()
                        self?.setupChatsListener(chats: userObject?.chats ?? [])
                    case .failure(let error):
                        print(error)
                }
            }
        }
    }
    
    deinit {
        userManager.currentUser.signal.removeListener(userSubscriptionToken)
    }
    
    func setupChatsListener(chats: [String]) {
        firestoreService.setupChatsListener(chats: chats) { [weak self] result in
            switch result {
                case .success(let changes):
                    self?.processChatsChanges(changes)
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    private func processChatsChanges(_ changes: [ChatChange]) {
        changes.forEach { diff in
            switch diff {
                case .add(let model):
                    if let index = items.firstIndex(where: { $0.chatId == model.chatId }) {
                        items[index] = model
                        return
                    }
                    items.insert(model, at: 0)
                case .changed(let model):
                    if let oldModelIndex = items.firstIndex(where: { $0.chatId == model.chatId }) {
                        items[oldModelIndex] = model
                    }
                case .removed(let model):
                    if let oldModelIndex = items.firstIndex(where: { $0.chatId == model.chatId }) {
                        items.remove(at: oldModelIndex)
                    }
            }
        }
        items.sort()
        didChange?()
    }
}

extension ChatRoomsListViewModel: ChatRoomsListViewModeling {
    var sections: [ChatRoomsSection] {
        [.single]
    }
}
