//
//  FirestoreService+User.swift
//  iBench
//
//  Created by Андрей Журавлев on 04.12.2020.
//  Copyright © 2020 Андрей Журавлев. All rights reserved.
//

import Foundation
import Firebase

typealias UserResultResponse = (Result<UserObject?, Error>) -> Void
typealias UserResponse = (UserObject?, Error?) -> Void
typealias UsersResultResponse = (Result<[UserObject], Error>) -> Void
typealias SimpleErrorResponse = (_ errorMessage: Error?) -> Void
typealias BoolResultResponse = (Result<Bool, Error>) -> Void

protocol FirestoreUserServiceable {
    func isUserWithEmailExist(_ email: String, completion: @escaping UserResultResponse)
    func isUserWithNicknameExist(_ nickname: String, completion: @escaping BoolResultResponse)
    func getUsersByPhoneNumbers(_ phoneNumbers: [String], completion: @escaping UsersResultResponse)
    
    func addUser(_ user: UserObject, completion: @escaping SimpleErrorResponse)
    func updateUsername(userId: String, _ userName: String, completion: @escaping UserResultResponse)
    
    func getUsersFromDatabase(userIds: [String], completion: @escaping UsersResultResponse)
    func getUserFromDataBase(userId: String, completion: @escaping UserResultResponse)
    func setUserProfileInfo(info: UserProfileModel, completion: @escaping SimpleErrorResponse)
    func setUserObject(_ object: UserObject, completion: @escaping SimpleErrorResponse)
}

extension FirestoreService: FirestoreUserServiceable {
    
    private var usersRef: CollectionReference {
        return firestore.collection(FirestorePathKeys.users)
    }
    
    func addUser(_ user: UserObject, completion: @escaping SimpleErrorResponse) {
        let usersRef = self.usersRef
        guard let json = try? user.asDictionary() else {
            completion(FirestoreError.wrongObjectFormat)
            return
        }
        usersRef.document(user.id).setData(json, completion: completion)
    }
    
    func updateUsername(userId: String, _ userName: String, completion: @escaping UserResultResponse) {
        let usersRef = self.usersRef
        let docRef = usersRef.document(userId)
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = userName
        changeRequest?.commitChanges(completion: { (error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            docRef.getDocument { (snapshot, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                if snapshot == nil {
                    completion(.success(nil))
                }
                guard let snapshot = snapshot,
                      var currentData = try? UserObject(jsonDictionary: snapshot.data() ?? [:]) else {
                    completion(.failure(FirestoreError.badData))
                    return
                }
                currentData.name = userName
                guard let json = try? currentData.asDictionary() else {
                    completion(.failure(FirestoreError.wrongObjectFormat))
                    return
                }
                docRef.setData(json) { (error) in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    completion(.success(currentData))
                }
            }
        })
        
    }
    
    func isUserWithEmailExist(_ email: String, completion: @escaping UserResultResponse) {
        let query = usersRef.whereField("email", isEqualTo: email)
        query.getDocuments { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
            }
            if snapshot?.documents.count ?? 0 > 1 {
                completion(.failure(FirestoreError.tooManyUsers(email)))
            }
            let document = snapshot?.documents.first
            let userObj = try? UserObject(jsonDictionary: document?.data())
            completion(.success(userObj))
        }
    }
    
    func isUserWithNicknameExist(_ nickname: String, completion: @escaping BoolResultResponse) {
        let query = usersRef.whereField("nickname", isEqualTo: nickname)
        query.getDocuments { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            if snapshot?.documents.count ?? 0 > 1 {
                completion(.failure(FirestoreError.tooManyUsers(nickname)))
                return
            }
            
            if let _ = snapshot?.documents.first {
                completion(.success(true))
                return
            }
            completion(.success(false))
        }
    }
    
    func getUsersByPhoneNumbers(_ phoneNumbers: [String], completion: @escaping UsersResultResponse) {
        let query = usersRef.whereField("phoneNumber", in: phoneNumbers)
        
        query.getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let snapshot = snapshot else {
                return
            }
            let users = snapshot.documents.compactMap {
                try? UserObject(jsonDictionary: $0.data())
            }
            completion(.success(users))
        }
    }
    
    func getUserFromDataBase(userId: String, completion: @escaping UserResultResponse) {
        let query = usersRef.whereField("id", isEqualTo: userId)
        query.getDocuments { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
            }
            guard let snapshot = snapshot,
                  !snapshot.documents.isEmpty else {
                completion(.failure(FirestoreError.userNotFound(userId)))
                return
            }
            guard snapshot.documents.count == 1,
                  let userDocument = snapshot.documents.first else {
                completion(.failure(FirestoreError.tooManyUsers(userId)))
                return
            }
            guard let userObject = try? UserObject(jsonDictionary: userDocument.data()) else {
                completion(.failure(FirestoreError.badData))
                return
            }
            completion(.success(userObject))
        }
    }
    
    func getUsersFromDatabase(userIds: [String], completion: @escaping UsersResultResponse) {
        guard userIds.count < 11 else {
            return
        }
        let query = usersRef.whereField("id", in: userIds)
        query.getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            }
            guard let snapshot = snapshot,
                  !snapshot.documents.isEmpty else {
                completion(.failure(FirestoreError.userNotFound(userIds.joined(separator: "\n"))))
                return
            }
            
            let users = snapshot.documents.compactMap { snapshot in
                try? UserObject(jsonDictionary: snapshot.data())
            }
            completion(.success(users))
        }
    }
    
    func setUserProfileInfo(info: UserProfileModel, completion: @escaping SimpleErrorResponse) {
        authenticationService.changeName(info.name) { [weak self] (error) in
            if let error = error {
                completion(error)
                return
            }
            let id = self?.authenticationService.currentUser?.uid ?? ""
            let query = self?.usersRef.whereField("id", isEqualTo: id)
            query?.getDocuments { (snapshot, error) in
                if let error = error {
                    completion(error as NSError?)
                    return
                }
                guard let snapshot = snapshot,
                      !snapshot.documents.isEmpty else {
                    completion(FirestoreError.userNotFound(id) as NSError)
                    return
                }
                guard snapshot.documents.count == 1,
                      let userDocument = snapshot.documents.first else {
                    completion(FirestoreError.tooManyUsers(id) as NSError?)
                    return
                }
                var userObject = try? UserObject(jsonDictionary: userDocument.data())
                userObject?.setUserProfileInfo(info: info)
                guard let json = (try? userObject?.asDictionary()) else {
                    completion(FirestoreError.someMistake("Unable to parse user object"))
                    return
                }
                userDocument.reference.setData(json, completion: completion)
            }
        }
    }
    
    func setUserObject(_ object: UserObject, completion: @escaping SimpleErrorResponse) {
        let data = (try? object.asDictionary()) ?? [:]
        usersRef.document(object.id).setData(data, completion: completion)
    }
}
