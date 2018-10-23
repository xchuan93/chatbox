//
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

public class GuestIndicator: UIImageView, Themeable {
    
    dynamic var colorSchemeVariant: ColorSchemeVariant = ColorScheme.default().variant {
        didSet {
            guard oldValue != colorSchemeVariant else { return }
            applyColorScheme(colorSchemeVariant)
        }
    }
    
    func applyColorScheme(_ colorSchemeVariant: ColorSchemeVariant) {
        image = UIImage(for: .guest, iconSize: .tiny, color: UIColor.wr_color(fromColorScheme: ColorSchemeColorIconGuest, variant: colorSchemeVariant))
    }
    
    init() {
        super.init(frame: .zero)
        contentMode = .scaleToFill
        setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
        setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
        setContentHuggingPriority(UILayoutPriorityRequired, for: .vertical)
        setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
        accessibilityIdentifier = "img.guest"
        applyColorScheme(colorSchemeVariant)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class GuestLabelIndicator: UIStackView, Themeable {
    
    dynamic var colorSchemeVariant: ColorSchemeVariant = ColorScheme.default().variant {
        didSet {
            guard oldValue != colorSchemeVariant else { return }
            applyColorSchemeOnSubviews(colorSchemeVariant)
            applyColorScheme(colorSchemeVariant)
        }
    }
    
    func applyColorScheme(_ colorSchemeVariant: ColorSchemeVariant) {
        label.textColor = UIColor.wr_color(fromColorScheme: ColorSchemeColorTextForeground, variant: colorSchemeVariant)
        guestIcon.image = UIImage(for: .guest, iconSize: .tiny, color: UIColor.wr_color(fromColorScheme: ColorSchemeColorTextForeground, variant: colorSchemeVariant))
    }
    
    private let guestIcon = UIImageView()
    private let label = UILabel()
    
    init() {
        guestIcon.contentMode = .scaleToFill
        guestIcon.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
        guestIcon.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
        guestIcon.setContentHuggingPriority(UILayoutPriorityRequired, for: .vertical)
        guestIcon.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
        guestIcon.image = UIImage(for: .guest, iconSize: .tiny, color: UIColor.wr_color(fromColorScheme: ColorSchemeColorTextForeground, variant: colorSchemeVariant))
        guestIcon.accessibilityIdentifier = "img.guest"

        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = FontSpec(.medium, .light).font
        label.textColor = UIColor.wr_color(fromColorScheme: ColorSchemeColorTextForeground, variant: colorSchemeVariant)
        label.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
        label.text = "profile.details.guest".localized
        
        super.init(frame: .zero)

        axis = .horizontal
        spacing = 8
        distribution = .fill
        alignment = .fill
        addArrangedSubview(guestIcon)
        addArrangedSubview(label)
        
        accessibilityIdentifier = "guest indicator"
    }
    
    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
