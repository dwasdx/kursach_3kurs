//
//  FirestoreService.swift
//  iBench
//
//  Created by Андрей Журавлев on 26.11.2020.
//  Copyright © 2020 Андрей Журавлев. All rights reserved.
//

import Foundation
import Firebase

struct FirestorePathKeys {
    static let users = "users"
    static let benches = "benches"
}

final class FirestoreService {
    
    static let shared = FirestoreService()
    private init() {
        
    }
    
    deinit {
        benchesListener?.remove()
    }
    
    var benchesListener: ListenerRegistration?
    
    let firestore = Firestore.firestore()
    
//    var benches: Emitter<[BenchObject]> = Emitter([])
    
}


