//
// Wire
// Copyright (C) 2016 Wire Swiss GmbH
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
//

import Foundation


extension MessageType {
    var analyticsTypeString : String {
        switch self {
        case .unknown:      return "unknown"
        case .text:         return "text"
        case .image:        return "image"
        case .audio:        return "audio"
        case .video:        return "video"
        case .richMedia:    return "rich_media"
        case .ping:         return "ping"
        case .file:         return "file"
        case .system:       return "system"
        case .location:     return "location"
        }
    }
}

extension ZMMessage {
    
    public class func analyticsTypeString(_ message: ZMConversationMessage) -> String {
        let messageType = Message.messageType(message)
        return analyticsTypeString(withMessageType: messageType)
    }
    
    public class func analyticsTypeString(withMessageType messageType: MessageType) -> String {
        return messageType.analyticsTypeString
    }
}

