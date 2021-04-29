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
}

extension FirestoreService: FirestoreChatServiceable {
    
    private var chatsRef: CollectionReference {
        firestore.collection(FirestorePathKeys.chats)
    }
    
    private var messageRef: CollectionReference {
        firestore.collection(FirestorePathKeys.message)
    }
    
    func setupChatsListener(chats: [String], completion: @escaping ChatChangeResultCompletion) {
        chatsListener?.remove()
        chatsListener = nil
        chatsListener = chatsRef.whereField("chatId", in: chats).addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let snapshot = snapshot else {
                completion(.failure(FirestoreError.noChatSnapshot("")))
                return
            }
            var chats = [ChatChange]()
            print("[\(Date().debugDescription)] Chats changed")
            snapshot.documentChanges.forEach { diff in
                let data = diff.document.data()
                print(data)
                switch diff.type {
                    case .added:
                        if let model = try? ChatRoomModel(jsonDictionary: data) {
                            chats.append(.add(model))
                        }
                    case .modified:
                        if let model = try? ChatRoomModel(jsonDictionary: data) {
                            chats.append(.changed(model))
                        }
                    case .removed:
                        if let model = try? ChatRoomModel(jsonDictionary: data) {
                            chats.append(.removed(model))
                        }
                }
            }
            completion(.success(chats))
        }
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
}
