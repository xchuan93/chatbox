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

@objc public class AvailabilityStringBuilder: NSObject {

    static func string(for user: ZMUser, with style: AvailabilityLabelStyle, color: UIColor? = nil) -> NSAttributedString {
        
        var title: String = ""
        var color = color
        let availability = user.availability
        var fontSize: FontSize = .small
        
        switch style {
            case .list: do {
                if let name = user.name {
                    title = name
                }

                fontSize = .normal
                if color == nil {
                    color = ColorScheme.default().color(withName: ColorSchemeColorTextForeground, variant: .dark)
                }
            }
            case .participants: do {
                title = user.displayName.uppercased()
                color = ColorScheme.default().color(withName: ColorSchemeColorTextForeground)
            }
            case .placeholder: do {
                if availability != .none { //Should use the default placeholder string
                    title = "availability.\(availability.canonicalName).placeholder".localized(args: user.displayName).uppercased()
                }
            }
        }
        
        guard let textColor = color else { return "".attributedString }
        let icon = AvailabilityStringBuilder.icon(for: availability, with: textColor, and: fontSize)
        let attributedText = IconStringsBuilder.iconString(with: icon, title: title, interactive: false, color: textColor)
        return attributedText
    }
    
    static func icon(for availability: Availability, with color: UIColor, and size: FontSize) -> NSTextAttachment? {
        guard availability != .none, let iconType = availability.iconType, let image = UIImage(for: iconType, fontSize: 10, color: color)
            else { return nil }
        
        let attachment = NSTextAttachment()
        attachment.image = image
        let ratio = image.size.width / image.size.height
        let height: CGFloat = 10
        let verticalOffset : CGFloat = (size == .small) ? -1.0 : 0.0
        attachment.bounds = CGRect(x: 0, y: verticalOffset, width: height * ratio, height: height)
        return attachment
    }
}
