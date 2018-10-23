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

import Foundation

fileprivate let ZMEnableConsoleLog = "ZMEnableAnalyticsLog"

@objc class AnalyticsProviderFactory: NSObject {
    @objc public static let shared = AnalyticsProviderFactory()
    @objc public static let ZMConsoleAnalyticsArgumentKey = "-ConsoleAnalytics"

    @objc public var useConsoleAnalytics: Bool = false
  
    @objc public func analyticsProvider() -> AnalyticsProvider? {
        if self.useConsoleAnalytics || UserDefaults.standard.bool(forKey: ZMEnableConsoleLog) {
            return AnalyticsConsoleProvider()
        }
        else if UseAnalytics.boolValue || AutomationHelper.sharedHelper.useAnalytics {
            return AnalyticsMixpanelProvider()
        }
        else {
            return nil
        }
    }
}

