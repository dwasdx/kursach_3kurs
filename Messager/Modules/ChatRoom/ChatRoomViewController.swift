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
    
}

protocol ChatRoomViewModeling: BaseViewModeling {
    var sender: SenderType { get }
    var numberOfMessages: Int { get }
    var otherUser: UserObject? { get }
    var otherUserAvatarData: Data? { get }
    
    func message(for index: Int) -> MessageType
    func isMessageFromCurrentSender(_ message: MessageType) -> Bool
    func sendTextMessage(_ text: String, completion: ((String?) -> Void)?)
    func sendImage(imageData: Data, completion: ((String?) -> Void)?)
    func sendLocation(location: LocationCoordinates, completion: ((String?) -> Void)?)
}

class ChatRoomViewController: MessagesViewController {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        tabBarController?.tabBar.isHidden 
    }
    
    private func configureUI() {
        navigationItem.setHidesBackButton(false, animated: false)
        
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        showMessageTimestampOnSwipeLeft = true
        
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
                            dump(image, name: "unable to get data from image")
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
}

extension ChatRoomViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        viewModel.sender
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        viewModel.message(for: indexPath.section)
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
        }
    }
}
