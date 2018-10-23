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

@objc final public class CollectionHeaderView: UICollectionReusableView, Reusable {
    
    public var section: CollectionsSectionSet = .none {
        didSet {
            let icon: ZetaIconType
            
            switch(section) {
            case CollectionsSectionSet.images:
                self.titleLabel.text = "collections.section.images.title".localized.uppercased()
                icon = .photo
            case CollectionsSectionSet.filesAndAudio:
                self.titleLabel.text = "collections.section.files.title".localized.uppercased()
                icon = .document
            case CollectionsSectionSet.videos:
                self.titleLabel.text = "collections.section.videos.title".localized.uppercased()
                icon = .movie
            case CollectionsSectionSet.links:
                self.titleLabel.text = "collections.section.links.title".localized.uppercased()
                icon = .link
            default: fatal("Unknown section")
            }
            
            let iconColor = ColorScheme.default().color(withName: ColorSchemeColorLightGraphite)
            self.iconImageView.image = UIImage(for: icon, iconSize: .tiny, color: iconColor)
        }
    }
    
    public var totalItemsCount: UInt = 0 {
        didSet {
            self.actionButton.isHidden = totalItemsCount == 0
            
            let totalCountText = String(format: "collections.section.all.button".localized, totalItemsCount)
            self.actionButton.setTitle(totalCountText, for: .normal)
        }
    }
    
    public let titleLabel = UILabel()
    public let actionButton = UIButton()
    public let iconImageView = UIImageView()
    
    public var selectionAction: ((CollectionsSectionSet) -> ())? = .none
    
    public required init(coder: NSCoder) {
        fatal("init(coder: NSCoder) is not implemented")
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.titleLabel)
        
        self.actionButton.contentHorizontalAlignment = .right
        self.actionButton.accessibilityLabel = "open all"
        self.actionButton.addTarget(self, action: #selector(CollectionHeaderView.didSelect(_:)), for: .touchUpInside)
        self.addSubview(self.actionButton)
        
        self.iconImageView.contentMode = .center
        self.addSubview(self.iconImageView)
        
        constrain(self, self.titleLabel, self.actionButton, self.iconImageView) { selfView, titleLabel, actionButton, iconImageView in
            iconImageView.leading == selfView.leading + 16
            iconImageView.centerY == selfView.centerY
            iconImageView.width == 16
            iconImageView.height == 16
            
            titleLabel.leading == iconImageView.trailing + 8
            titleLabel.centerY == selfView.centerY
            titleLabel.trailing == selfView.trailing
            
            actionButton.leading == selfView.leading
            actionButton.top == selfView.top
            actionButton.trailing == selfView.trailing - 16
            actionButton.bottom == selfView.bottom
        }
    }
    
    public var desiredWidth: CGFloat = 0
    public var desiredHeight: CGFloat = 0
    
    override open var intrinsicContentSize: CGSize {
        get {
            return CGSize(width: self.desiredWidth, height: self.desiredHeight)
        }
    }
    
    override open func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        var newFrame = layoutAttributes.frame
        newFrame.size.width = intrinsicContentSize.width
        newFrame.size.height = intrinsicContentSize.height
        layoutAttributes.frame = newFrame
        return layoutAttributes
    }
    
    public func didSelect(_ button: UIButton!) {
        self.selectionAction?(self.section)
    }
}
