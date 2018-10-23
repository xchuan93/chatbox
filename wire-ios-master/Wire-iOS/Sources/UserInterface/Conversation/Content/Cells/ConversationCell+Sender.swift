////
// Wire
// Copyright (C) 2018 Wire Swiss GmbH
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

public extension ConversationCell {

    private enum TextKind {
        case userName(accent: UIColor)
        case botName
        case botSuffix

        var color: UIColor {
            switch self {
            case let .userName(accent: accent):
                return accent
            case .botName:
                return ColorScheme.default().color(withName: ColorSchemeColorTextForeground)
            case .botSuffix:
                return ColorScheme.default().color(withName: ColorSchemeColorTextDimmed)
            }
        }

        var font: UIFont {
            switch self {
            case .userName, .botName:
                return FontSpec(.medium, .semibold).font!
            case .botSuffix:
                return FontSpec(.medium, .regular).font!
            }
        }
    }

    @objc(updateSenderAndSenderImage:)
    func updateSenderAndImage(_ message: ZMConversationMessage) {
        guard let sender = message.sender, let conversation = message.conversation else { return }
        let name = sender.displayName(in: conversation)

        var attributedString: NSAttributedString
        if sender.isServiceUser {
            let bot = attributedName(for: .botSuffix, string: "BOT")
            let name = attributedName(for: .botName, string: name)
            attributedString = name + " ".attributedString + bot
        } else {
            let accentColor = ColorScheme.default().nameAccent(for: sender.accentColorValue, variant: ColorScheme.default().variant)
            attributedString = attributedName(for: .userName(accent: accentColor), string: name)
        }

        self.authorLabel.attributedText = attributedString
        self.authorImageView.user = sender
    }

    private func attributedName(for kind: TextKind, string: String) -> NSAttributedString {
        return string.attributedString.addAttributes([NSForegroundColorAttributeName : kind.color, NSFontAttributeName : kind.font], toSubstring: string)
    }
}
