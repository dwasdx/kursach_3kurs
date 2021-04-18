//
//  WelcomeScreenViewModel.swift
//  Messager
//
//  Created by Андрей Журавлев on 18.04.2021.
//

import Foundation

class WelcomeScreenViewModel: BaseViewModel {
    var avatarPngData: Data?
    
    init(imageData: Data?) {
        self.avatarPngData = imageData
    }
}

extension WelcomeScreenViewModel: WelcomeScreenViewModeling {
    
}
