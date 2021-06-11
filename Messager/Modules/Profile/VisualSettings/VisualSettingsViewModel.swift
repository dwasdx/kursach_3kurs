//
//  VisualSettingsViewModel.swift
//  Messager
//
//  Created by Андрей Журавлев on 30.05.2021.
//

import Foundation

class VisualSettingsViewModel: ObservableObject {
    @Published var selectedItem: Theme
    
    let settingsManager: SettingsManaging
    
    init(
        settingsManager: SettingsManaging = SettingsManager.shared
    ) {
        self.settingsManager = settingsManager
        selectedItem = settingsManager.theme
    }
    
}

extension VisualSettingsViewModel {
    var items: [Theme] {
        Theme.allCases
    }
    
    func updateTheme(_ theme: Theme) {
        settingsManager.theme = theme
        selectedItem = theme
    }
}
