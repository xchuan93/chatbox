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

class SettingsStyleNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.setBackgroundImage(UIImage(color: .black, andSize: CGSize(width: 1,height: 1)), for:.default)
        self.navigationBar.isTranslucent = false
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(magicIdentifier: "style.text.normal.font_spec_bold").smallCaps()]
        
        let navButtonAppearance = UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self])
        
        let attributes = [NSFontAttributeName : UIFont(magicIdentifier: "style.text.normal.font_spec").smallCaps()]
        navButtonAppearance.setTitleTextAttributes(attributes, for: UIControlState.normal)
        navButtonAppearance.setTitleTextAttributes(attributes, for: UIControlState.highlighted)
        
    }
}
