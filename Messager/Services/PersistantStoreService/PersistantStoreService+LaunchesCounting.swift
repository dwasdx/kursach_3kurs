//
//  PersistantStoreService+LaunchesCounting.swift
//  iBench
//
//  Created by Андрей Журавлев on 28.11.2020.
//  Copyright © 2020 Андрей Журавлев. All rights reserved.
//

import Foundation

protocol LaunchesCounting {
    var launchesCount: Int { get }
    var isFirstLaunch: Bool { get }
    func incrementLaunchesCount()
}

extension PersistantStoreService: LaunchesCounting {
    
    var isFirstLaunch: Bool {
        launchesCount == 1
    }
    
    func incrementLaunchesCount() {
        launchesCount += 1
    }
    
    private(set) var launchesCount: Int {
        get {
            keyValueStorage.get(key: Self.launchesCountKey)
        }
        set {
            keyValueStorage.set(key: Self.launchesCountKey, value: newValue)
        }
    }
    
    private static let launchesCountKey = "launchesCountKey"
}
