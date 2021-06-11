//
//  FirestoreService+Chat.swift
//  Messager
//
//  Created by Андрей Журавлев on 29.04.2021.
//

import Foundation
import Firebase

typealias ResultStringArrayCompletion = ([String]) -> Void
typealias ChatChangeResultCompletion = (Result<[ChatChange], Error>) -> Void
typealias MessageChangeResultCompletion = (Result<[MessageChange], Error>) -> Void

enum ChatChange {
    case add(_ chat: ChatRoomModel)
    case changed(_ chat: ChatRoomModel)
    case removed(_ chat: ChatRoomModel)
}

enum MessageChange {
    case add(_ chat: MessageModel)
    case changed(_ chat: MessageModel)
    case removed(_ chat: MessageModel)
}

protocol FirestoreChatServiceable {
    func setupChatsListener(chats: [String], completion: @escaping ChatChangeResultCompletion)
    func setupChatMessagesListener(chatId: String, completion: @escaping MessageChangeResultCompletion)
    func removeMessagesListener()
    
    func getChatRoom(oponentId: String, completion: @escaping (ChatRoomModel) -> Void)
    func getChatRooms(chatIds: [String], completion: @escaping ((Result<[ChatRoomModel], Error>) -> Void))
    
    func sendMessage(_ message: MessageModel, toChat: ChatRoomModel, completion: @escaping SimpleErrorResponse)
}

extension FirestoreService: FirestoreChatServiceable {
    
    private var chatsRef: CollectionReference {
        firestore.collection(FirestorePathKeys.chats)
    }
    
    private var messageRef: CollectionReference {
        firestore.collection(FirestorePathKeys.message)
    }
    
    func getChatRoom(oponentId: String, completion: @escaping (ChatRoomModel) -> Void) {
        if let model = self.chatrooms.first(where: { $0.members.contains(oponentId) }) {
            completion(model)
            return
        }
        DispatchQueue.global().async {
            guard let currentUserId = CurrentUserManager.shared.currentUser.value?.id else {
                fatalError("No current user")
            }
            let room = ChatRoomModel(chatId: UUID().uuidString,
                                     createdBy: currentUserId,
                                     createdAt: Date().timeIntervalSince1970,
                                     updatedAt: Date().timeIntervalSince1970,
                                     lastMessage: nil,
                                     members: [currentUserId, oponentId],
                                     type: 1)
            guard let json = try? room.asDictionary() else {
                return
            }
            self.chatsRef.document(room.chatId).setData(json) { error in
                if let error = error {
                    print(error)
                    return
                }
                self.getUsersFromDatabase(userIds: [currentUserId, oponentId]) { result in
                    switch result {
                        case .success(let users):
                            if var first = users.first {
                                first.chats = first.chats ?? []
                                first.chats?.append(room.chatId)
                                self.setUserObject(first, completion: { _ in })
                            }
                            if var second = users.last {
                                second.chats = second.chats ?? []
                                second.chats?.append(room.chatId)
                                self.setUserObject(second, completion: { _ in })
                            }
                            completion(room)
                        case .failure(let error):
                            print(error)
                    }
                }
//                completion(room)
            }
        }
    }
    
    func setupChatsListener(chats: [String], completion: @escaping ChatChangeResultCompletion) {
        chatsListener?.remove()
        chatsListener = nil
        chatsListener = chatsRef.addSnapshotListener({ snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let snapshot = snapshot else {
                completion(.failure(FirestoreError.noChatSnapshot("")))
                return
            }
            print("[\(Date().debugDescription)] Chats changed")
            var chatsChanges = [ChatChange]()
            snapshot.documentChanges.forEach { diff in
                let data = diff.document.data()
                print(data)
                guard let model = try? ChatRoomModel(jsonDictionary: data),
                      chats.contains(model.chatId) else {
                    return
                }
                switch diff.type {
                    case .added:
                        chatsChanges.append(.add(model))
                        self.chatrooms.append(model)
                    case .modified:
                        chatsChanges.append(.changed(model))
                        if let index = self.chatrooms.firstIndex(where: { $0.chatId == model.chatId }) {
                            self.chatrooms[index] = model
                        }
                    case .removed:
                        chatsChanges.append(.removed(model))
                        if let index = self.chatrooms.firstIndex(where: { $0.chatId == model.chatId }) {
                            self.chatrooms.remove(at: index)
                        }
                }
            }
            completion(.success(chatsChanges))
        })
//        chatsListener = chatsRef.whereField("chatId", in: chats).addSnapshotListener { snapshot, error in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//            guard let snapshot = snapshot else {
//                completion(.failure(FirestoreError.noChatSnapshot("")))
//                return
//            }
//            var chats = [ChatChange]()
//            print("[\(Date().debugDescription)] Chats changed")
//            snapshot.documentChanges.forEach { diff in
//                let data = diff.document.data()
//                print(data)
//                switch diff.type {
//                    case .added:
//                        if let model = try? ChatRoomModel(jsonDictionary: data) {
//                            chats.append(.add(model))
//                            self.chatrooms.append(model)
//                        }
//                    case .modified:
//                        if let model = try? ChatRoomModel(jsonDictionary: data) {
//                            chats.append(.changed(model))
//                            if let index = self.chatrooms.firstIndex(where: { $0.chatId == model.chatId }) {
//                                self.chatrooms[index] = model
//                            }
//                        }
//                    case .removed:
//                        if let model = try? ChatRoomModel(jsonDictionary: data) {
//                            chats.append(.removed(model))
//                            if let index = self.chatrooms.firstIndex(where: { $0.chatId == model.chatId }) {
//                                self.chatrooms.remove(at: index)
//                            }
//                        }
//                }
//            }
//            completion(.success(chats))
//        }
    }
    
    func getChatRooms(chatIds: [String], completion: @escaping ((Result<[ChatRoomModel], Error>) -> Void)) {
        chatsRef.getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let snapshot = snapshot else {
                completion(.failure(FirestoreError.noChatSnapshot("")))
                return
            }
            var models = snapshot.documents.compactMap { try? ChatRoomModel(jsonDictionary: $0.data()) }
            models = models.filter {
                chatIds.contains($0.chatId)
            }
            completion(.success(models))
        }
//        chatsRef.whereField("chatId", in: chatIds).getDocuments { snapshot, error in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//            guard let snapshot = snapshot else {
//                completion(.failure(FirestoreError.noChatSnapshot("")))
//                return
//            }
//            let models = snapshot.documents.compactMap { try? ChatRoomModel(jsonDictionary: $0.data()) }
//            completion(.success(models))
//        }
    }
    
    func setupChatMessagesListener(chatId: String, completion: @escaping MessageChangeResultCompletion) {
        
        messagesListener = messageRef.document(chatId).collection("messages").addSnapshotListener({ snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let snapshot = snapshot else {
                completion(.failure(FirestoreError.noChatSnapshot("")))
                return
            }
            var messages = [MessageChange]()
            print("[\(Date().debugDescription)] Messages changed")
            snapshot.documentChanges.forEach { diff in
                let data = diff.document.data()
                print(data)
                switch diff.type {
                    case .added:
                        if let model = try? MessageModel(jsonDictionary: data) {
                            messages.append(.add(model))
                        }
                    case .modified:
                        if let model = try? MessageModel(jsonDictionary: data) {
                            messages.append(.changed(model))
                        }
                    case .removed:
                        if let model = try? MessageModel(jsonDictionary: data) {
                            messages.append(.removed(model))
                        }
                }
            }
            completion(.success(messages))
        })
    }
    
    func removeMessagesListener() {
        messagesListener?.remove()
        messagesListener = nil
    }
    
    func sendMessage(_ message: MessageModel, toChat: ChatRoomModel, completion: @escaping SimpleErrorResponse) {
        var chat = toChat
        let ref = messageRef.document(chat.chatId).collection("messages")
        do {
            let data = try message.asDictionary()
            ref.addDocument(data: data) { [weak self] error in
                if let error = error {
                    completion(error)
                    return
                }
                chat.lastMessage = message.asShortMessage()
                chat.updatedAt = message.sentAt
                guard let data = try? chat.asDictionary() else {
                    completion(FirestoreError.wrongObjectFormat)
                    return
                }
                self?.chatsRef.document(chat.chatId).setData(data) { error in
                    if let error = error {
                        completion(error)
                        return
                    }
                    completion(nil)
                }
                
            }
        } catch let error {
            completion(error)
        }
        
    }
}
