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


/**
 Available settings
 
 - ChatHeadsDisabled:      Disable chat heads in conversation and self profile
 - DisableMarkdown:        Disable markdown formatter for messages
 - SkipFirstTimeUseChecks: Temporarily skip firts time checks
 - PreferredFlashMode:     Flash mode for internal camera UI
 - DarkMode:               Dark mode for conversation
 - PriofileName:           User name
 - SoundAlerts:            Sound alerts level
 - DisableCrashAndAnalyticsSharing: Opt-Out analytics and Hockey
 - DisableSendButton:      Opt-Out of new send button
 - DisableLinkPreviews:    Disable link previews for links you send
 - Disable(.*):            Disable some app features (debug)
 */
public enum SettingsPropertyName: String, CustomStringConvertible {
    
    // User defaults
    case chatHeadsDisabled = "ChatHeadsDisabled"
    case notificationContentVisible = "NotificationContentVisible"
    case disableMarkdown = "Markdown"
    
    case skipFirstTimeUseChecks = "SkipFirstTimeUseChecks"
    
    case preferredFlashMode = "PreferredFlashMode"
    
    case darkMode = "DarkMode"
    
    case disableSendButton = "DisableSendButton"
    
    case disableLinkPreviews = "DisableLinkPreviews"
    
    // Profile
    case profileName = "ProfileName"
    case accentColor = "AccentColor"
    
    // AVS
    case soundAlerts = "SoundAlerts"
    case callingConstantBitRate = "constantBitRate"
    
    // Analytics
    case disableCrashAndAnalyticsSharing = "DisableCrashAndAnalyticsSharing"
    
    // Sounds
    case messageSoundName = "MessageSoundName"
    case callSoundName = "CallSoundName"
    case pingSoundName = "PingSoundName"
    
    // Open In
    case tweetOpeningOption = "TweetOpeningOption"
    case mapsOpeningOption = "MapsOpeningOption"
    case browserOpeningOption = "BrowserOpeningOption"
    
    // Debug
    case disableCallKit = "DisableCallKit"
    case callingProtocolStrategy = "CallingProtcolStrategy"
    case enableBatchCollections = "EnableBatchCollections"
    
    case lockApp = "lockApp"
    case lockAppLastDate = "lockAppLastDate"
    
    public var changeNotificationName: String {
        return self.description + "ChangeNotification"
    }
    
    public var description: String {
        return self.rawValue;
    }
}

