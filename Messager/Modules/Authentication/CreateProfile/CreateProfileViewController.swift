//
//  CreateProfileViewController.swift
//  Messager
//
//  Created by Андрей Журавлев on 14.04.2021.
//

import UIKit
import PhoneNumberKit

protocol CreateProfileRouting {
    func openTabBarScreen()
}

protocol CreateProfileViewModeling: BaseViewModeling {
    var name: String? { get set }
    var nickname: String? { get set }
    var phoneNumber: String? { get set }
    var userInfo: String? { get set }
    var wordsCount: Int { get }
    var maximumWordsCount: Int { get }
    
    func setProfileInfo(completion: ((String?) -> Void)?)
}

class CreateProfileViewController: BaseViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: PhoneNumberTextField!
    @IBOutlet weak var userInfoTextView: UITextView!
    @IBOutlet weak var wordsCountLabel: UILabel!
    
    var router: CreateProfileRouting?
    var viewModel: CreateProfileViewModeling! {
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
        scrollView.delegate = self
        userInfoTextView.delegate = self
        
        phoneNumberTextField.withPrefix = true
        phoneNumberTextField.withExamplePlaceholder = true
    }
    
    private func update() {
        guard isViewLoaded else {
            return
        }
        updateWordsCountLabel()
    }
    
    private func updateWordsCountLabel() {
        wordsCountLabel.text = "\(viewModel.wordsCount)/\(viewModel.maximumWordsCount)"
    }
    
    @IBAction func onContinue() {
        viewModel.setProfileInfo { [weak self] (errorMessage) in
            if let error = errorMessage {
                self?.showErrorAlert(message: error)
                return
            }
            self?.router?.openTabBarScreen()
        }
    }
    
    @IBAction func onNameChanged(sender: UITextField) {
        viewModel.name = sender.text
    }
    
    @IBAction func onNicknameChanged(sender: UITextField) {
        viewModel.nickname = sender.text
    }
    
    @IBAction func onPhoneNumberChanged(sender: UITextField) {
        viewModel.phoneNumber = sender.text
    }
}

extension CreateProfileViewController {
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
        guard userInfoTextView.isFirstResponder else {
            return
        }
        let point = CGPoint(x: wordsCountLabel.frame.maxX,
                            y: wordsCountLabel.frame.maxY)
        let userInfoPoint = wordsCountLabel.convert(point, to: view)
        
        
        var currentOffset = scrollView.contentOffset
        currentOffset.y += keyboardFrame.height
        scrollView.setContentOffset(currentOffset, animated: true)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
//        distanceAnchor.constant = loginButtonDefaultOffset
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            print("no keyboard frame")
            return
        }
        scrollView.contentInset = .zero
        guard userInfoTextView.isFirstResponder else {
            return
        }
        
        var currentOffset = scrollView.contentOffset
        currentOffset.y -= keyboardFrame.height
        scrollView.setContentOffset(currentOffset, animated: true)
        return
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: .curveEaseOut) {
            self.view.layoutIfNeeded()
        }
    }
}

extension CreateProfileViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
}

extension CreateProfileViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        viewModel.userInfo = textView.text
    }
}
