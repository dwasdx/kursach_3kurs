//
//  UserObject.swift
//  iBench
//
//  Created by Андрей Журавлев on 13.11.2020.
//  Copyright © 2020 Андрей Журавлев. All rights reserved.
//

import Foundation
import Firebase

struct UserObject: Codable {
    internal init(name: String, id: String, email: String?) {
        self.name = name
        self.id = id
        self.email = email
    }
    
    var name: String
    var id: String
    let email: String?
    
    var dictionaryRepresentation: [String: Any] {
        [
            "name": name,
            "email": email as Any,
            "id": id,
        ]
    }
    
    init(firebaseUser: User) {
        self.name = firebaseUser.displayName ?? "Not given"
        self.id = firebaseUser.uid
        self.email = firebaseUser.email
    }
    
    init?(document: DocumentSnapshot) {
        let data = document.data()
        guard let name = data?["name"] as? String,
              let id = data?["id"] as? String,
              let email = data?["email"] as? String else {
            return nil
        }
        self.name = name
        self.id = id
        self.email = email
    }
    
}

extension UserObject: Equatable {
    
}
