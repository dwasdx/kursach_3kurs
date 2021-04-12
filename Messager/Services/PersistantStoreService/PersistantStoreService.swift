//
//  PersistantStoreService.swift
//  iBench
//
//  Created by Андрей Журавлев on 28.11.2020.
//  Copyright © 2020 Андрей Журавлев. All rights reserved.
//

import Foundation

// All the logic in extensions that confirms to it's protocols implementations
final class PersistantStoreService {
    
    internal let keyValueStorage: KeyValuePersistentStorage = UserDefaultsStorage.shared
    
    static let shared = PersistantStoreService()
    private init() {
    }
}
