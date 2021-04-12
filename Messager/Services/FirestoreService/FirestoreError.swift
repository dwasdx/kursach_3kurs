//
//  FirestoreError.swift
//  iBench
//
//  Created by Андрей Журавлев on 26.11.2020.
//  Copyright © 2020 Андрей Журавлев. All rights reserved.
//

import Foundation

enum FirestoreError: Error {
    case badData
    case userNotFound(String)
    case tooManyUsers(String)
    case benchNotFound(String)
    case tooManyBenches(String)

    var localizedDescription: String {
        switch self {
            case .badData:
                return "Unable to decode document data"
            case .userNotFound(let id):
                return "Unable to find given user with id \(id)"
            case .tooManyUsers(let id):
                return "Too many users returned by an id-query with id \(id)"
            case .benchNotFound(let id):
                return "Could not find bench with id \(id)"
            case .tooManyBenches(let id):
                return "Too many benches returned by an id-query with id \(id)"
        }
    }
}
