//
//  ChatRoomViewController.swift
//  Messager
//
//  Created by Андрей Журавлев on 21.04.2021.
//

import UIKit
import Photos
import MessageKit
import Lightbox
import InputBarAccessoryView

protocol ChatRoomRouting {
    func presentContactProfileViewController(contact: ContactModel, completion: (() -> Void)?)
}

protocol ChatRoomViewModeling: BaseViewModeling {
    var sender: SenderType { get }
    var numberOfMessages: Int { get }
    var otherUser: UserObject? { get }
    var otherUserAvatarData: Data? { get }
    
    func message(for index: Int, atBottom: Bool) -> (MessageType, Bool)
    func isMessageFromCurrentSender(_ message: MessageType) -> Bool
    func sendTextMessage(_ text: String, completion: ((String?) -> Void)?)
    func sendImage(imageData: Data, completion: ((String?) -> Void)?)
    func sendLocation(location: LocationCoordinates, completion: ((String?) -> Void)?)
}

class ChatRoomViewController: MessagesViewController {
    
    var userPicButton: UIButton?
    
    var router: ChatRoomRouting?
    var viewModel: ChatRoomViewModeling! {
        didSet {
            viewModel.didChange = { [weak self] in
                DispatchQueue.main.async { [weak self] in
                    self?.update()
                }
            }
        }
    }
    
    var navbarOriginallyHidden = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        navbarOriginallyHidden = navigationController?.navigationBar.isHidden ?? false
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
////        tabBarController?.tabBar.isHidden
//        if navbarOriginallyHidden {
////            navigationController?.navigationBar.isHidden = false
//            navigationController?.setNavigationBarHidden(false, animated: true)
//        }
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        navigationController?.navigationBar.isHidden = true
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        if navbarOriginallyHidden {
//            navigationController?.setNavigationBarHidden(true, animated: true)
//        }
//    }
//    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        if navbarOriginallyHidden {
//            navigationController?.navigationBar.isHidden = true
//        }
//    }
    
    private func configureUI() {
        navigationItem.setHidesBackButton(false, animated: false)
        let button = UIButton(type: .system)
        button.size = CGSize(width: 37, height: 37)
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 37),
            button.heightAnchor.constraint(equalToConstant: 37)
        ])
        button.layer.cornerRadius = button.size.width / 2
        button.addTarget(self, action: #selector(onUserPicTapped), for: .touchUpInside)
        button.setImage(UIImage(systemName: "person"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .blue
        self.userPicButton = button
        let rightItem = UIBarButtonItem(customView: button)
        navigationItem.setRightBarButton(rightItem, animated: false)
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        showMessageTimestampOnSwipeLeft = true
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.textMessageSizeCalculator.incomingAvatarSize = .zero
            layout.photoMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.photoMessageSizeCalculator.incomingAvatarSize = .zero
            layout.locationMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.locationMessageSizeCalculator.incomingAvatarSize = .zero
        }
        
        configureMessageInputBar()
    }
    
    private func configureMessageInputBar() {
        messageInputBar.backgroundColor = .secondarySystemBackground
        messageInputBar.delegate = self
        messageInputBar.sendButton.setTitleColor(.systemBlue, for: .normal)
        let item = InputBarButtonItem(type: .system)
        item.setImage(UIImage(systemName: "paperclip"), for: .normal)
        item.addTarget(self, action: #selector(onAttachItem), for: .touchUpInside)
        item.setSize(CGSize(width: 30, height: 30), animated: false)
        item.contentMode = .center
        item.tintColor = .systemGray3
        messageInputBar.leftStackView.alignment = .leading
        messageInputBar.setLeftStackViewWidthConstant(to: 35, animated: false)
        messageInputBar.setStackViewItems([item], forStack: .left, animated: false)
        
        messageInputBar.inputTextView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.layer.borderWidth = 1
        messageInputBar.inputTextView.layer.borderColor = UIColor.chatTextViewBorderGray.cgColor
        messageInputBar.inputTextView.layer.cornerRadius = 16.5
        messageInputBar.inputTextView.placeholder = "Message"
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 5, left: 13, bottom: 5, right: 13)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 5, left: 19, bottom: 5, right: 13)
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    }
    
    private func update() {
        guard isViewLoaded else {
            return
        }
        messagesCollectionView.reloadData()
        updateNavBar()
    }
    
    private func updateNavBar() {
        let otherUser = viewModel.otherUser
        self.title = otherUser?.name ?? otherUser?.nickname ?? ""
        
        if let data = viewModel.otherUserAvatarData,
           viewModel.otherUser?.imageUrl != nil,
           let image = UIImage(data: data) {
            userPicButton?.setImage(image, for: .normal)
        }
    }
    
    @objc private func onAttachItem() {
        let alert = UIAlertController(style: .actionSheet)
        alert.addAction(UIAlertAction(title: "Photo", style: .default, handler: { _ in
            let alert = UIAlertController(style: .actionSheet)
            alert.addPhotoLibraryPicker(
                flow: .vertical,
                paging: true,
                selection: .single(action: { [weak self] asset in
                    guard let asset = asset else {
                        self?.showErrorAlert(message: "Unable to retrieve photo from library")
                        return
                    }
                    let manager = PHImageManager.default()
                    let options = PHImageRequestOptions()
                    options.version = .original
                    options.isSynchronous = true
                    manager.requestImage(for: asset,
                                         targetSize: PHImageManagerMaximumSize,
                                         contentMode: .aspectFit,
                                         options: options) { (image, _) in
                        guard let data = image?.pngData() else {
                            dump(image, name: "Unable to get data from image")
                            return
                        }
                        self?.viewModel.sendImage(imageData: data, completion: { errorMessage in
                            if let message = errorMessage {
                                self?.showErrorAlert(message: message)
                                return
                            }
                        })
                    }
                }))
            alert.addAction(title: "Cancel", style: .cancel)
            alert.show()
        }))
        alert.addAction(UIAlertAction(title: "Location", style: .default, handler: { _ in
            let alert = UIAlertController(style: .actionSheet)
            alert.addLocationPicker { location in
                guard let coord = location?.coordinate else {
                    self.showErrorAlert(message: "Unable to retrieve coordinates")
                    return
                }
                self.viewModel.sendLocation(location: LocationCoordinates(coordinates: coord)) { errorMessage in
                    if let message = errorMessage {
                        self.showErrorAlert(message: message)
                    }
                }
            }
            alert.addAction(title: "Cancel", style: .cancel)
            alert.show()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.show()
    }
    
    @objc private func onUserPicTapped() {
        guard let user = viewModel.otherUser else {
            return
        }
        let contact = ContactModel(id: user.id,
                                   name: user.name ?? user.nickname ?? "",
                                   phoneNumber: user.phoneNumber ?? "NA",
                                   avatarUrl: user.imageUrl,
                                   isInApp: true)
        router?.presentContactProfileViewController(contact: contact, completion: nil)
    }
}

fileprivate extension UIScrollView {
    var isAtBottom: Bool {
        return contentOffset.y >= verticalOffsetForBottom
    }
    
    var verticalOffsetForBottom: CGFloat {
        let scrollViewHeight = bounds.height
        let scrollContentSizeHeight = contentSize.height
        let bottomInset = contentInset.bottom
        let scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight
        return scrollViewBottomOffset
    }
}

extension ChatRoomViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        viewModel.sender
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        let (message, shouldScrollToBottom) = viewModel.message(for: indexPath.section,
                                                                atBottom: messagesCollectionView.isAtBottom)
        if shouldScrollToBottom {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                messagesCollectionView.scrollToLastItem()
            }
        }
        return message
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        viewModel.numberOfMessages
    }
    
    func messageTimestampLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let date = message.sentDate
        let text = NSMutableAttributedString(string: DateFormattingManager.shared.string(from: date, usingFormat: "HH:mm"))
        guard let range = text.string.range(of: text.string) else {
            return nil
        }
        let nsRange = NSRange(range, in: text.string)
        text.addAttributes([
            .font: UIFont.systemFont(ofSize: 11),
            .foregroundColor: UIColor(hex: 0x8E8E93)
        ], range: nsRange)
        return text
    }

}

extension ChatRoomViewController: MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        viewModel.isMessageFromCurrentSender(message) ? .systemBlue : .chatOponentBgGray
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        viewModel.isMessageFromCurrentSender(message) ? .white : .chatOponentTextWhite
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let date = message.sentDate
        let text = NSMutableAttributedString(string: DateFormattingManager.shared.string(from: date, usingFormat: "HH:mm"))
        guard let range = text.string.range(of: text.string) else {
            return nil
        }
        let nsRange = NSRange(range, in: text.string)
        text.addAttributes([
            .font: UIFont.systemFont(ofSize: 11),
            .foregroundColor: UIColor(hex: 0x8E8E93)
        ], range: nsRange)
        return text
    }
}

extension ChatRoomViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        print(text)
        viewModel.sendTextMessage(text) { [weak self] errorMessage in
            if let errorMessage = errorMessage {
                self?.showErrorAlert(message: errorMessage)
                return
            }
            inputBar.inputTextView.text = ""
            self?.messagesCollectionView.scrollToLastItem()
        }
    }
}
