//
//  MessageModel.swift
//  Messager
//
//  Created by Андрей Журавлев on 21.04.2021.
//

import Foundation
import MessageKit

struct MessageModel: Hashable, Codable {
    
    let messageId: String
    let sentBy: String
    let sentAt: TimeInterval
    let isRead: Bool
    let text: String?
    let imageUrl: String?
    let location: LocationCoordinates?
    
    var shortText: String {
        var stringToShow = ""
        if let _ = imageUrl {
            stringToShow = "🖼"
        }
        if let text = text {
            stringToShow += (stringToShow.isEmpty ? "" : " ") + text
        } else if let _ = location {
            stringToShow = "Location"
        } else if !stringToShow.isEmpty {
            stringToShow += " Picture"
        }
        return stringToShow
    }
    
    func asShortMessage() -> ShortMessageModel {
        ShortMessageModel(sentAt: sentAt, sentBy: sentBy, text: shortText)
    }
    
    func asMessageType() -> MessageType {
        MessageDisplayModel(sender: SenderUser(senderId: sentBy, displayName: ""),
                messageId: messageId,
                sentDate: Date(timeIntervalSince1970: sentAt),
                kind: .text("Warning - hardcoded in \(#function)"))
    }
}

//extension MessageModel: MessageType {
//    var sender: SenderType {
//        SenderUser(senderId: sentBy, displayName: "")
//    }
//    var sentDate: Date {
//        Date(timeIntervalSince1970: sentAt)
//    }
//
//    var kind: MessageKind {
//
//    }
//}

struct ShortMessageModel: Codable, Hashable {
    let sentAt: TimeInterval
    let sentBy: String
    let text: String
}

struct MessageDisplayModel: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}
