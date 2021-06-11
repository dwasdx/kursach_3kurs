//
//  SettingsManager.swift
//  Messager
//
//  Created by Андрей Журавлев on 30.05.2021.
//

import UIKit

protocol SettingsManaging: AnyObject {
    var theme: Theme { get set }
}

class SettingsManager {
    let settingsStorage: Settings
    
    static let shared = SettingsManager()
    private init(
        settingsStorage: Settings = PersistantStoreService.shared
    ) {
        self.settingsStorage = settingsStorage
    }
    
}

extension SettingsManager: SettingsManaging {
    var theme: Theme {
        get {
            settingsStorage.theme
        }
        set {
            settingsStorage.theme = newValue
            let sd = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
            sd?.window?.overrideUserInterfaceStyle = newValue.userInterfaceStyle
        }
    }
}

enum Theme: Int, CaseIterable {
    case device
    case light
    case dark
    
    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .device:
            return .unspecified
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
    
    var description: String {
        switch self {
        case .device:
            return "Device Settings"
        case .light:
            return "Light theme"
        case .dark:
            return "Dark theme"
        }
    }
}
