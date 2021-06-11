//
//  EditProfileViewController.swift
//  Messager
//
//  Created by Андрей Журавлев on 19.05.2021.
//

import UIKit
import PhoneNumberKit

protocol EditProfileRouting: AnyObject {
    func dismiss()
}

protocol EditProfileViewModeling: BaseViewModeling {
    var name: String? { get set }
    var nickname: String { get }
    var profileInfo: String? { get set }
    var phoneNumber: String? { get set }
    var imageData: Data? { get set }
    var imageUrl: URL? { get }
    
    func saveProfile(completion: ((Error?) -> Void)?)
}

fileprivate enum Constants {
    static let textViewPlaceholder = "Info about you"
}

final class EditProfileViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var infoTextView: UITextView!
    @IBOutlet weak var phoneNumberTextField: PhoneNumberTextField!
    @IBOutlet weak var nicknameView: UIControl!
    @IBOutlet weak var nicknameLabel: UILabel!
    
    var originalScrollViewInset: UIEdgeInsets = .zero
    
    var router: EditProfileRouting?
    var viewModel: EditProfileViewModeling! {
        didSet {
            viewModel.didChange = { [weak self] in
                DispatchQueue.main.async { [weak self] in
                    self?.update()
                }
            }
            viewModel.didGetError = { [weak self] message in
                DispatchQueue.main.async { [weak self] in
                    self?.showErrorAlert(message: message)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        setupNavBar()
        setupTextView()
        setupTextFields()
        
    }
    
    private func setupNavBar() {
        //        navigationItem.setHidesBackButton(false, animated: false)
        let rightItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(onSave))
        //        navigationItem.setRightBarButton(rightItem, animated: false)
        let leftItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(onCancel))
        //        navigationItem.setLeftBarButton(leftItem, animated: false)
        var frame = navigationController?.navigationBar.frame ?? .zero
        let bar = UINavigationBar(frame: frame)
        let item = UINavigationItem(title: "Profile")
        item.setLeftBarButton(leftItem, animated: false)
        item.setRightBarButton(rightItem, animated: false)
        
        frame.size = CGSize(width: frame.width, height: frame.height + frame.origin.y)
        frame.origin.y = 0
        let view = UIView(frame: frame)
        view.backgroundColor = .secondarySystemBackground
        view.addSubview(bar)
        self.view.addSubview(view)
        bar.setItems([item], animated: true)
        bar.contentMode = .bottom
        
//        var inset = scrollView.contentInset
//        inset.top = view.frame.height
//        scrollView.co
        scrollView.contentInset.top = view.frame.height - scrollView.safeAreaInsets.top
    }
    
    private func setupTextView() {
        infoTextView.delegate = self
        infoTextView.text = Constants.textViewPlaceholder
        infoTextView.textColor = .placeholderText
    }
    
    private func setupTextFields() {
        phoneNumberTextField.withPrefix = true
        phoneNumberTextField.withExamplePlaceholder = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
//        navigationController?.setNavigationBarHidden(false, animated: true)
//        navigationController?.navigationBar.isHidden = false
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        update()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
//        navigationController?.setNavigationBarHidden(true, animated: true)
//        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func update() {
        phoneNumberTextField.text = viewModel.phoneNumber
        nicknameLabel.text = viewModel.nickname
        nameTextField.text = viewModel.name
        if let data = viewModel.imageData {
            avatarImageView.image = UIImage(data: data)
        } else if let url = viewModel.imageUrl {
            avatarImageView.sd_setImage(with: url, completed: nil)
        } else {
            avatarImageView.backgroundColor = .lightGray
            avatarImageView.image = UIImage(systemName: "Person")
            avatarImageView.contentMode = .scaleAspectFit
        }
        if let info = viewModel.profileInfo {
            infoTextView.text = info
            infoTextView.textColor = .label
        }
    }
    
    @objc private func onCancel() {
        self.router?.dismiss()
    }
    
    @objc private func onSave() {
        showSpinner(onView: view)
        viewModel.saveProfile { [weak self] error in
            self?.removeSpinner()
            if let error = error {
                self?.showErrorAlert(message: error.localizedDescription)
                return
            }
            self?.router?.dismiss()
        }
    }
    
    @IBAction func onNewPhoto() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func onNameChanged(_ sender: UITextField) {
        viewModel.name = sender.text
    }
    
    @IBAction func onPhoneNumberChanged(sender: PhoneNumberTextField) {
        viewModel.phoneNumber = sender.text?.trimmingCharacters(in: .whitespacesAndNewlines).decimalString
    }
}

extension EditProfileViewController {
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        originalScrollViewInset = scrollView.contentInset
        var inset = originalScrollViewInset
        inset.bottom = keyboardFrame.height
        scrollView.contentInset = inset
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = originalScrollViewInset
    }
}

extension EditProfileViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        return updatedText.count <= 150
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholderText {
            textView.text = nil
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = Constants.textViewPlaceholder
            textView.textColor = .placeholderText
        }
    }
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            self.avatarImageView.image = image
            viewModel.imageData = image.pngData()
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
