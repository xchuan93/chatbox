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
import Cartography

@objc public final class CollectionCellHeader: UIView {
    public var message: ZMConversationMessage? {
        didSet {
            guard let message = self.message, let serverTimestamp = message.serverTimestamp, let sender = message.sender else {
                return
            }
            
            self.nameLabel.textColor = sender.nameAccentColor
            self.nameLabel.text = sender.displayName
            self.dateLabel.text = serverTimestamp.formattedDate
        }
    }
    
    public required init(coder: NSCoder) {
        fatal("init(coder: NSCoder) is not implemented")
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.nameLabel.accessibilityLabel = "sender name"
        self.dateLabel.accessibilityLabel = "sent on"
        
        self.addSubview(self.nameLabel)
        self.addSubview(self.dateLabel)
        
        constrain(self, self.nameLabel, self.dateLabel) { selfView, nameLabel, dateLabel in
            nameLabel.leading == selfView.leading
            nameLabel.trailing <= dateLabel.leading
            dateLabel.trailing == selfView.trailing
            nameLabel.top == selfView.top
            nameLabel.bottom == selfView.bottom
            dateLabel.centerY == nameLabel.centerY
        }
    }
    
    public var nameLabel = UILabel()
    public var dateLabel = UILabel()
}
