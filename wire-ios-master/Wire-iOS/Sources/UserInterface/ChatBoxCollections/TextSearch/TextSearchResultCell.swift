//
// Wire
// Copyright (C) 2017 Wire Swiss GmbH
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

@objc internal class TextSearchResultCell: UITableViewCell {
    fileprivate let messageTextLabel = SearchResultLabel()
    fileprivate let footerView = TextSearchResultFooter()
    fileprivate let userImageViewContainer = UIView()
    fileprivate let userImageView = UserImageView(magicPrefix: "content.author_image")
    fileprivate let separatorView = UIView()
    public let resultCountView = RoundedTextBadge()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.userImageView.userSession = ZMUserSession.shared()
        
        self.accessibilityIdentifier = "search result cell"
        
        self.contentView.addSubview(self.footerView)
        self.selectionStyle = .none
        self.messageTextLabel.accessibilityIdentifier = "text search result"
        self.messageTextLabel.numberOfLines = 1
        self.messageTextLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
        self.messageTextLabel.setContentHuggingPriority(UILayoutPriorityRequired, for: .vertical)
        
        self.contentView.addSubview(self.messageTextLabel)
        
        self.userImageViewContainer.addSubview(self.userImageView)
        
        self.contentView.addSubview(self.userImageViewContainer)
        
        self.separatorView.cas_styleClass = "separator"
        self.contentView.addSubview(self.separatorView)
        
        self.resultCountView.textLabel.accessibilityIdentifier = "count of matches"
        self.contentView.addSubview(self.resultCountView)
        
        constrain(self.userImageView, self.userImageViewContainer) { userImageView, userImageViewContainer in
            userImageView.height == 24
            userImageView.width == userImageView.height
            userImageView.center == userImageViewContainer.center
        }
        
        constrain(self.contentView, self.footerView, self.messageTextLabel, self.userImageViewContainer, self.resultCountView) { contentView, footerView, messageTextLabel, userImageViewContainer, resultCountView in
            userImageViewContainer.leading == contentView.leading
            userImageViewContainer.top == contentView.top
            userImageViewContainer.bottom == contentView.bottom
            userImageViewContainer.width == 48
            
            messageTextLabel.top == contentView.top + 10
            messageTextLabel.leading == userImageViewContainer.trailing
            messageTextLabel.trailing == resultCountView.leading - 16
            messageTextLabel.bottom == footerView.top - 4
            
            footerView.leading == userImageViewContainer.trailing
            footerView.trailing == contentView.trailing - 16
            footerView.bottom == contentView.bottom - 10
            
            resultCountView.trailing == contentView.trailing - 16
            resultCountView.centerY == contentView.centerY
            resultCountView.height == 20
            resultCountView.width >= 24
        }
        
        constrain(self.contentView, self.separatorView, self.userImageViewContainer) { contentView, separatorView, userImageViewContainer in
            separatorView.leading == userImageViewContainer.trailing
            separatorView.trailing == contentView.trailing
            separatorView.bottom == contentView.bottom
            separatorView.height == CGFloat.hairline
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.message = .none
        self.queries = []
    }
    
    private func updateTextView() {
        guard let text = message?.textMessageData?.messageText else {
            return
        }
        
        self.messageTextLabel.configure(with: text, queries: queries)
        
        let totalMatches = self.messageTextLabel.estimatedMatchesCount
        
        self.resultCountView.isHidden = totalMatches <= 1
        self.resultCountView.textLabel.text = "\(totalMatches)"
    }
    
    public func configure(with message: ZMConversationMessage, queries: [String]) {
        self.message = message
        self.queries = queries
        
        self.userImageView.user = self.message?.sender
        self.footerView.message = self.message
        
        self.updateTextView()
    }
    
    var message: ZMConversationMessage? = .none
    var queries: [String] = []
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool)  {
        super.setHighlighted(highlighted, animated: animated)
        
        let backgroundColor = ColorScheme.default().color(withName: ColorSchemeColorContentBackground)
        let foregroundColor = ColorScheme.default().color(withName: ColorSchemeColorTextForeground)
        
        self.contentView.backgroundColor = highlighted ? backgroundColor.mix(foregroundColor, amount: 0.1) : backgroundColor
    }
}
