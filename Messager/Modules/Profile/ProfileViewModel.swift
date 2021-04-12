//
//  ProfileViewModel.swift
//  Messager
//
//  Created by Андрей Журавлев on 02.03.2021.
//

import Foundation

final class ProfileViewModel: ObservableObject {
    
    weak var router: ProfileRouting?
    
    @Published var username: String?
    @Published var name: String?
    
    init(
        router: ProfileRouting?
    ) {
        self.router = router
        username = "dwasd"
        name = "Vladimir"
    }
}
