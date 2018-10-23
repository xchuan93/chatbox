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

import UIKit
import Cartography
import Marklight


public protocol MarkdownBarViewDelegate: class {
    func markdownBarView(_ markdownBarView: MarkdownBarView, didSelectElementType type: MarkdownElementType, with sender: IconButton)
    func markdownBarView(_ markdownBarView: MarkdownBarView, didDeselectElementType type: MarkdownElementType, with sender: IconButton)
}


public final class MarkdownBarView: UIView {
    
    weak var delegate: MarkdownBarViewDelegate?
    
    private let stackView =  UIStackView()
    private let buttonMargin = WAZUIMagic.cgFloat(forIdentifier: "content.left_margin") / 2 - UIImage.size(for: .tiny) / 2
    private let accentColor = ColorScheme.default().accentColor
    private let normalColor = ColorScheme.default().color(withName: ColorSchemeColorIconNormal)
    
    public let headerButton         = PopUpIconButton()
    public let boldButton           = IconButton()
    public let italicButton         = IconButton()
    public let numberListButton     = IconButton()
    public let bulletListButton     = IconButton()
    public let codeButton           = IconButton()
    
    public let buttons: [IconButton]
    public var activeModes = [MarkdownElementType]()
    
    required public init() {
        buttons = [headerButton, boldButton, italicButton, numberListButton, bulletListButton, codeButton]
        super.init(frame: CGRect.zero)
        setupViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 56)
    }
    
    private func setupViews() {
        
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: buttonMargin, bottom: 0, right: buttonMargin)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        
        headerButton.setIcon(.markdownH1, with: .tiny, for: .normal)
        boldButton.setIcon(.markdownBold, with: .tiny, for: .normal)
        italicButton.setIcon(.markdownItalic, with: .tiny, for: .normal)
        numberListButton.setIcon(.markdownNumberList, with: .tiny, for: .normal)
        bulletListButton.setIcon(.markdownBulletList, with: .tiny, for: .normal)
        codeButton.setIcon(.markdownCode, with: .tiny, for: .normal)
        
        for button in buttons {
            let color = ColorScheme.default().color(withName: ColorSchemeColorIconNormal)
            button.setIconColor(color, for: .normal)
            button.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
        
        addSubview(stackView)
        
        constrain(self, stackView) { view, stackView in
            stackView.edges == view.edges
        }
        
        headerButton.itemIcons = [.markdownH1, .markdownH2, .markdownH3]
        headerButton.delegate = self
        headerButton.setupView()
    }
    
    // MARK: Actions
    
    @objc private func buttonTapped(sender: IconButton) {
        
        let elementType: MarkdownElementType
        
        switch sender {
        case headerButton:
            switch headerButton.iconType(for: .normal) {
            case .markdownH1:       elementType = .header(.h1)
            case .markdownH2:       elementType = .header(.h2)
            case .markdownH3:       elementType = .header(.h3)
            default:                return
            }
        case boldButton:            elementType = .bold
        case italicButton:          elementType = .italic
        case numberListButton:      elementType = .numberList
        case bulletListButton:      elementType = .bulletList
        case codeButton:            elementType = .code
        default:                    return
        }
        
        if sender.iconColor(for: .normal) != normalColor {
            sender.setIconColor(normalColor, for: .normal)
            delegate?.markdownBarView(self, didDeselectElementType: elementType, with: sender)
        } else {
            delegate?.markdownBarView(self, didSelectElementType: elementType, with: sender)
        }
    }
    
    public func updateIconsForModes(_ modes: [MarkdownElementType]) {
        
        resetIcons()
        var buttonsToHighlight = [IconButton]()
        
        for type in modes {
            switch type {
            case .header(let level):
                // update header icon
                let icon: ZetaIconType
                switch level {
                case .h1: icon = .markdownH1
                case .h2: icon = .markdownH2
                case .h3: icon = .markdownH3
                }
                headerButton.setIcon(icon, with: .tiny, for: .normal)
                buttonsToHighlight.append(headerButton)
                
            case .italic: buttonsToHighlight.append(italicButton)
            case .bold: buttonsToHighlight.append(boldButton)
            case .numberList: buttonsToHighlight.append(numberListButton)
            case .bulletList: buttonsToHighlight.append(bulletListButton)
            case .code: buttonsToHighlight.append(codeButton)
            default: break
            }
        }
        
        buttonsToHighlight.forEach { $0.setIconColor(accentColor, for: .normal) }
    }
    
    @objc public func resetIcons() {
        buttons.forEach { $0.setIconColor(normalColor, for: .normal) }
    }
}

extension MarkdownBarView: PopUpIconButtonDelegate {
    
    func popUpIconButton(_ button: PopUpIconButton, didSelectIcon icon: ZetaIconType) {
        
        if button === headerButton {
            var headerLevel: MarkdownElementType.HeaderLevel?
            switch icon {
            case .markdownH1: headerLevel = .h1
            case .markdownH2: headerLevel = .h2
            case .markdownH3: headerLevel = .h3
            default: return
            }
            // selecting header level from popup view always inserts/converts current syntax
            delegate?.markdownBarView(self, didSelectElementType: .header(headerLevel!), with: button)
        }
    }
}
