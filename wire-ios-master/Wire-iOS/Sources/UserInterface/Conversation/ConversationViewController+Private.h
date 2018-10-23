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


#import "WAZUIMagicIOS.h"
#import "WireSyncEngine+iOS.h"

NS_ASSUME_NONNULL_BEGIN

@class ConversationInputBarViewController;
@class ConversationDetailsTransitioningDelegate;
@class CollectionsViewController;
@class AnalyticsTracker;

@interface ConversationViewController (Private)

@property (nonatomic, readonly) ConversationContentViewController *contentViewController;
@property (nonatomic, readonly) ConversationInputBarViewController *inputBarController;
@property (nonatomic, readonly) UIViewController *participantsController;
@property (nonatomic, readonly) AnalyticsTracker *analyticsTracker;
@property (nonatomic, readonly) ConversationDetailsTransitioningDelegate *conversationDetailsTransitioningDelegate;
@property (nonatomic, nullable) CollectionsViewController *collectionController;

- (void)onBackButtonPressed:(UIButton *)backButton;

@end

NS_ASSUME_NONNULL_END
