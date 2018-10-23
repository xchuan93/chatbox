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


private enum ExtensionSettingsKey: String {

    case disableCrashAndAnalyticsSharing = "disableCrashAndAnalyticsSharing"
    case disableLinkPreviews = "disableLinkPreviews"

    static var all: [ExtensionSettingsKey] {
        return [
            .disableLinkPreviews,
            .disableCrashAndAnalyticsSharing
        ]
    }

    private var defaultValue: Any? {
        switch self {
        // In case the user opted out and we did not yet migrate the opt out value
        // into the shared settings (which is only done from the main app).
        case .disableCrashAndAnalyticsSharing: return false
        case .disableLinkPreviews: return false
        }
    }

    static var defaultValueDictionary: [String: Any] {
        return all.reduce([:]) { result, current in
            var mutableResult = result
            mutableResult[current.rawValue] = current.defaultValue
            return mutableResult
        }
    }

}


private let defaults = UserDefaults.shared()!


public class ExtensionSettings: NSObject {

    public static let shared = ExtensionSettings()

    private override init() {
        super.init()
        type(of: self).setupDefaultValues()
    }

    private static func setupDefaultValues() {
        defaults.register(defaults: ExtensionSettingsKey.defaultValueDictionary)
    }

    public func reset() {
        ExtensionSettingsKey.all.forEach {
            defaults.removeObject(forKey: $0.rawValue)
        }

        // As we purposely crash afterwards we manually call synchronize.
        defaults.synchronize()
    }

    public var disableCrashAndAnalyticsSharing: Bool {
        get {
            return defaults.bool(forKey: ExtensionSettingsKey.disableCrashAndAnalyticsSharing.rawValue)
        }

        set {
            defaults.set(newValue, forKey: ExtensionSettingsKey.disableCrashAndAnalyticsSharing.rawValue)
        }
    }
    
    public var disableLinkPreviews: Bool {
        get {
            return defaults.bool(forKey: ExtensionSettingsKey.disableLinkPreviews.rawValue)
        }
        
        set {
            defaults.set(newValue, forKey: ExtensionSettingsKey.disableLinkPreviews.rawValue)
        }
    }
}
