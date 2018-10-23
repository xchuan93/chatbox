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


import UIKit
import Cartography


@objc enum OutgoingConnectionBottomBarAction: UInt {
    case cancel, archive
}


@objc final class OutgoingConnectionViewController: UIViewController {

    private let cancelButton = IconButton.iconButtonDefault()
    private let archiveButton = IconButton.iconButtonDefault()

    var buttonCallback: ((OutgoingConnectionBottomBarAction) -> Void)?

    init() {
        super.init(nibName: nil, bundle: nil)
        setupViews()
        createConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        setupCancelButton()
        setupArchiveButton()
        [cancelButton, archiveButton].forEach(view.addSubview)
    }

    private func setupCancelButton() {
        cancelButton.accessibilityLabel = "cancel connection"
        cancelButton.setIcon(.undo, with: .tiny, for: .normal)
        cancelButton.setTitle("profile.cancel_connection_button_title".localized.uppercased(), for: .normal)
        cancelButton.titleLabel?.font = UIFont(magicIdentifier: "style.text.small.font_spec_light")
        cancelButton.setTitleColor(ColorScheme.default().color(withName: ColorSchemeColorTextForeground), for: .normal)
        cancelButton.titleImageSpacing = 24
        cancelButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    private func setupArchiveButton() {
        archiveButton.accessibilityLabel = "archive connection"
        archiveButton.setIcon(.archive, with: .tiny, for: .normal)
        archiveButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    private func createConstraints() {
        constrain(view, cancelButton, archiveButton) { view, cancelButton, archiveButton in
            cancelButton.leading == view.leading + 24
            cancelButton.top == view.top + 12
            cancelButton.bottom == view.bottom - 24
            archiveButton.centerY == cancelButton.centerY
            archiveButton.trailing == view.trailing - 24
        }
    }

    @objc private func buttonTapped(sender: IconButton) {
        switch sender {
        case cancelButton: buttonCallback?(.cancel)
        case archiveButton: buttonCallback?(.archive)
        default: break
        }
    }

}
