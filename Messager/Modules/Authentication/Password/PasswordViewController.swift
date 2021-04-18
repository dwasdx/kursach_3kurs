//
//  PasswordViewController.swift
//  Messager
//
//  Created by Андрей Журавлев on 12.04.2021.
//

import UIKit

protocol PasswordRouting {
    func openTabBarScreen()
    func openCreateProfileScreen(userObject: UserObject?)
}

protocol PasswordViewModeling: BaseViewModeling {
    var password: String? { get set }
    var greetingsText: String { get }
    var buttonText: String { get }
    var avatarData: Data? { get }
    
    func authenticate(_ completion: ((UserObject?, String?) -> Void)?)
}

class PasswordViewController: BaseViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var distanceAnchor: NSLayoutConstraint!
    
    private let loginButtonDefaultOffset: CGFloat = -50
    
    var router: PasswordRouting?
    var viewModel: PasswordViewModeling! {
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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        update()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    private func configureUI() {
        nameLabel.text = viewModel.greetingsText
    }
    
    private func update() {
        guard isViewLoaded else {
            return
        }
        updateLoginButton()
        updateLoadingState()
    }
    
    private func updateLoginButton() {
        let isEmptyPassword = viewModel.password?.isEmpty ?? true
        loginButton.isEnabled = !isEmptyPassword
        let color: UIColor = isEmptyPassword ? .gray : .systemBlue
        loginButton.backgroundColor = color
    }
    
    private func updateLoadingState() {
        let isLoading = viewModel.isLoading
        loginButton.isHidden = isLoading
        isLoading ? loadingIndicator.startAnimating() : loadingIndicator.stopAnimating()
    }
    
    private func updateAvatarImage() {
        if let data = viewModel.avatarData {
            imageView.image = UIImage(data: data)
        }
    }
    
    @IBAction func onContinue() {
        viewModel.authenticate { [weak self] (userObject, errorMessage) in
            if let error = errorMessage {
                self?.showErrorAlert(message: error)
                return
            }
            let isProfileFilled = userObject?.isFilled ?? false
            isProfileFilled ? self?.router?.openTabBarScreen() :
                self?.router?.openCreateProfileScreen(userObject: userObject)
        }
    }
    
    @IBAction func onPasswordChanged(sender: UITextField) {
        viewModel.password = sender.text
    }
}

extension PasswordViewController {
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        let containerViewMaxYCoord = containerView.frame.maxY
        let keyboardUpperYCoord = view.frame.height - keyboardFrame.height - 10
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
