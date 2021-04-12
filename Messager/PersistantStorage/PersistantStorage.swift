//
//  PersistantStorage.swift
//  Messager
//
//  Created by Андрей Журавлев on 05.04.2021.
//

import Foundation

protocol KeyValuePersistentStorage {
    
    func set(key: String, value: Int)
    func get(key: String) -> Int
    
    func set(key: String, value: String?)
    func get(key: String) -> String?
    
    func set(key: String, value: Date?)
    func get(key: String) -> Date?
    
    func set(key: String, value: Any?)
    func object(forKey key: String) -> Any?
}

class UserDefaultsStorage {
    
    // MARK: - Singletone
    static let shared = UserDefaultsStorage()
    private init() {
    }
    
}

extension UserDefaultsStorage: KeyValuePersistentStorage {
    
    // Int
    func set(key: String, value: Int) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    func get(key: String) -> Int {
        UserDefaults.standard.integer(forKey: key)
    }
    
    // String
    func set(key: String, value: String?) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    func get(key: String) -> String? {
        UserDefaults.standard.string(forKey: key)
    }
    
    // Date
    func set(key: String, value: Date?) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    func get(key: String) -> Date? {
        guard let object = UserDefaults.standard.object(forKey: key), let date = object as? Date else {
            return nil
        }
        
        return date
    }
    
    //Any
    func set(key: String, value: Any?) {
        UserDefaults.standard.setValue(value, forKey: key)
    }
    
    func object(forKey key: String) -> Any? {
        UserDefaults.standard.object(forKey: key)
    }
}
