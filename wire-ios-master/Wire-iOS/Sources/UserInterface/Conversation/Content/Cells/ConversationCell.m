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


#import "ConversationCell.h"
#import "ConversationCell+Private.h"

@import PureLayout;

#import "WAZUIMagicIOS.h"
#import "UIColor+WAZExtensions.h"
#import "Message+UI.h"
#import "UIColor+WR_ColorScheme.h"
#import "UIView+Borders.h"
#import "Wire-Swift.h"
#import "UserImageView.h"
#import "AccentColorChangeHandler.h"
#import "Analytics.h"
#import "Analytics+ConversationEvents.h"
#import "UIResponder+FirstResponder.h"
#import "UserImageView+Magic.h"
#import "UIScreen+Compact.h"

const CGFloat ConversationCellSelectedOpacity = 0.4;
const NSTimeInterval ConversationCellSelectionAnimationDuration = 0.33;
static const CGFloat BurstContainerExpandedHeight = 40;

@implementation MenuConfigurationProperties

@end

@implementation ConversationCellLayoutProperties

@end



@interface ConversationCell ()

@property (nonatomic, readwrite) id<ZMConversationMessage>message;
@property (nonatomic, readwrite) UIView *messageContentView;

@property (nonatomic, readwrite) UILabel *authorLabel;
@property (nonatomic, readwrite) UIView *marginContainer;
@property (nonatomic, readwrite) NSParagraphStyle *authorParagraphStyle;

@property (nonatomic, readwrite) UserImageView *authorImageView;
@property (nonatomic, readwrite) UIView *authorImageContainer;

@property (nonatomic) MessageToolboxView *toolboxView;

@property (nonatomic) AccentColorChangeHandler *accentColorChangeHandler;
@property (nonatomic, readwrite) UITapGestureRecognizer *doubleTapGestureRecognizer;
@property (nonatomic, readwrite) ConversationCellLayoutProperties *layoutProperties;

#pragma mark - Constraints

@property (nonatomic) NSLayoutConstraint *authorHeightConstraint;
@property (nonatomic) NSLayoutConstraint *authorLeftMarginConstraint;

@property (nonatomic) NSLayoutConstraint *authorImageTopMarginConstraint;
@property (nonatomic) NSLayoutConstraint *authorImageHeightConstraint;

@property (nonatomic) NSLayoutConstraint *burstTimestampHeightConstraint;
@property (nonatomic) NSLayoutConstraint *topMarginConstraint;
@property (nonatomic) NSLayoutConstraint *messageToolsHeightConstraint;

@property (nonatomic) NSLayoutConstraint *toolboxCollapseConstraint;

@property (nonatomic) BOOL countdownContainerViewHidden;
@property (nonatomic) UIView *countdownContainerView;
@property (nonatomic) DestructionCountdownView *countdownView;
@property (nonatomic) CADisplayLink *destructionLink;

@end

@interface ConversationCell (MessageToolboxViewDelegate) <MessageToolboxViewDelegate>

@end

@implementation ConversationCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.clipsToBounds = YES;
        self.tintColor = [UIColor accentColor];
        self.layoutMargins = UIEdgeInsetsZero;
        self.burstTimestampSpacing = 16;
        
        [self createViews];

        self.contentLayoutMargins = self.class.layoutDirectionAwareLayoutMargins;

        [NSLayoutConstraint autoCreateAndInstallConstraints:^{
            [self createBaseConstraints];
        }];
        
        self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        [self.contentView addGestureRecognizer:self.longPressGestureRecognizer];

        self.accentColorChangeHandler = [AccentColorChangeHandler addObserver:self handlerBlock:^(UIColor *newColor, ConversationCell *cell) {
            cell.tintColor = newColor;
        }];
        
    }
    
    return self;
}

- (void)dealloc
{
    [self.burstTimestampTimer invalidate];
    self.burstTimestampTimer = nil;
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];
    
    if (newWindow != nil) {
        [self scheduledTimerForUpdateBurstTimestamp];
    } else {
        [self.burstTimestampTimer invalidate];
        self.burstTimestampTimer = nil;
    }
}

- (void)createViews
{
    self.clipsToBounds = NO;
    self.contentView.clipsToBounds = NO;
    
    self.marginContainer = [[UIView alloc] init];
    self.marginContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.marginContainer];

    self.messageContentView = [[UIView alloc] init];
    self.messageContentView.translatesAutoresizingMaskIntoConstraints = NO;
    self.messageContentView.accessibilityElementsHidden = NO;
    [self.contentView addSubview:self.messageContentView];

    self.authorLabel = [[UILabel alloc] init];
    self.authorLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.marginContainer addSubview:self.authorLabel];

    self.authorImageContainer = [[UIView alloc] init];
    self.authorImageContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.marginContainer addSubview:self.authorImageContainer];
    
    self.authorImageView = [[UserImageView alloc] initWithMagicPrefix:@"content.author_image"];
    self.authorImageView.userSession = [ZMUserSession sharedSession];
    self.authorImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.authorImageView.delegate = self;
    
    self.authorImageView.layer.shouldRasterize = YES;
    self.authorImageView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    [self.authorImageContainer addSubview:self.authorImageView];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.minimumLineHeight = [WAZUIMagic cgFloatForIdentifier:@"content.burst_timestamp.line_height"];
    paragraphStyle.maximumLineHeight = paragraphStyle.minimumLineHeight;

    self.burstTimestampView = [[ConversationCellBurstTimestampView alloc] initForAutoLayout];
    self.burstTimestampView.isSeparatorHidden = YES;
    [self.contentView addSubview:self.burstTimestampView];

    
    self.toolboxView = [[MessageToolboxView alloc] init];
    self.toolboxView.delegate = self;
    self.toolboxView.translatesAutoresizingMaskIntoConstraints = NO;
    self.toolboxView.accessibilityIdentifier = @"MessageToolbox";
    self.toolboxView.accessibilityLabel = @"MessageToolbox";
    [self.contentView addSubview:self.toolboxView];
    
    self.countdownContainerView = [[UIView alloc] initForAutoLayout];
    [self.contentView addSubview:self.countdownContainerView];
    
    self.countdownContainerViewHidden = YES;
    
    [self createLikeButton];
    
    self.doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleTapMessage:)];
    self.doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    self.doubleTapGestureRecognizer.delaysTouchesBegan = YES;
    [self.contentView addGestureRecognizer:self.doubleTapGestureRecognizer];
    
    self.contentView.isAccessibilityElement = YES;
    
    NSMutableArray *accessibilityElements = [NSMutableArray arrayWithArray:self.accessibilityElements];
    [accessibilityElements addObjectsFromArray:@[self.messageContentView, self.authorLabel, self.authorImageView, self.burstTimestampView.unreadDot, self.toolboxView, self.likeButton]];
    self.accessibilityElements = accessibilityElements;

    [CASStyler.defaultStyler styleItem:self];
}

- (void)prepareForReuse
{
    self.message = nil;
    [self.toolboxView prepareForReuse];
    
    [super prepareForReuse];
    
    self.topMarginConstraint.constant = 0;
    self.authorImageTopMarginConstraint.constant = 0;
    self.beingEdited = NO;
    [self updateCountdownView];
}

- (void)didEndDisplayingInTableView
{
    [self.burstTimestampTimer invalidate];
    self.burstTimestampTimer = nil;
    [self tearDownCountdownLink];
}

- (void)createBaseConstraints
{
    CGFloat authorImageDiameter = [WAZUIMagic floatForIdentifier:@"content.sender_image_tile_diameter"];

    self.topMarginConstraint = [self.burstTimestampView autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [self.burstTimestampView autoPinEdgeToSuperviewEdge:ALEdgeLeading];
    [self.burstTimestampView autoPinEdgeToSuperviewEdge:ALEdgeTrailing];

    [NSLayoutConstraint autoSetPriority:UILayoutPriorityRequired forConstraints:^{
        self.burstTimestampHeightConstraint = [self.burstTimestampView autoSetDimension:ALDimensionHeight toSize:0];
    }];

    [self.marginContainer autoPinEdgesToSuperviewEdges];
    [self.authorLabel autoPinEdgeToSuperviewMargin:ALEdgeLeading];

    self.authorHeightConstraint = [self.authorLabel autoSetDimension:ALDimensionHeight toSize:0];
    [self.authorLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.authorImageContainer];
    [self.authorLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    
    self.authorImageHeightConstraint = [self.authorImageView autoSetDimension:ALDimensionHeight toSize:0];
    self.authorHeightConstraint.active = NO;
    self.authorImageView.layer.cornerRadius = authorImageDiameter / 2;
    [self.authorImageView autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [self.authorImageView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [self.authorImageView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionHeight ofView:self.authorImageView];
    [self.authorImageView autoCenterInSuperview];
    
    self.authorImageTopMarginConstraint = [self.authorImageContainer autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.burstTimestampView];
    [self.authorImageContainer autoPinEdgeToSuperviewEdge:ALEdgeLeading];
    [self.authorImageContainer autoPinEdge:ALEdgeTrailing toEdge:ALEdgeLeading ofView:self.authorLabel];

    [self.messageContentView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.authorImageView];
    [self.messageContentView autoPinEdgeToSuperviewEdge:ALEdgeLeading];
    [self.messageContentView autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
    
    [NSLayoutConstraint autoSetPriority:UILayoutPriorityRequired forConstraints:^{
        [self.authorImageView autoSetDimension:ALDimensionHeight toSize:authorImageDiameter];
    }];
    
    [NSLayoutConstraint autoSetPriority:UILayoutPriorityDefaultHigh + 1 forConstraints:^{
        self.toolboxCollapseConstraint = [self.toolboxView autoSetDimension:ALDimensionHeight toSize:0];
    }];
    
    [self.toolboxView autoSetDimension:ALDimensionHeight toSize:0 relation:NSLayoutRelationGreaterThanOrEqual];
    [self.toolboxView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.messageContentView];
    [self.toolboxView autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
    [self.toolboxView autoPinEdgeToSuperviewEdge:ALEdgeLeading];
    [self.toolboxView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    
    [self.likeButton autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.toolboxView];
    [self.likeButton autoAlignAxis:ALAxisVertical toSameAxisOfView:self.authorImageContainer];
    
    [self.countdownContainerView autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:8];
}

- (void)setContentLayoutMargins:(UIEdgeInsets)contentLayoutMargins
{
    _contentLayoutMargins = contentLayoutMargins;
    
    // NOTE Layout margins are not being preserved beyond the UITableViewCell.contentView so we must re-apply them
    // here until we re-factor the the ConversationCell

    self.marginContainer.layoutMargins = contentLayoutMargins;
    self.messageContentView.layoutMargins = contentLayoutMargins;
    self.toolboxView.layoutMargins = contentLayoutMargins;
    self.burstTimestampView.layoutMargins = contentLayoutMargins;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!self.countdownContainerViewHidden) {
        self.countdownContainerView.layer.cornerRadius = CGRectGetWidth(self.countdownContainerView.bounds) / 2;
    }
    
    [self.contentView layoutIfNeeded];
}

- (void)updateConstraintConstants
{
    ConversationCellLayoutProperties *properties = self.layoutProperties;
    BOOL showBurstLabelContainer                 =   properties.showBurstTimestamp || properties.showDayBurstTimestamp;

    self.burstTimestampView.isShowingUnreadDot   =   properties.showUnreadMarker;
    self.authorImageHeightConstraint.active      = ! properties.showSender;
    self.authorImageTopMarginConstraint.constant =   showBurstLabelContainer ? self.burstTimestampSpacing : 0;
    self.topMarginConstraint.constant            =   properties.topPadding;
    self.authorHeightConstraint.active           = ! properties.showSender;
    self.authorLabel.hidden                      = ! properties.showSender;
    self.authorImageContainer.hidden             = ! properties.showSender;
    self.burstTimestampHeightConstraint.constant =   showBurstLabelContainer ? BurstContainerExpandedHeight : 0;
    self.burstTimestampView.isSeparatorExpanded  =   properties.showDayBurstTimestamp;
}

- (void)configureForMessage:(id<ZMConversationMessage>)message layoutProperties:(ConversationCellLayoutProperties *)layoutProperties;
{
    _message = message;

    _layoutProperties = layoutProperties;

    if (layoutProperties.showSender) {
        [self updateSenderAndSenderImage:message];
    }
    
    if (layoutProperties.showBurstTimestamp || layoutProperties.showDayBurstTimestamp) {
        [self updateBurstTimestamp];
    }
    
    [self configureLikeButtonForMessage:message];
    
    [self updateConstraintConstants];
    [self updateToolboxVisibilityAnimated:NO];
    [self startCountdownAnimationIfNeeded:message];
    [self updateCountdownView];
}

- (void)updateToolboxVisibilityAnimated:(BOOL)animated
{
    if (nil == self.message) {
        return;
    }
    
    ZMDeliveryState deliveryState = self.message.deliveryState;
    
    BOOL shouldShowPendingDeliveryState = self.message.conversation.conversationType == ZMConversationTypeOneOnOne;
    BOOL shouldShowDeliveryState = (deliveryState == ZMDeliveryStatePending && shouldShowPendingDeliveryState) || deliveryState == ZMDeliveryStateFailedToSend || self.layoutProperties.alwaysShowDeliveryState;
    BOOL shouldBeVisible = self.selected || self.message.usersReaction.count > 0 || shouldShowDeliveryState;
    
    if (! [Message shouldShowTimestamp:self.message]) {
        shouldBeVisible = NO;
    }
    
    BOOL hideLikeButton = !([Message hasLikers:self.message] || self.selected) && self.layoutProperties.alwaysShowDeliveryState;
    BOOL showLikeButton = [Message messageCanBeLiked:self.message] && !hideLikeButton;
    
    self.toolboxCollapseConstraint.active = ! shouldBeVisible;
    
    if (shouldBeVisible) {
        [self.toolboxView configureForMessage:self.message forceShowTimestamp:self.selected animated:animated];
    }
    
    if (animated) {
        if (shouldBeVisible) {
            [UIView animateWithDuration:0.35 animations:^{
                self.toolboxView.alpha = 1;
            } completion:^(BOOL finished) {
                if (self.toolboxView.alpha == 1) {
                    [UIView animateWithDuration:0.15 animations:^{
                        self.likeButton.alpha = showLikeButton ? 1 : 0;
                    }];
                }
            }];
        }
        else {
            self.likeButton.alpha = 0;
            [UIView animateWithDuration:0.35 animations:^{
                self.toolboxView.alpha = 0;
            }];
        }
    }
    else {
        [self.toolboxView.layer removeAllAnimations];
        [self.likeButton.layer removeAllAnimations];
        self.toolboxView.alpha = shouldBeVisible ? 1 : 0;
        self.likeButton.alpha = shouldBeVisible && showLikeButton ? 1 : 0;
    }
}


- (void)setCountdownContainerViewHidden:(BOOL)countdownContainerViewHidden
{
    if (countdownContainerViewHidden == _countdownContainerViewHidden) {
        return;
    }
    
    _countdownContainerViewHidden = countdownContainerViewHidden;
    
    if (nil == self.countdownView) {
        if (!countdownContainerViewHidden) {
            self.countdownView = [[DestructionCountdownView alloc] init];
            self.countdownView.accessibilityLabel = @"EphemeralMessageCountdownView";
            [self.countdownContainerView addSubview:self.countdownView];
            [self.countdownView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
            self.countdownContainerView.layer.cornerRadius = CGRectGetWidth(self.countdownContainerView.bounds) / 2;
        }
    }
    else {
        self.countdownContainerView.hidden = countdownContainerViewHidden;
    }
    
}

#pragma mark - Size class

/**
 When iPad switches form/to slide over/fullscreen/split mode, update contentLayoutMargins

 @param previousTraitCollection previousTraitCollection
 */
- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection
{
    [super traitCollectionDidChange:previousTraitCollection];
    if (!self.showsPreview) {
        self.contentLayoutMargins = self.class.layoutDirectionAwareLayoutMargins;
    }
}

#pragma mark - Long press management

- (UIView *)selectionView
{
    return self;
}

- (CGRect)selectionRect
{
    return self.bounds;
}

- (UIView *)previewView
{
    return self.selectionView;
}

- (BOOL)canBecomeFirstResponder;
{
    return YES;
}

- (MenuConfigurationProperties *)menuConfigurationProperties;
{
    return nil;
}

- (MessageType)messageType;
{
    return MessageTypeSystem;
}

- (void)menuWillShow:(NSNotification *)notification
{
    self.showsMenu = YES;
    if (self.menuConfigurationProperties.selectedMenuBlock != nil ) {
        self.menuConfigurationProperties.selectedMenuBlock(YES, YES);
    }
}

- (void)menuDidHide:(NSNotification *)notification
{
    self.showsMenu = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.menuConfigurationProperties.selectedMenuBlock != nil && !self.beingEdited) {
        self.menuConfigurationProperties.selectedMenuBlock(NO, YES);
    }
}

- (void)setBeingEdited:(BOOL)beingEdited
{
    if (_beingEdited == beingEdited) {
        return;
    }
    
    _beingEdited = beingEdited;
    
    if (self.menuConfigurationProperties.selectedMenuBlock != nil) {
        self.menuConfigurationProperties.selectedMenuBlock(beingEdited, YES);
    }
}

- (void)showMenu;
{
    // ephemeral message's only possibility is to be deleted
    if (self.message.isEphemeral && !self.message.canBeDeleted) {
        return;
    }

    BOOL shouldBecomeFirstResponder = YES;
    if ([self.delegate respondsToSelector:@selector(conversationCell:shouldBecomeFirstResponderWhenShowMenuWithCellType:)]) {
        shouldBecomeFirstResponder = [self.delegate conversationCell:self shouldBecomeFirstResponderWhenShowMenuWithCellType:[self messageType]];
    }
    
    MenuConfigurationProperties *menuConfigurationProperties = [self menuConfigurationProperties];
    if (!menuConfigurationProperties) {
        return;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuWillShow:)
                                                 name:UIMenuControllerWillShowMenuNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuDidHide:)
                                                 name:UIMenuControllerDidHideMenuNotification object:nil];
    
    /**
     *  The reason why we are touching the window here is to workaround a bug where,
     *  After dismissing the webplayer, the window would fail to become the first responder, 
     *  preventing us to show the menu at all. 
     *  We now force the window to be the key window and to be the first responder to ensure that we can 
     *  show the menu controller.
     */
    [self.window makeKeyWindow];
    [self.window becomeFirstResponder];

    if (shouldBecomeFirstResponder) {
        [self becomeFirstResponder];
    }
    
    UIMenuController *menuController = UIMenuController.sharedMenuController;
    
    NSMutableArray <UIMenuItem *> *items = [NSMutableArray array];
    
    if (!self.message.isEphemeral) {
        [items addObjectsFromArray:menuConfigurationProperties.additionalItems];
        
        if ([Message messageCanBeLiked:self.message]) {
            UIMenuItem *likeItem = [UIMenuItem likeItemForMessage:self.message action:@selector(likeMessage:)];
            
            if (items.count > 0) {
                [items insertObject:likeItem atIndex:menuConfigurationProperties.likeItemIndex];
            } else {
                [items addObject:likeItem];
            }
        }
    }

    // at this point, if message is ephemeral, then this will always be true
    if (self.message.canBeDeleted) {
        UIMenuItem *deleteItem = [UIMenuItem deleteItemWithAction:@selector(deleteMessage:)];
        [items addObject:deleteItem];
    }

    menuController.menuItems = items;
    [menuController setTargetRect:menuConfigurationProperties.targetRect inView:menuConfigurationProperties.targetView];
    [menuController setMenuVisible:YES animated:YES];

    if ([self.delegate respondsToSelector:@selector(conversationCell:didOpenMenuForCellType:)]) {
        [self.delegate conversationCell:self didOpenMenuForCellType:[self messageType]];
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer;
{
    if (! CGRectContainsPoint(self.contentView.bounds, [gestureRecognizer locationInView:self.contentView]) ||
        ! CGRectContainsPoint(self.menuConfigurationProperties.targetRect, [gestureRecognizer locationInView:self.menuConfigurationProperties.targetView])) {
        gestureRecognizer.enabled = NO;
        gestureRecognizer.enabled = YES;
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self showMenu];
    }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender;
{
    if (action == @selector(deleteMessage:) && self.message.canBeDeleted) {
        return YES;
    }
    
    if (action == @selector(likeMessage:)) {
        return YES;
    }
    
    if (action == @selector(copy:) && self.message.isEphemeral) {
        return NO;
    }
    
    return [super canPerformAction:action withSender:sender];
}

- (void)deleteMessage:(id)sender;
{
    self.beingEdited = YES;
    if([self.delegate respondsToSelector:@selector(conversationCell:didSelectAction:)]) {
        [self.delegate conversationCell:self didSelectAction:MessageActionDelete];
        [[Analytics shared] tagOpenedMessageAction:MessageActionTypeDelete];
    }
}

- (void)forward:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(conversationCell:didSelectAction:)]) {
        [self.delegate conversationCell:self didSelectAction:MessageActionForward];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    [self updateToolboxVisibilityAnimated:YES];
}

#pragma mark - UserImageView delegate

- (void)userImageViewTouchUpInside:(UserImageView *)userImageView
{
    if (! userImageView) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(conversationCell:userTapped:inView:)]) {
        [self.delegate conversationCell:self userTapped:BareUserToUser(userImageView.user) inView:userImageView];
    }
}

#pragma mark - Message observation

- (BOOL)updateForMessage:(MessageChangeInfo *)change
{
    if (change.reactionsChanged) {
        [self configureLikeButtonForMessage:change.message];
    }
    
    if (change.userChangeInfo.nameChanged || change.senderChanged) {
        [self updateSenderAndSenderImage:change.message];
    }

    if (change.isObfuscatedChanged) {
        [self configureForMessage:change.message layoutProperties:self.layoutProperties];
        [self updateCountdownView];
    }

    if ([self.delegate respondsToSelector:@selector(conversationCellShouldStartDestructionTimer:)] &&
        [self.delegate conversationCellShouldStartDestructionTimer:self]) {
        if ([self.message startSelfDestructionIfNeeded]) {
            [self startCountdownAnimationIfNeeded:self.message];
        }
    }

    [self updateToolboxVisibilityAnimated:change.reactionsChanged];
    
    return change.reactionsChanged || change.deliveryStateChanged || change.isObfuscatedChanged;
}

#pragma mark - Countdown Timer

- (void)tearDownCountdownLink
{
    [self.destructionLink invalidate];
    self.destructionLink = nil;
}

- (void)startCountdownAnimationIfNeeded:(id<ZMConversationMessage>)message
{
    if (self.showDestructionCountdown && nil == self.destructionLink) {
        self.destructionLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateCountdownView)];
        [self.destructionLink addToRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
    }
}

- (BOOL)showDestructionCountdown
{
    return !self.message.hasBeenDeleted && self.message.isEphemeral && !self.message.isObfuscated;
}

- (void)updateCountdownView
{
    self.countdownContainerViewHidden = !self.showDestructionCountdown;

    if (! self.showDestructionCountdown && nil != self.destructionLink) {
        [self tearDownCountdownLink];
        return;
    }

    if (!self.countdownContainerViewHidden && nil != self.message.destructionDate) {
        CGFloat fraction = self.message.destructionDate.timeIntervalSinceNow / self.message.deletionTimeout;
        [self.countdownView updateWithFraction:fraction];
        [self.toolboxView updateTimestamp:self.message];
    }
}

@end

@implementation ConversationCell (MessageToolboxViewDelegate)

- (void)messageToolboxViewDidSelectLikers:(MessageToolboxView *)messageToolboxView
{
    [self.delegate conversationCellDidTapOpenLikers:self];
}

- (void)messageToolboxViewDidSelectResend:(MessageToolboxView *)messageToolboxView
{
    [self.delegate conversationCellDidTapResendMessage:self];
}

- (void)messageToolboxViewDidSelectDelete:(MessageToolboxView *)messageToolboxView
{
    [self.delegate conversationCell:self didSelectAction:MessageActionDelete];
}

@end
