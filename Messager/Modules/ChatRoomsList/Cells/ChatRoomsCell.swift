//
//  ChatRoomsCell.swift
//  Messager
//
//  Created by Андрей Журавлев on 21.04.2021.
//

import UIKit

class ChatRoomsCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var interlocutorNameLabel: UILabel!
    @IBOutlet weak var lastMessageTextLabel: UILabel!
    @IBOutlet weak var lastMessageTimeLabel: UILabel!
    
    private var model: ChatRoomModel?
    
    private static var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImageView.cornerRadius = 16
    }
    
    func configure(model: ChatRoomModel,
                   firestoreService: FirestoreUserServiceable = FirestoreService.shared,
                   storageService: FirebaseStorageServiceable = FirebaseStorageService.shared,
                   userManager: CurrentUserManaging = CurrentUserManager.shared) {
        self.model = model
        guard model.chatType == .personal else {
            return
        }
        let userId = userManager.currentUser.value?.id ?? ""
        let interlocutorId = model.members.first(where: { $0 != userId }) ?? ""
        interlocutorNameLabel.text = ""
        firestoreService.getUserFromDataBase(userId: interlocutorId) { [weak self] (result) in
            switch result {
                case .success(let user):
                    self?.interlocutorNameLabel.text = user?.name
                    if let _ = user?.imageUrl, let id = user?.id {
                        storageService.downloadUserAvatar(userId: id) { dataResult in
                            if case .success(let data) = dataResult, let data = data {
                                DispatchQueue.main.async { [weak self] in
                                    self?.avatarImageView.image = UIImage(data: data)
                                }
                            }
                        }
                    } else {
                        DispatchQueue.main.async { [weak self] in
                            self?.avatarImageView.backgroundColor = .systemBlue
                            self?.avatarImageView.image = UIImage(systemName: "person")
                            self?.avatarImageView.contentMode = .scaleAspectFit
                            self?.avatarImageView.tintColor = .white
                        }
                    }
                case .failure(_):
                    DispatchQueue.main.async { [weak self] in
                        self?.interlocutorNameLabel.text = ""
                    }
            }
        }
        
        lastMessageTextLabel.text = model.lastMessage?.text
        
        if let createdAt = model.lastMessage?.sentAt {
//            let createdAt = model.lastMessage?.sentAt ?? 0
            let date = Date(timeIntervalSince1970: Double(createdAt))
            lastMessageTextLabel.isHidden = false
            lastMessageTimeLabel.text = Self.timeFormatter.string(from: date)
        } else {
            lastMessageTimeLabel.text = ""
            lastMessageTextLabel.text = ""
        }
        
        
    }
}
