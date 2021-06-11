//
//  ChatRoomViewModel.swift
//  Messager
//
//  Created by Андрей Журавлев on 21.04.2021.
//

import Foundation
import MessageKit

import class UIKit.UIImage

struct SenderUser: SenderType {
    var senderId: String
    var displayName: String
}

struct MediaItemModel: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage {
        UIImage(named: "chatImagePlaceholder")!
    }
    var size: CGSize {
        CGSize(width: 200, height: 100)
    }
    
}

class ChatRoomViewModel: BaseViewModel {
    
    private let room: ChatRoomModel
    var otherUser: UserObject? {
        didSet {
            didChange?()
        }
    }
    var otherUserAvatarData: Data? {
        didSet {
            didChange?()
        }
    }
    
    private var messages: [MessageType] = []
    
    private let chatService: FirestoreChatServiceable
    private let userManager: CurrentUserManaging
    private let storageService: FirebaseStorageServiceable
    
    init(room: ChatRoomModel,
         chatService: FirestoreChatServiceable & FirestoreUserServiceable = FirestoreService.shared,
         userManager: CurrentUserManaging = CurrentUserManager.shared,
         storageService: FirebaseStorageServiceable = FirebaseStorageService.shared) {
        self.room = room
        self.chatService = chatService
        self.userManager = userManager
        self.storageService = storageService
        super.init()
        messages = []
        guard let currentUserId = userManager.currentUser.value?.id,
              let otherUserId = room.members.first(where: { $0 != currentUserId }) else {
            return
        }
        chatService.getUserFromDataBase(userId: otherUserId) { [weak self] result in
            switch result {
                case .success(let user):
                    self?.otherUser = user
                    chatService.setupChatMessagesListener(chatId: room.chatId) { [weak self] result in
                        switch result {
                            case .success(let diff):
                                DispatchQueue.global().async {
                                    self?.processMessageDiff(diff)
                                }
                            case .failure(let error):
                                print(error)
                        }
                    }
                case .failure(let error):
                    print(error)
            }
        }
        
        
        storageService.downloadUserAvatar(userId: otherUserId) { [weak self] result in
            switch result {
                case .success(let data):
                    self?.otherUserAvatarData = data
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    deinit {
        chatService.removeMessagesListener()
    }
    
    private func sortMessages() {
        messages.sort { lhs, rhs in
            lhs.sentDate < rhs.sentDate
        }
    }
    
    private func processMessageDiff(_ changes: [MessageChange]) {
        changes.forEach { diff in
            switch diff {
                case .add(let model):
                    insertNewMessage(model)
                case .changed(let model):
                    if let oldModelIndex = messages.firstIndex(where: { $0.messageId == model.messageId }) {
                        replaceExistingMessage(model, oldIndex: oldModelIndex)
                    }
                case .removed(let model):
                    if let oldModelIndex = messages.firstIndex(where: { $0.messageId == model.messageId }) {
                        messages.remove(at: oldModelIndex)
                    }
            }
        }
        sortMessages()
        dump(messages, name: "Messages")
        didChange?()
    }
    
    private func replaceExistingMessage(_ message: MessageModel, oldIndex: Array<MessageModel>.Index) {
        print("\(#function) is not implemented")
    }
    
    private func insertNewMessage(_ message: MessageModel) {
        var name = ""
        if message.sentBy == otherUser?.id {
            name = otherUser?.name ?? otherUser?.nickname ?? "?"
        } else {
            let currentUser = userManager.currentUser.value
            name = currentUser?.name ?? currentUser?.nickname ?? "?"
        }
        var displayModel = MessageDisplayModel(sender: SenderUser(senderId: message.sentBy,
                                                                  displayName: name),
                                               messageId: message.messageId,
                                               sentDate: Date(timeIntervalSince1970: message.sentAt),
                                               kind: .text(""))
        if let text = message.text {
            displayModel.kind = .text(text)
        } else if let location = message.location {
            displayModel.kind = .location(location)
        } else if let imageUrl = message.imageUrl {
            let lastIndex = messages.indices.last ?? 0
            displayModel.kind = .photo(MediaItemModel())
            self.messages.insert(displayModel, at: lastIndex)
            storageService.downloadMessagePicture(path: imageUrl) { [weak self] result in
                switch result {
                    case .success(let data):
                        if let data = data, let image = UIImage(data: data) {
                            displayModel.kind = .photo(MediaItemModel(image: image))
                            if let index = self?.messages.firstIndex(where: { $0.messageId == displayModel.messageId }) {
                                self?.messages[index] = displayModel
                            }
                            self?.sortMessages()
                            self?.didChange?()
                        }
                    case .failure(let error):
                        print(error)
                }
            }
            return
        }
        messages.append(displayModel)
        sortMessages()
    }
}

extension ChatRoomViewModel: ChatRoomViewModeling {
    
    var sender: SenderType {
        SenderUser(senderId: userManager.currentUser.value?.id ?? "", displayName: "user1")
    }
    
    var numberOfMessages: Int {
        messages.count
    }
    
    func message(for index: Int, atBottom: Bool) -> (MessageType, Bool) {
        let message = messages[index]
        let isLatestMessage = index == messages.count - 1
        let shouldScrollToBottom = atBottom && isLatestMessage
        return (message, shouldScrollToBottom)
    }
    
    func isMessageFromCurrentSender(_ message: MessageType) -> Bool {
        message.sender.senderId == "user1"
    }
    
    func sendTextMessage(_ text: String, completion: ((String?) -> Void)?) {
        guard let userId = userManager.currentUser.value?.id else {
            fatalError("Unauthorized user is in chat screen")
        }
        let message = MessageModel(messageId: UUID().uuidString,
                                   sentBy: userId,
                                   sentAt: Date().timeIntervalSince1970,
                                   isRead: false,
                                   text: text,
                                   imageUrl: nil,
                                   location: nil)
        chatService.sendMessage(message, toChat: room) { error in
            if let error = error {
                completion?("Error happened during sending message")
                print(error)
                return
            }
            completion?(nil)
//            self?.messages.append(message)
//            self?.didChange?()
        }
    }
    
    func sendImage(imageData: Data, completion: ((String?) -> Void)?) {
        guard let userId = userManager.currentUser.value?.id else {
            fatalError("Unauthorized user is in chat screen")
        }
        let messageId = UUID().uuidString
        storageService.uploadMessagePicture(chatId: room.chatId,
                                            messageId: messageId,
                                            data: imageData) { progress in
            dump(progress, name: "Progress")
        } completion: { [weak self] path, error in
            guard let self = self else {
                return
            }
            if let _ = error {
                completion?("Error happened during uploading image")
                return
            }
            let model = MessageModel(messageId: messageId,
                                     sentBy: userId,
                                     sentAt: Date().timeIntervalSince1970,
                                     isRead: false,
                                     text: nil,
                                     imageUrl: path,
                                     location: nil)
            self.chatService.sendMessage(model, toChat: self.room) { error in
                if let _ = error {
                    completion?("Error happened during sending message")
                    return
                }
                completion?(nil)
            }
        }

    }
    
    func sendLocation(location: LocationCoordinates, completion: ((String?) -> Void)?) {
        guard let userId = userManager.currentUser.value?.id else {
            fatalError("Unauthorized user is in chat screen")
        }
        let model = MessageModel(messageId: UUID().uuidString,
                                 sentBy: userId,
                                 sentAt: Date().timeIntervalSince1970,
                                 isRead: false,
                                 text: nil,
                                 imageUrl: nil,
                                 location: location)
        chatService.sendMessage(model, toChat: room) { error in
            if let error = error {
                completion?("Error happened during sending message")
                print(error)
                return
            }
            completion?(nil)
        }
    }
}
