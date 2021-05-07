//
//  FirebaseStorageService.swift
//  Messager
//
//  Created by Андрей Журавлев on 18.04.2021.
//

import Foundation
import Firebase
import Cache

typealias StringErrorResponse = (String?, Error?) -> Void
typealias DataResultResposne = (Swift.Result<Data?, Error>) -> Void

protocol FirebaseStorageServiceable {
    func uploadUserAvatar(_ data: Data, userId: String, completion: @escaping StringErrorResponse)
    func downloadUserAvatar(userId: String, completion: @escaping DataResultResposne)
    func uploadMessagePicture(chatId: String,
                              messageId: String,
                              data: Data,
                              progressHandler: @escaping ((Double) -> Void),
                              completion: @escaping StringErrorResponse)
    func downloadMessagePicture(chatId: String, messageId: String, completion: @escaping DataResultResposne)
    func downloadMessagePicture(path: String, completion: @escaping DataResultResposne)
}

fileprivate struct FirebaseStoragePathKeys {
    static let avatars = "avatars"
    static let messageImages = "messageImages"
}

class FirebaseStorageService {
    let queue = DispatchQueue(label: "com.messager.fetchPhotos",
                              qos: .userInitiated,
                              autoreleaseFrequency: .inherit,
                              target: nil)
    
    static let shared = FirebaseStorageService()
    private init() {}
    
    private let storage = Firebase.Storage.storage()
    private lazy var reference = storage.reference()
    
    let diskConfig = DiskConfig(name: "Floppy")
    let memoryConfig = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)
    
    lazy var chacheStorage: Cache.Storage<String, Data>? = {
        return try? Cache.Storage<String, Data>(
            diskConfig: diskConfig,
            memoryConfig: memoryConfig,
            transformer: TransformerFactory.forCodable(ofType: Data.self)
        )
        
    }()
    
    private func getImagePathForUserId(_ id: String) -> String {
        "\(FirebaseStoragePathKeys.avatars)/user-\(id).png"
    }
    
    private func getMessageImagePath(forChatId chatId: String, andMessageId messageId: String) -> String {
        [FirebaseStoragePathKeys.messageImages, chatId, "\(messageId).png"].joined(separator: "/")
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
        queue.async { [weak self] in
            guard let imagePath = self?.getImagePathForUserId(userId) else {
                return
            }
            if let entry = try? self?.chacheStorage?.entry(forKey: imagePath) {
                completion(.success(entry.object))
                return
            }
            self?.reference.child(imagePath).getData(maxSize: .max) { (data, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                if let data = data {
                    try? self?.chacheStorage?.setObject(data, forKey: imagePath)
                }
                completion(.success(data))
            }
        }
    }
    
    func uploadMessagePicture(chatId: String,
                              messageId: String,
                              data: Data,
                              progressHandler: @escaping ((Double) -> Void),
                              completion: @escaping StringErrorResponse) {
        let imagePath = getMessageImagePath(forChatId: chatId, andMessageId: messageId)
        let task = reference.child(imagePath).putData(data, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                print("Error uploading data to path \(imagePath)")
                completion(nil, error)
                return
            }
            try? self.chacheStorage?.setObject(data, forKey: String(imagePath))
            completion(metadata.path, nil)
        }
        task.observe(.progress) { snapshot in
            let percentComplete = Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            progressHandler(percentComplete)
        }
        task.observe(.success) { _ in
            task.removeAllObservers()
        }
    }
    
    func downloadMessagePicture(chatId: String, messageId: String, completion: @escaping DataResultResposne) {
        queue.async { [weak self] in
            guard let imagePath = self?.getMessageImagePath(forChatId: chatId, andMessageId: messageId) else {
                return
            }
            if let entry = try? self?.chacheStorage?.entry(forKey: imagePath) {
                completion(.success(entry.object))
                return
            }
            self?.reference.child(imagePath).getData(maxSize: .max) { data, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                if let data = data {
                    try? self?.chacheStorage?.setObject(data, forKey: imagePath)
                }
                completion(.success(data))
            }
        }
    }
    
    func downloadMessagePicture(path: String, completion: @escaping DataResultResposne) {
        queue.async { [weak self] in
            if let entry = try? self?.chacheStorage?.entry(forKey: path) {
                completion(.success(entry.object))
                return
            }
            self?.reference.child(path).getData(maxSize: .max) { data, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                if let data = data {
                    try? self?.chacheStorage?.setObject(data, forKey: path)
                }
                completion(.success(data))
            }
        }
    }
}
