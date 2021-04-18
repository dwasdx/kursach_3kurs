//
//  CreateProfileViewController.swift
//  Messager
//
//  Created by Андрей Журавлев on 14.04.2021.
//

import UIKit
import PhoneNumberKit
import Photos

protocol CreateProfileRouting {
    func openWelcomeScreen(imageData: Data?)
    func openTabBarScreen()
}

protocol CreateProfileViewModeling: BaseViewModeling {
    var name: String? { get set }
    var nickname: String? { get set }
    var phoneNumber: String? { get set }
    var userInfo: String? { get set }
    var imageData: Data? { get set }
    var wordsCount: Int { get }
    var maximumWordsCount: Int { get }
    var isAllowedToContinue: Bool { get }
    
    func setProfileInfo(completion: ((String?) -> Void)?)
}

class CreateProfileViewController: BaseViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var avatarImageButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: PhoneNumberTextField!
    @IBOutlet weak var userInfoTextView: UITextView!
    @IBOutlet weak var wordsCountLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
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
        updateLoginButton()
        updateLoadingState()
    }
    
    private func updateWordsCountLabel() {
        wordsCountLabel.text = "\(viewModel.wordsCount)/\(viewModel.maximumWordsCount)"
    }
    
    private func updateLoginButton() {
        let isEnabled = viewModel.isAllowedToContinue
        continueButton.isEnabled = isEnabled
        let color: UIColor = isEnabled ? .systemBlue : .gray
        continueButton.backgroundColor = color
    }
    
    private func updateLoadingState() {
        let isLoading = viewModel.isLoading
        continueButton.isHidden = isLoading
        isLoading ? loadingIndicator.startAnimating() : loadingIndicator.stopAnimating()
    }
    
    @IBAction func onContinue() {
        viewModel.setProfileInfo { [weak self] (errorMessage) in
            if let error = errorMessage {
                self?.showErrorAlert(message: error)
                return
            }
            self?.router?.openWelcomeScreen(imageData: self?.viewModel.imageData)
//            self?.router?.openTabBarScreen()
        }
    }
    
    @IBAction func onNameChanged(sender: UITextField) {
        viewModel.name = sender.text?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    @IBAction func onNicknameChanged(sender: UITextField) {
        viewModel.nickname = sender.text?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    @IBAction func onPhoneNumberChanged(sender: UITextField) {
        viewModel.phoneNumber = sender.text?.trimmingCharacters(in: .whitespacesAndNewlines).decimalString
    }
    
    @IBAction func onImageTapped() {
//        let alert = UIAlertController(style: .actionSheet)
//        alert.addPhotoLibraryPicker(
//            flow: .vertical,
//            paging: false,
//            selection: .single(action: { [weak self] asset in
//                guard let asset = asset else {
//                    return
//                }
//                let manager = PHImageManager.default()
//                let options = PHImageRequestOptions()
//                options.version = .original
//                options.isSynchronous = true
//                manager.requestImage(for: asset,
//                                     targetSize: PHImageManagerMaximumSize,
//                                     contentMode: .aspectFit,
//                                     options: options) { (image, _) in
//                    self?.viewModel.imageData = image?.pngData()
//                    self?.avatarImageButton.setBackgroundImage(image, for: .normal)
//                }
////                return img
//            }))
//        alert.addAction(title: "Cancel", style: .cancel)
//        alert.show()
        let picker = UIImagePickerController()
        picker.allowsEditing = true
//        picker.cameraCaptureMode = .photo
        
        picker.delegate = self
        present(picker, animated: true, completion: nil)
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
        _ = wordsCountLabel.convert(point, to: view)
        
        
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
            
//        UIView.animate(withDuration: 0.2,
//                       delay: 0,
//                       options: .curveEaseOut) {
//            self.view.layoutIfNeeded()
//        }
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
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        textView.text.count < viewModel.maximumWordsCount
    }
}

extension CreateProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            self.avatarImageButton.setBackgroundImage(image, for: .normal)
            viewModel.imageData = image.pngData()
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
