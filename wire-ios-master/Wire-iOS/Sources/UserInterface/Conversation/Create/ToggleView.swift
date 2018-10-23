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

import UIKit
import Cartography

final class ToggleView: UIView {

    typealias ToggleHandler = (Bool) -> Void
    private let toggle = UISwitch()
    private let titleLabel = UILabel(weight: .light, color: ColorSchemeColorTextForeground, variant: .light)
    private let title: String
    
    var handler: ToggleHandler?
    var isOn: Bool {
        set { toggle.isOn = newValue }
        get { return toggle.isOn }
    }
    
    init(title: String, isOn: Bool, accessibilityIdentifier: String) {
        self.title = title
        super.init(frame: .zero)
        setupViews()
        createConstraints()
        toggle.isOn = isOn
        toggle.accessibilityIdentifier = accessibilityIdentifier
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        [toggle, titleLabel].forEach(addSubview)
        backgroundColor = .wr_color(fromColorScheme: ColorSchemeColorBackground, variant: .light)
        titleLabel.text = title
        toggle.addTarget(self, action: #selector(toggleValueChanged), for: .valueChanged)
    }
    
    private func createConstraints() {
        constrain(self, titleLabel, toggle) { view, titleLabel, toggle in
            titleLabel.centerY == view.centerY
            titleLabel.leading == view.leading + 16
            toggle.centerY == view.centerY
            toggle.trailing == view.trailing - 16
            view.height == 56
        }
    }
    
    @objc private func toggleValueChanged(_ sender: UISwitch) {
        handler?(sender.isOn)
    }
    
}
