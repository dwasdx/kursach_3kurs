//
//  FirestoreService.swift
//  iBench
//
//  Created by Андрей Журавлев on 26.11.2020.
//  Copyright © 2020 Андрей Журавлев. All rights reserved.
//

import Foundation
import Firebase

enum FirestorePathKeys {
    static let users = "users"
    static let chats = "chats"
    static let message = "message"
}

final class FirestoreService {
    
    static let shared = FirestoreService()
    let firestore = Firestore.firestore()

    let authenticationService: FirebaseAuthenticationServiceable
    
    private init(
        authenticationService: FirebaseAuthenticationServiceable = FirebaseAuthenticationService.shared
    ) {
        self.authenticationService = authenticationService
    }
    
    deinit {
        chatsListener?.remove()
        messagesListener?.remove()
    }
    
    var chatsListener: ListenerRegistration?
    var messagesListener: ListenerRegistration?
    
    var chatrooms = [ChatRoomModel]()
//    var benches: Emitter<[BenchObject]> = Emitter([])
    
}


