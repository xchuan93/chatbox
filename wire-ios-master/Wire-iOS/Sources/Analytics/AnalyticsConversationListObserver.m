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


#import "AnalyticsConversationListObserver.h"

#import "Analytics.h"
#import <WireSyncEngine/WireSyncEngine.h>
#import "ZMUser+Additions.h"

#import "avs+iOS.h"
#import "Wire-Swift.h"


#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#endif




const NSTimeInterval PermantentConversationListObserverObservationTime = 10.0f;
const NSTimeInterval PermantentConversationListObserverObservationFinalTime = 20.0f;



@interface AnalyticsConversationListObserver () <ZMConversationListObserver>

@property (nonatomic, strong) NSDate *observationStartDate;
@property (nonatomic, strong) Analytics *analytics;
@property (nonatomic) id conversationListObserverToken;

@end



@implementation AnalyticsConversationListObserver

- (instancetype)initWithAnalytics:(Analytics *)analytics
{
    self = [super init];
    if (self) {

        self.analytics = analytics;
    }
    return self;
}

- (void)setObserving:(BOOL)observing
{
    if (_observing == observing) {
        return;
    }

    _observing = observing;

    if (self.observing) {
        self.observationStartDate = [NSDate date];

        self.conversationListObserverToken = [ConversationListChangeInfo addObserver:self
                                                                             forList:[ZMConversationList conversationsIncludingArchivedInUserSession:[ZMUserSession sharedSession]]
                                                                         userSession:[ZMUserSession sharedSession]];
        
        [self performSelector:@selector(probablyReceivedFullConversationList)
                   withObject:nil
                   afterDelay:PermantentConversationListObserverObservationFinalTime];
    } else {
        self.conversationListObserverToken = nil;
    }
}

- (void)probablyReceivedFullConversationList
{
    if (nil == ZMUserSession.sharedSession.managedObjectContext) {
        return;
    }

    NSUInteger groupConvCount = 0;

    for (ZMConversation *conversation in [ZMConversationList conversationsIncludingArchivedInUserSession:[ZMUserSession sharedSession]]) {
        if (conversation.conversationType == ZMConversationTypeGroup) {
            groupConvCount ++;
        }
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:[ZMUser entityName]];
    fetchRequest.predicate = [ZMUser predicateForConnectedNonBotUsers];
    NSUInteger contactsCount = [[ZMUserSession sharedSession].managedObjectContext countForFetchRequest:fetchRequest error:nil];
    
    [self.analytics sendCustomDimensionsWithNumberOfContacts:contactsCount
                                          groupConversations:groupConvCount];

    self.observing = NO;
}

#pragma mark - ZMConversationListObserver

- (void)conversationListDidChange:(ConversationListChangeInfo *)change
{
    NSTimeInterval timeFromStart = [NSDate timeIntervalSinceReferenceDate] - [self.observationStartDate timeIntervalSinceReferenceDate];

    if (timeFromStart > PermantentConversationListObserverObservationTime) {
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(probablyReceivedFullConversationList) object:nil];
        [self probablyReceivedFullConversationList];
    }
}

@end
