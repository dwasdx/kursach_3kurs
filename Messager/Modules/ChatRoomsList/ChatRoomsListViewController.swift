//
//  ChatRoomsListViewController.swift
//  Messager
//
//  Created by Андрей Журавлев on 15.04.2021.
//

import UIKit

protocol ChatRoomsListRouting: BaseRouting {
    func presentChatRoomsListScreen()
}

protocol ChatRoomsListViewModeling: BaseViewModeling {
    
}

class ChatRoomsListViewController: BaseViewController {
    
    var router: ChatRoomsListRouting?
    var viewModel: ChatRoomsListViewModeling! {
        didSet {
            viewModel.didChange = { [weak self] in
                self?.update()
            }
            viewModel.didGetError = { [weak self] (message) in
                self?.showErrorAlert(message: message)
            }
        }
    }
    
    override func viewDidLoad() {
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        update()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    private func configureUI() {
        
    }
    
    private func update() {
        guard isViewLoaded else {
            return
        }
    }
}
