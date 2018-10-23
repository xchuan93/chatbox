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

class DefaultNavigationBar : UINavigationBar {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configure()
    }
    
    func configure() {
        isTranslucent = false
        tintColor = ColorScheme.default().color(withName: ColorSchemeColorTextForeground)
        barTintColor = ColorScheme.default().color(withName: ColorSchemeColorBarBackground)
        setBackgroundImage(UIImage.singlePixelImage(with: ColorScheme.default().color(withName: ColorSchemeColorBarBackground)), for: .default)
        shadowImage = UIImage.singlePixelImage(with: UIColor.clear)
        titleTextAttributes = [NSFontAttributeName: FontSpec(.small, .semibold).font!,
                               NSForegroundColorAttributeName: ColorScheme.default().color(withName: ColorSchemeColorTextForeground)]
        setTitleVerticalPositionAdjustment(-2.0, for: .default)
        backIndicatorImage = UIImage(for: .backArrow, iconSize: .tiny, color: ColorScheme.default().color(withName: ColorSchemeColorTextForeground)).withInsets(UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0), backgroundColor: .clear)
        backIndicatorTransitionMaskImage = UIImage(for: .backArrow, iconSize: .tiny, color: .black)
    }
    
}

extension UIViewController {
    
    func wrapInNavigationController() -> UINavigationController {
        return self.wrapInNavigationController(RotationAwareNavigationController.self)
    }
    
    func wrapInNavigationController(_ navigationControllerClass: UINavigationController.Type) -> UINavigationController {
        let navigationController = navigationControllerClass.init(navigationBarClass: DefaultNavigationBar.self, toolbarClass: nil)
        navigationController.setViewControllers([self], animated: false)
        return navigationController
    }
    
}
