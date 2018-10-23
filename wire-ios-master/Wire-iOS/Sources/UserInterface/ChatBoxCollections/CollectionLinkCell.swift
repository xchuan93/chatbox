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

final public class CollectionLinkCell: CollectionCell {
    private var articleView: ArticleView? = .none
    private var headerView = CollectionCellHeader()
    
    func createArticleView(with textMessageData: ZMTextMessageData) {
        let articleView = ArticleView(withImagePlaceholder: textMessageData.hasImageData)
        articleView.isUserInteractionEnabled = false
        articleView.imageHeight = 0
        articleView.messageLabel.numberOfLines = 1
        articleView.authorLabel.numberOfLines = 1
        articleView.configure(withTextMessageData: textMessageData, obfuscated: false)
        self.contentView.addSubview(articleView)
        self.contentView.cas_styleClass = "container-view"
        // Reconstraint the header
        self.headerView.removeFromSuperview()
        self.headerView.message = self.message!
        
        self.contentView.addSubview(self.headerView)
        
        self.contentView.layoutMargins = UIEdgeInsetsMake(16, 4, 4, 4)
        
        constrain(self.contentView, articleView, headerView) { contentView, articleView, headerView in
            
            headerView.top == contentView.topMargin
            headerView.leading == contentView.leadingMargin + 12
            headerView.trailing == contentView.trailingMargin - 12
            
            articleView.top >= headerView.bottom - 4
            articleView.left == contentView.leftMargin
            articleView.right == contentView.rightMargin
            articleView.bottom == contentView.bottomMargin
        }
        
        self.articleView = articleView
    }

    override func updateForMessage(changeInfo: MessageChangeInfo?) {
        super.updateForMessage(changeInfo: changeInfo)
        
        guard let message = self.message, let textMessageData = message.textMessageData, let _ = textMessageData.linkPreview else {
            return
        }

        var shouldReload = false
        
        if changeInfo == nil {
            shouldReload = true
        }
        else {
            shouldReload = changeInfo!.imageChanged
        }

        if shouldReload {            
            self.articleView?.removeFromSuperview()
            self.articleView = nil
            
            self.createArticleView(with: textMessageData)
        }
    }

    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        switch action{
        case #selector(copy(_:)): return true
        default: return super.canPerformAction(action, withSender: sender)
        }
    }

    public override func copy(_ sender: Any?) {
        guard let link = message?.textMessageData?.linkPreview else { return }
        UIPasteboard.general.url = link.openableURL as URL?
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        self.message = .none
    }
}
