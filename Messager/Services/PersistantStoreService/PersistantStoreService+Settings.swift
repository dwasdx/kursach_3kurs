//
//  PersistantStoreService+Settings.swift
//  Messager
//
//  Created by Андрей Журавлев on 30.05.2021.
//

import Foundation

protocol Settings: AnyObject {
    var theme: Theme { get set }
}

extension PersistantStoreService: Settings {
    private static let themeKey = "themeKey"
    
    var theme: Theme {
        get {
            Theme(rawValue: keyValueStorage.get(key: Self.themeKey)) ?? .device
        }
        set {
            keyValueStorage.set(key: Self.themeKey, value: newValue.rawValue)
        }
    }
    
}
