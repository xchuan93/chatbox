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


#import <Foundation/Foundation.h>

FOUNDATION_EXTERN NSString *const AnalyticsContextKey;
FOUNDATION_EXTERN NSString *const AnalyticsMethodKey;

#pragma mark - AnalyticsContext

FOUNDATION_EXTERN NSString *const AnalyticsContextSignIn;
FOUNDATION_EXTERN NSString *const AnalyticsContextProfile;
FOUNDATION_EXTERN NSString *const AnalyticsContextPostLogin;
FOUNDATION_EXTERN NSString *const AnalyticsContextConversation;
FOUNDATION_EXTERN NSString *const AnalyticsContextRegistrationPhone;
FOUNDATION_EXTERN NSString *const AnalyticsContextRegistrationEmail;

#pragma mark - AnalyticsEventTypes

FOUNDATION_EXTERN NSString *const AnalyticsEventTypePermissions;
FOUNDATION_EXTERN NSString *const AnalyticsEventTypeMedia;

#pragma mark - AnalyticsEventTypePermissions

FOUNDATION_EXTERN NSString *const AnalyticsEventTypePermissionsCategoryKey;
FOUNDATION_EXTERN NSString *const AnalyticsEventTypePermissionsStateKey;

FOUNDATION_EXTERN NSString *const AnalyticsEventTypePermissionsCategoryCamera;
FOUNDATION_EXTERN NSString *const AnalyticsEventTypePermissionsCategoryPushNotifications;

FOUNDATION_EXTERN NSString *const AnalyticsEventTypePermissionsStateAllowed;
FOUNDATION_EXTERN NSString *const AnalyticsEventTypePermissionsStateDenied;

#pragma mark - AnalyticsEventTypeLinkVisit

FOUNDATION_EXTERN NSString *const AnalyticsEventMediaLinkTypeKey;

FOUNDATION_EXTERN NSString *const AnalyticsEventMediaLinkTypeNone;
FOUNDATION_EXTERN NSString *const AnalyticsEventMediaLinkTypeYouTube;
FOUNDATION_EXTERN NSString *const AnalyticsEventMediaLinkTypeVimeo;
FOUNDATION_EXTERN NSString *const AnalyticsEventMediaLinkTypeSoundCloud;

FOUNDATION_EXTERN NSString *const AnalyticsEventMediaActionKey;
FOUNDATION_EXTERN NSString *const AnalyticsEventMediaActionPosted;
FOUNDATION_EXTERN NSString *const AnalyticsEventMediaActionVisited;

FOUNDATION_EXTERN NSString *const AnalyticsEventConversationTypeKey;
FOUNDATION_EXTERN NSString *const AnalyticsEventConversationTypeGroup;
FOUNDATION_EXTERN NSString *const AnalyticsEventConversationTypeOneToOne;
FOUNDATION_EXTERN NSString *const AnalyticsEventConversationTypeUnknown;


#pragma mark - Invitations

FOUNDATION_EXTERN NSString *const AnalyticsEventInviteContactListOpened;
FOUNDATION_EXTERN NSString *const AnalyticsEventInvitationSentToAddressBook;
FOUNDATION_EXTERN NSString *const AnalyticsEventInvitationSentToAddressBookMethodEmail;
FOUNDATION_EXTERN NSString *const AnalyticsEventInvitationSentToAddressBookMethodPhone;
FOUNDATION_EXTERN NSString *const AnalyticsEventInvitationSentToAddressBookFromSearch;
FOUNDATION_EXTERN NSString *const AnalyticsEventOpenedMenuForGenericInvite;
FOUNDATION_EXTERN NSString *const AnalyticsEventAcceptedGenericInvite;

@interface AnalyticsTracker : NSObject

@property (nonatomic, copy, readonly) NSString *context;

+ (instancetype)analyticsTrackerWithContext:(NSString *)context;

- (void)tagEvent:(NSString *)event;
- (void)tagEvent:(NSString *)event attributes:(NSDictionary *)attributes;

@end
