//
//  CurrentUserManager.swift
//  iBench
//
//  Created by Андрей Журавлев on 07.11.2020.
//  Copyright © 2020 Андрей Журавлев. All rights reserved.
//

import Foundation
import Firebase

protocol CurrentUserManaging {
    var currentUser: Emitter<UserObject?> { get }
    var didAuthenticateSuccessfully: Emitter<Bool> { get }
    
    var isSignedIn: Bool { get }
    
    func createUser(name: String?, email: String?, password: String?, _ completion: @escaping (_ error: Error?) -> Void)
    func authanticate(email: String, compleiton: @escaping UserResultResponse)
    func updateCurrentUser(completion: @escaping UserResponse)
    func updateDisplayName(name: String, _ completion: @escaping (String?) -> Void)
    func login(email: String?, password: String?, _ compleiton: @escaping (_ error: Error?) -> Void)
    func updateName(name: String, _ completion: @escaping (_ errorMessage: String?) -> Void)
    func logOut(_ completion: ((_ error: NSError?) -> Void)?)
    
    func mapErrorMessage(for error: NSError) -> String
}

class CurrentUserManager: NSObject {
    
    private let authenticationService: FirebaseAuthenticationServiceable
    private let firestoreService: FirestoreUserServiceable
    private let userPersistantStoreService: PersistantStoreUserServiceable
    
    let currentUser = Emitter<UserObject?>(nil)
    let didAuthenticateSuccessfully = Emitter<Bool>(false)
    
    private var timer: Timer?
    
    static let shared = CurrentUserManager()
    private init(
        authenticationService: FirebaseAuthenticationServiceable = FirebaseAuthenticationService.shared,
        firestoreService: FirestoreUserServiceable = FirestoreService.shared,
        persistantStoreService: PersistantStoreUserServiceable = PersistantStoreService.shared
    ) {
        self.authenticationService = authenticationService
        self.firestoreService = firestoreService
        self.userPersistantStoreService = persistantStoreService
        currentUser.value = userPersistantStoreService.userObject
        super.init()
        
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true, block: { [weak self] timer in
            print("[\(Date().debugDescription)] UPDATING USER")
            self?.updateCurrentUser(completion: { _, _ in
                
            })
        })
        timer?.fire()
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
    
    private func setCurrentUser(_ user: UserObject?) {
        let oldValue = currentUser.value
        currentUser.value = user
        userPersistantStoreService.userObject = user
        if oldValue == nil, user != nil {
            didAuthenticateSuccessfully.value = true
        }
    }
}

extension CurrentUserManager: CurrentUserManaging {
    
    func authanticate(email: String, compleiton: @escaping UserResultResponse) {
        firestoreService.isUserWithEmailExist(email, completion: compleiton)
    }
    
    func createUser(name: String?, email: String?, password: String?, _ completion: @escaping (Error?) -> Void) {
        authenticationService.register(withEmail: email, password: password, name: name) { [weak self] (result) in
            switch result {
                case .success(let user):
                    let currentUser = UserObject(firebaseUser: user)
                    self?.firestoreService.addUser(currentUser) { (error) in
                        if let error = error {
                            completion(error)
                            return
                        }
                        self?.setCurrentUser(currentUser)
                        completion(nil)
                    }
                case .failure(let error):
                    completion(error)
            }
        }
    }
    
    func updateCurrentUser(completion: @escaping UserResponse) {
        guard let user = currentUser.value else {
            completion(nil, nil)
            return
        }
        firestoreService.getUserFromDataBase(userId: user.id) { [weak self] result in
            switch result {
                case .success(let object):
                    self?.setCurrentUser(object)
                    completion(object, nil)
                case .failure(let error):
                    completion(nil, error)
            }
        }
    }
    
    func login(email: String?, password: String?, _ compleiton: @escaping (Error?) -> Void) {
        authenticationService.login(withEmail: email, password: password) { [weak self] (result) in
            switch result{
                case .success(let user):
                    let currentUser = UserObject(firebaseUser: user)
                    self?.setCurrentUser(currentUser)
                    compleiton(nil)
                case .failure(let error):
                    compleiton(error)
            }
        }
    }
    
    func updateName(name: String, _ completion: @escaping (String?) -> Void) {
        updateDisplayName(name: name) { [weak self] errorMessage in
            guard let id = self?.currentUser.value?.id else {
                completion("No current user")
                return
            }
            self?.firestoreService.updateUsername(userId: id, name, completion: { result in
                switch result {
                case .success(let user):
                    self?.setCurrentUser(user)
                    completion(nil)
                case .failure(let error):
                    completion(error.localizedDescription)
                }
            })
        }
        
    }
    
    func updateDisplayName(name: String, _ completion: @escaping (String?) -> Void) {
        authenticationService.changeName(name) { error in
            completion(error?.localizedDescription)
        }
    }
    
    func logOut(_ completion: ((NSError?) -> Void)?) {
        if let error = authenticationService.signOut() {
            completion?(error as NSError?)
            return
        }
        currentUser.value = nil
        userPersistantStoreService.userObject = nil
        completion?(nil)
    }
    
    var isSignedIn: Bool {
        authenticationService.currentUser != nil
    }
}

extension CurrentUserManager {
    func mapErrorMessage(for error: NSError) -> String {
        switch error.code {
            case AuthErrorCode.emailAlreadyInUse.rawValue: return "Данный адрес почты уже используется"
            case AuthErrorCode.invalidEmail.rawValue:      return "Аккаунт не существует"
//            case AuthErrorCode.missingEmail.rawValue:      return "Please enter an email"
            case AuthErrorCode.wrongPassword.rawValue:     return "Неверный пароль"
            case AuthErrorCode.userNotFound.rawValue:      return "Пользователь не найден"
            case AuthErrorCode.weakPassword.rawValue:      return "Слишком слабый пароль. Пожалуйста, введите более сложный пароль"
                
            default:
                return error.localizedDescription
        }
    }
}
