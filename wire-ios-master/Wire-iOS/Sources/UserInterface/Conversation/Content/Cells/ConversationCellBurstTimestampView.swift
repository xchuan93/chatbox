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


import Classy
import Cartography


@objc final public class ConversationCellBurstTimestampView: UIView {

    public let unreadDot = UIView()
    public let label = UILabel()

    public var separatorColor: UIColor?
    public var separatorColorExpanded: UIColor?

    private let unreadDotContainer = UIView()
    private let leftSeparator = UIView()
    private let rightSeparator = UIView()

    private let inset: CGFloat = 16
    private let unreadDotHeight: CGFloat = 8
    private var heightConstraints = [NSLayoutConstraint]()
    private var accentColorObserver: AccentColorChangeHandler?

    public var isShowingUnreadDot: Bool = true {
        didSet {
            leftSeparator.isHidden = isShowingUnreadDot
            unreadDot.isHidden = !isShowingUnreadDot
        }
    }

    public var isSeparatorHidden: Bool = false {
        didSet {
            leftSeparator.isHidden = isSeparatorHidden || isShowingUnreadDot
            rightSeparator.isHidden = isSeparatorHidden
        }
    }

    public var isSeparatorExpanded: Bool = false {
        didSet {
            separatorHeight = isSeparatorExpanded ? 4 : .hairline
            let color = isSeparatorExpanded ? separatorColorExpanded : separatorColor
            leftSeparator.backgroundColor = color
            rightSeparator.backgroundColor = color
        }
    }

    private var separatorHeight: CGFloat = .hairline {
        didSet {
            heightConstraints.forEach {
                $0.constant = separatorHeight
            }
        }
    }

    init() {
        super.init(frame: .zero)
        CASStyler.default().styleItem(self)
        setupViews()
        createConstraints()

        accentColorObserver = AccentColorChangeHandler.addObserver(self) { [weak self] (color, _) in
            self?.unreadDot.backgroundColor = color
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        [leftSeparator, label, rightSeparator, unreadDotContainer].forEach(addSubview)
        unreadDotContainer.addSubview(unreadDot)

        unreadDotContainer.backgroundColor = .clear
        unreadDot.backgroundColor = .accent()
        unreadDot.layer.cornerRadius = unreadDotHeight / 2
        clipsToBounds = true
    }

    private func createConstraints() {
        constrain(self, label, leftSeparator, rightSeparator) { view, label, leftSeparator, rightSeparator in
            leftSeparator.leading == view.leading
            leftSeparator.trailing == label.leading - inset
            leftSeparator.centerY == view.centerY

            rightSeparator.leading == label.trailing + inset
            rightSeparator.trailing == view.trailing
            rightSeparator.centerY == view.centerY

            label.centerY == view.centerY
            label.leading == view.leadingMargin
            label.trailing <= view.trailingMargin ~ 500.0

            heightConstraints = [
                leftSeparator.height == separatorHeight,
                rightSeparator.height == separatorHeight
            ]
        }

        constrain(self, unreadDotContainer, unreadDot, label) { view, unreadDotContainer, unreadDot, label in
            unreadDotContainer.leading == view.leading
            unreadDotContainer.trailing == label.leading
            unreadDotContainer.top == view.top
            unreadDotContainer.bottom == view.bottom

            unreadDot.center == unreadDotContainer.center
            unreadDot.height == unreadDotHeight
            unreadDot.width == unreadDotHeight
        }
    }

}
