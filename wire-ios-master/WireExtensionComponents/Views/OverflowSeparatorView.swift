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
import Cartography
import Classy


@objc public class OverflowSeparatorView: UIView {

    public var inverse: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.applyStyle()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.applyStyle()
    }
    
    private func applyStyle() {
        self.backgroundColor = ColorScheme.default().color(withName: ColorSchemeColorSeparator)
        self.alpha = 0
    }
    
    override open var intrinsicContentSize: CGSize {
        get {
            return CGSize(width: UIViewNoIntrinsicMetric, height: .hairline)
        }
    }
    
    @objc(scrollViewDidScroll:)
    public func scrollViewDidScroll(scrollView: UIScrollView!) {
        if inverse {
            let (height, contentHeight) = (scrollView.bounds.height, scrollView.contentSize.height)
            let offsetY = scrollView.contentOffset.y
            let showSeparator = contentHeight - offsetY > height
            alpha = showSeparator ? 1 : 0
        }
        else {
            self.alpha = scrollView.contentOffset.y > 0 ? 1 : 0
        }
    }
}

