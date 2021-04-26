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
        
        let userId = userManager.currentUser.value?.id ?? ""
        let interlocutorId = model.creatorId == userId ? model.recipientId : model.creatorId
        interlocutorNameLabel.text = ""
        firestoreService.getUserFromDataBase(userId: interlocutorId) { [weak self] (result) in
            switch result {
                case .success(let user):
                    self?.interlocutorNameLabel.text = user?.name
                case .failure(_):
                    self?.interlocutorNameLabel.text = ""
            }
        }
        
        if let lastMessage = model.messages.last {
            var stringToShow = ""
            if let _ = lastMessage.imageUrl {
                stringToShow = "🖼"
            }
            if let text = lastMessage.text {
                stringToShow += " " + text
            } else if let _ = lastMessage.location {
                stringToShow = "Location"
            }
            if lastMessage.senderId == userId {
                stringToShow = "You: \(stringToShow)"
            }
            
            let createdAt = lastMessage.createdAt
            let date = Date(timeIntervalSince1970: Double(createdAt))
            lastMessageTextLabel.isHidden = false
            lastMessageTimeLabel.text = Self.timeFormatter.string(from: date)
        } else {
            lastMessageTextLabel.isHidden = true
        }
    }
}
