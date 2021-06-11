//
//  PersistantStoreService+User.swift
//  iBench
//
//  Created by Андрей Журавлев on 28.11.2020.
//  Copyright © 2020 Андрей Журавлев. All rights reserved.
//

import Foundation

protocol PersistantStoreUserServiceable: AnyObject {
    var userObject: UserObject? { get set }
}

extension PersistantStoreService: PersistantStoreUserServiceable {
    var userObject: UserObject? {
        get {
            guard let data = keyValueStorage.object(forKey: Self.userObjectKey) as? Data else {
                return nil
            }
            guard let object = try? PropertyListDecoder().decode(UserObject.self, from: data) else {
                return nil
            }
            return object
        }
        set {
            let data = try? PropertyListEncoder().encode(newValue)
            keyValueStorage.set(key: Self.userObjectKey, value: data)
        }
    }
    
    private static let userObjectKey = "userObjectKey"
}
