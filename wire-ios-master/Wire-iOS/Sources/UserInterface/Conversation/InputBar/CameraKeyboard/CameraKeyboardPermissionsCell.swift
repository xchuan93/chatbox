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
import Cartography
import UIKit

public enum DeniedAuthorizationType {
    case camera
    case photos
    case cameraAndPhotos
}

open class CameraKeyboardPermissionsCell: UICollectionViewCell, Reusable {

    let settingsButton = Button()
    let descriptionLabel = UILabel()
    
    private let containerView = UIView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = ColorScheme.default().color(withName: ColorSchemeColorGraphite)
        
        let textSize: CGFloat = 16.0
        
        descriptionLabel.backgroundColor = .clear
        descriptionLabel.textColor = .white
        descriptionLabel.font = UIFont.systemFont(ofSize: textSize, weight: UIFontWeightLight)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        
        settingsButton.setTitleColor(.white, for: .normal)
        settingsButton.titleLabel?.font = UIFont.systemFont(ofSize: textSize, weight: UIFontWeightSemibold)
        settingsButton.setTitle("keyboard_photos_access.denied.keyboard.settings".localized, for: .normal)
        settingsButton.contentEdgeInsets = UIEdgeInsetsMake(10, 30, 10, 30)
        settingsButton.layer.cornerRadius = 4.0
        settingsButton.layer.masksToBounds = true
        settingsButton.addTarget(self, action: #selector(CameraKeyboardPermissionsCell.openSettings), for: .touchUpInside)
        settingsButton.setBackgroundImageColor(UIColor.white.withAlphaComponent(0.16), for: .normal)
        settingsButton.setBackgroundImageColor(UIColor.white.withAlphaComponent(0.24), for: .highlighted)
        containerView.backgroundColor = .clear
        
        [descriptionLabel, settingsButton].forEach(containerView.addSubview)
        addSubview(containerView)
        
        createConstraints()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public convenience init(frame: CGRect, deniedAuthorization: DeniedAuthorizationType) {
        self.init(frame: frame)
        configure(deniedAuthorization: deniedAuthorization)
    }
    
    func configure(deniedAuthorization: DeniedAuthorizationType) {
        var title = ""
        
        switch deniedAuthorization {
        case .camera:           title = "keyboard_photos_access.denied.keyboard.camera"
        case .photos:           title = "keyboard_photos_access.denied.keyboard.photos"
        case .cameraAndPhotos:  title = "keyboard_photos_access.denied.keyboard.camera_and_photos"
        }
        
        descriptionLabel.text = title.localized
    }
    
    @objc private func openSettings() {
        guard let url = URL(string:UIApplicationOpenSettingsURLString), UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.openURL(url)
    }
    
    private func createConstraints() {
        
        constrain(self, containerView, descriptionLabel, settingsButton) { (selfView, container, description, settings) in
            
            description.leading == container.leading + 16
            description.trailing == container.trailing - 16
            description.top == container.top
            
            settings.height == 44.0
            settings.centerX == container.centerX
            settings.bottom == container.bottom
            settings.top == description.bottom + 24
            
            container.centerY == selfView.centerY
            container.leading == selfView.leading
            container.trailing == selfView.trailing
        }
    }

}
