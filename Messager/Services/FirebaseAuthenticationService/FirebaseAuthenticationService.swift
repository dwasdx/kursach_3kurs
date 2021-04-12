//
//  FirebaseAuthenticationService.swift
//  iBench
//
//  Created by Андрей Журавлев on 07.11.2020.
//  Copyright © 2020 Андрей Журавлев. All rights reserved.
//

import Foundation
import Firebase

protocol FirebaseAuthenticationServiceable {
    var currentUser: User? { get }
    var userRegistared: Bool { get }
    
    func register(withEmail email: String?, password: String?, name: String?, completion: @escaping (Result<User, Error>) -> ())
    func login(withEmail email: String?, password: String?, completion: @escaping (Result<User, Error>) -> ())
    func signOut() -> Error?
}

class FirebaseAuthenticationService {
    static let shared = FirebaseAuthenticationService()
    private init() {
        self.authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let self = self else {
                return
            }
            
            self.authenticationChanged.value = self.userRegistared
        }
    }
    
    deinit {
        Auth.auth().removeStateDidChangeListener(authStateDidChangeListenerHandle)
    }
    
    var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle!
    let authenticationChanged = Emitter(false)
    
}

extension FirebaseAuthenticationService: FirebaseAuthenticationServiceable {
    var currentUser: User? {
        Auth.auth().currentUser
    }
    
    var userRegistared: Bool {
        currentUser != nil
    }
    
    func register(withEmail email: String?, password: String?, name: String?, completion: @escaping (Result<User, Error>) -> ()) {
//        guard Validators.isFilled(email: email, password: password) else {
//            completion(.failure(AuthError.notFilled))
//            return
//        }
//        
//        guard Validators.isSimpleEmail(email!) else {
//            completion(.failure(AuthError.invalidEmail))
//            return
//        }
        
        Auth.auth().createUser(withEmail: email!, password: password!) { (result, error) in
            guard let result = result else {
                completion(.failure(error!))
                return
            }
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = name
            changeRequest?.commitChanges(completion: { (error) in
                if error != nil {
                    completion(.success(result.user))
                    return
                }
                completion(.success(self.currentUser ?? result.user))
            })
            
//            completion(.success(result.user))
        }
    }
    
    func login(withEmail email: String?, password: String?, completion: @escaping (Result<User, Error>) -> ()) {
        guard let email = email, let password = password else {
            completion(.failure(AuthError.notFilled))
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            guard let result = result else {
                completion(.failure(error!))
                return
            }
            completion(.success(result.user))
        }
    }
    
    func signOut() -> Error? {
        do {
            try Auth.auth().signOut()
            return nil
        } catch let signOutError {
            print ("ERROR: signing out: %@", signOutError)
            return signOutError
        }
    }
}
