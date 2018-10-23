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
import XCTest
import Wire
import HockeySDK

class AnalyticsTests : XCTestCase {
    
    func testThatItMigratesTheOptOutFromLocalytics() {
        // GIVEN
        TrackingManager.shared.disableCrashAndAnalyticsSharing = false
        UserDefaults.shared().set(false, forKey: "DidMigrateLocalyticsSettingInitially")
        Localytics.integrate(LocalyticsAPIKey)
        Localytics.setOptedOut(true)
        // WHEN
        XCTAssertFalse(TrackingManager.shared.disableCrashAndAnalyticsSharing)
        TrackingManager.shared.migrateFromLocalytics()
        // THEN
        XCTAssertTrue(TrackingManager.shared.disableCrashAndAnalyticsSharing)
        XCTAssertTrue(UserDefaults.shared().bool(forKey: "DidMigrateLocalyticsSettingInitially"))
    }
    
    func testThatItMigratesTheOptOutFromLocalytics_Once() {
        // GIVEN
        UserDefaults.shared().set(true, forKey: "DidMigrateLocalyticsSettingInitially")
        Localytics.setOptedOut(true)
        TrackingManager.shared.disableCrashAndAnalyticsSharing = false
        // WHEN
        XCTAssertFalse(TrackingManager.shared.disableCrashAndAnalyticsSharing)
        TrackingManager.shared.migrateFromLocalytics()
        // THEN
        XCTAssertFalse(TrackingManager.shared.disableCrashAndAnalyticsSharing)
    }
    
    func testThatItSetsOptOutOnHockey() {
        // GIVEN
        TrackingManager.shared.disableCrashAndAnalyticsSharing = false
        
        // WHEN
        TrackingManager.shared.disableCrashAndAnalyticsSharing = true
        
        // THEN
        XCTAssertTrue(BITHockeyManager.shared().isCrashManagerDisabled)
    }
    
    func testThatItSetsOptOutToSharedSettings() {
        // GIVEN
        TrackingManager.shared.disableCrashAndAnalyticsSharing = false
        // THEN
        XCTAssertFalse(ExtensionSettings.shared.disableCrashAndAnalyticsSharing)
        // WHEN
        TrackingManager.shared.disableCrashAndAnalyticsSharing = true
        // THEN
        XCTAssertTrue(ExtensionSettings.shared.disableCrashAndAnalyticsSharing)
    }
    
}
