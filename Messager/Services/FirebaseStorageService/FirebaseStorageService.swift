//
//  FirebaseStorageService.swift
//  Messager
//
//  Created by Андрей Журавлев on 18.04.2021.
//

import Foundation
import Firebase

typealias StringErrorResponse = (String?, Error?) -> Void
typealias DataResultResposne = (Result<Data?, Error>) -> Void

protocol FirebaseStorageServiceable {
    func uploadUserAvatar(_ data: Data, userId: String, completion: @escaping StringErrorResponse)
    func downloadUserAvatar(userId: String, completion: @escaping DataResultResposne)
    
}

struct FirebaseStoragePathKeys {
    static let avatars = "avatars"
}

class FirebaseStorageService {
    static let shared = FirebaseStorageService()
    
    private let storage = Storage.storage()
    private lazy var reference = storage.reference()
    
    private func getImagePathForUserId(_ id: String) -> String {
        "\(FirebaseStoragePathKeys.avatars)/user-\(id).png"
    }
}

extension FirebaseStorageService: FirebaseStorageServiceable {
    func uploadUserAvatar(_ data: Data, userId: String, completion: @escaping StringErrorResponse) {
        let imagePath = getImagePathForUserId(userId)
        reference.child(imagePath).putData(data,
                                           metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                print("Error uploading data to path \(imagePath)")
                completion(nil, error)
                return
            }
            completion(metadata.path, nil)
        }
    }
    
    func downloadUserAvatar(userId: String, completion: @escaping DataResultResposne) {
        let imagePath = getImagePathForUserId(userId)
        reference.child(imagePath).getData(maxSize: .max) { (data, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(data))
        }
    }
}
