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


@import WireExtensionComponents;


#import "ConversationInputBarSendController.h"
#import "ZMUserSession+iOS.h"
#import "Analytics.h"
#import "AnalyticsTracker+Media.h"
#import "Message+Formatting.h"
#import "LinkAttachment.h"
#import "NSString+Mentions.h"
#import "Settings.h"
#import "Wire-Swift.h"


@interface ConversationInputBarSendController ()

@property (nonatomic, readwrite) ZMConversation *conversation;
@property (nonatomic) UIImpactFeedbackGenerator* feedbackGenerator;

@end

@implementation ConversationInputBarSendController
//lining-mark1
- (instancetype)initWithConversation:(ZMConversation *) conversation
{
    self = [super init];
    if (self) {
        self.conversation = conversation;
        
        if (nil != [UIImpactFeedbackGenerator class]) {
            self.feedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
        }
    }
    return self;
}

-(void)sendMessageWithImageData:(NSData *)imageData completion:(dispatch_block_t)completionHandler
{
  
    if (imageData != nil) {
        [self.feedbackGenerator prepare];
        [[ZMUserSession sharedSession] enqueueChanges:^{
            [self.conversation appendMessageWithImageData:imageData];  //发送图片
            [self.feedbackGenerator impactOccurred];
        } completionHandler:^{
            if (completionHandler){
                completionHandler();
            }
            [[Analytics shared] tagMediaAction:ConversationMediaActionPhoto inConversation:self.conversation];
            [[Analytics shared] tagMediaActionCompleted:ConversationMediaActionPhoto inConversation:self.conversation];

        }];
    }
}

//发送文本接口

- (void)sendTextMessage:(NSString *)text
{
    [AppDelegate checkNetworkAndFlashIndicatorIfNecessary];
    BOOL shouldFetchLinkPreview = ![Settings sharedSettings].disableLinkPreviews;
    __block id<ZMConversationMessage> textMessage = nil;
    [[ZMUserSession sharedSession] enqueueChanges:^{
        if([Settings sharedSettings].shouldSend500Messages) {
            [Settings sharedSettings].shouldSend500Messages = NO;
            // This is a debug function to stress-load the client
            for(int i = 0; i < 500; ++i) {
                NSString *textWithNumber = [NSString stringWithFormat:@"%@ (%d)", text, i+1];
                // only save last ones, who cares
                textMessage = [self.conversation appendMessageWithText:textWithNumber fetchLinkPreview:shouldFetchLinkPreview];
                [(ZMMessage *)textMessage removeExpirationDate];
            }
        }
        else {
            // normal sending
           textMessage =
            [self.conversation appendMessageWithText:text fetchLinkPreview:shouldFetchLinkPreview];
        }
        self.conversation.draftMessageText = @"";
    } completionHandler:^{
        [[Analytics shared] tagMediaAction:ConversationMediaActionText inConversation:self.conversation];
        [[Analytics shared] tagMediaActionCompleted:ConversationMediaActionText inConversation:self.conversation];
        [self tagExternalLinkPostEventsForMessage:textMessage];
    }];
}

- (void)sendTextMessage:(NSString *)text withImageData:(NSData *)data
{
    [AppDelegate checkNetworkAndFlashIndicatorIfNecessary];
    __block id <ZMConversationMessage> textMessage = nil;
    BOOL shouldFetchLinkPreview = ![Settings sharedSettings].disableLinkPreviews;
    [ZMUserSession.sharedSession enqueueChanges:^{
        textMessage = [self.conversation appendMessageWithText:text fetchLinkPreview:shouldFetchLinkPreview];
        [self.conversation appendMessageWithImageData:data];
        self.conversation.draftMessageText = @"";
    } completionHandler:^{
        [[Analytics shared] tagMediaAction:ConversationMediaActionPhoto inConversation:self.conversation];
        [[Analytics shared] tagMediaActionCompleted:ConversationMediaActionPhoto inConversation:self.conversation];
        [[Analytics shared] tagMediaAction:ConversationMediaActionText inConversation:self.conversation];
        [[Analytics shared] tagMediaActionCompleted:ConversationMediaActionText inConversation:self.conversation];
        [[Analytics shared] tagMediaSentPictureSourceOtherInConversation:self.conversation source:ConversationMediaPictureSourceGiphy];
        [self tagExternalLinkPostEventsForMessage:textMessage];
    }];
}

- (void)tagExternalLinkPostEventsForMessage:(id <ZMConversationMessage>)message
{
    for (LinkAttachment *attachment in [Message linkAttachments:message.textMessageData]) {
        [self.analyticsTracker tagExternalLinkPostEventForAttachmentType:attachment.type
                                                        conversationType:self.conversation.conversationType];
    }
}

- (void)sendMentionsToUsersInMessage:(NSString *)text
{
    NSArray *mentionedUsers = [text usersMatchingMentions:self.conversation.activeParticipants.array strict:YES];
    NSPredicate *filterSelfUserPredicate = [NSPredicate predicateWithFormat:@"SELF != %@", [ZMUser selfUser]];
    NSArray *usersToPing = [mentionedUsers filteredArrayUsingPredicate:filterSelfUserPredicate];
    [usersToPing enumerateObjectsUsingBlock:^(id participant, NSUInteger idx, BOOL *stop) {
        ZMUser *user = (ZMUser *) participant;
        ZMConversation *conversation = user.oneToOneConversation;
        [[ZMUserSession sharedSession] enqueueChanges:^{
            [conversation appendKnock];
            [[Analytics shared] tagMediaActionCompleted:ConversationMediaActionPing inConversation:self.conversation];
        }];
        
        [self sendTextMessage:[NSString stringWithFormat:@"I want your attention in %@", self.conversation.displayName]];
    }];
}

@end
