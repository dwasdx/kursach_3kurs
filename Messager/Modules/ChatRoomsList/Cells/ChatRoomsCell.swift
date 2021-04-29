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
    
    func configure(model: ChatRoomModel,
                   firestoreService: FirestoreUserServiceable = FirestoreService.shared,
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
                case .failure(_):
                    self?.interlocutorNameLabel.text = ""
            }
        }
        
        lastMessageTextLabel.text = model.lastMessage.text
        
        let createdAt = model.lastMessage.sentAt
        let date = Date(timeIntervalSince1970: Double(createdAt))
        lastMessageTextLabel.isHidden = false
        lastMessageTimeLabel.text = Self.timeFormatter.string(from: date)
        
    }
}
