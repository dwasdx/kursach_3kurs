//
//  AuthenticationViewController.swift
//  Messager
//
//  Created by Андрей Журавлев on 15.03.2021.
//

import UIKit
import PhoneNumberKit

protocol AuthenticationRouting {
    func openContinueAsScreen()
    func openCreateProfileScreen()
}

protocol AuthenticationViewModeling: BaseViewModeling {
    var email: String? { get set }
        
    func login(_ completion: ((String?) -> Void)?)
}

class AuthenticationViewController: BaseViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var distanceAnchor: NSLayoutConstraint!
    
    private let loginButtonDefaultOffset: CGFloat = -30
    
    var router: AuthenticationRouting?
    var viewModel: AuthenticationViewModeling! {
        didSet {
            viewModel.didChange = { [weak self] in
                self?.update()
            }
        }
    }
    
    override func viewDidLoad() {
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        update()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    private func configureUI() {
        emailTextField.delegate = self
        
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.setTitleColor(UIColor.white.withAlphaComponent(0.8), for: .disabled)
    }
    
    private func update() {
        guard isViewLoaded else {
            return
        }
        updateLoginButton()
    }
    
    private func updateLoginButton() {
        let isEmptyLogin = viewModel.email?.isEmpty ?? true
        loginButton.isEnabled = !isEmptyLogin
        let color: UIColor = isEmptyLogin ? .gray : .systemBlue
        loginButton.backgroundColor = color
    }
    
    @IBAction func loginButtonTapped() {
        viewModel.login { (errorMessage) in
            if let message = errorMessage {
                self.showErrorAlert(message: message)
                return
            }
            self.router?.openContinueAsScreen()
        }
    }
    
    @IBAction func textFieldEditingChanged(_ textFIeld: UITextField) {
        viewModel.email = textFIeld.text
    }
}

extension AuthenticationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        !(textField.text ?? "").isEmpty
    }
    
    
}

extension AuthenticationViewController {
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        let containerViewMaxYCoord = containerView.frame.maxY
        let keyboardUpperYCoord = view.frame.height - keyboardFrame.height
        if keyboardUpperYCoord < containerViewMaxYCoord {
            distanceAnchor.constant += keyboardUpperYCoord - containerViewMaxYCoord
            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           options: .curveEaseOut) {
                self.view.layoutIfNeeded()
            }
            
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        distanceAnchor.constant = loginButtonDefaultOffset
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: .curveEaseOut) {
            self.view.layoutIfNeeded()
        }
    }
}
