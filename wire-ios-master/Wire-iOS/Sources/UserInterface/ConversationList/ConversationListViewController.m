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


#import "ConversationListViewController.h"
#import "ConversationListViewController+StartUI.h"

@import PureLayout;
@import WireExtensionComponents;

#import "Settings.h"
#import "UIScrollView+Zeta.h"

#import "ZClientViewController.h"
#import "ZClientViewController+Internal.h"

#import "Constants.h"
#import "PermissionDeniedViewController.h"
#import "AnalyticsTracker.h"

#import "WireSyncEngine+iOS.h"

#import "ConversationListContentController.h"
#import "StartUIViewController.h"
#import "KeyboardAvoidingViewController.h"

// helpers

#import "WAZUIMagicIOS.h"
#import "Analytics.h"
#import "UIView+Borders.h"
#import "NSAttributedString+Wire.h"

// Transitions
#import "AppDelegate.h"
#import "NotificationWindowRootViewController.h"
#import "PassthroughTouchesView.h"


#import "ActionSheetController.h"
#import "ActionSheetController+Conversation.h"

#import "Wire-Swift.h"
#import "UIImage+Color.h"
#import <Masonry.h>
#import "IFMMenu.h"
#import "InviteContactsViewController.h"
#import "AnalyticsTracker+Invitations.h"

#import "PerCenterViewController.h"

@interface ConversationListViewController (Content) <ConversationListContentDelegate,ContactsViewControllerDelegate>

- (void)updateBottomBarSeparatorVisibilityWithContentController:(ConversationListContentController *)controller;

@end

@interface ConversationListViewController (BottomBarDelegate) <ConversationListBottomBarControllerDelegate>
@end

@interface ConversationListViewController (StartUI) <StartUIDelegate>
@end

@interface ConversationListViewController (Archive) <ArchivedListViewControllerDelegate>
@end

@interface ConversationListViewController (PermissionDenied) <PermissionDeniedViewControllerDelegate>
@end

@interface ConversationListViewController (InitialSyncObserver) <ZMInitialSyncCompletionObserver>
@end

@interface ConversationListViewController (ConversationListObserver) <ZMConversationListObserver>

- (void)updateArchiveButtonVisibility;

@end

#define COLOR(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a]
@interface ConversationListViewController ()<ConversationCreationControllerDelegate>{
    NSMutableDictionary *listDic;
}

@property (nonatomic) ZMConversation *selectedConversation;
@property (nonatomic) ConversationListState state;

@property (nonatomic, weak) id<UserProfile> userProfile;
@property (nonatomic) NSObject *userProfileObserverToken;
@property (nonatomic) id userObserverToken;
@property (nonatomic) id allConversationsObserverToken;
@property (nonatomic) id connectionRequestsObserverToken;
@property (nonatomic) id initialSyncObserverToken;

@property (nonatomic) ConversationListContentController *listContentController;
@property (nonatomic) StartUIViewController *startcontroller;
@property (nonatomic) ConversationListBottomBarController *bottomBarController;

@property (nonatomic) ConversationListTopBar *topBar;
@property (nonatomic) UIView *contentContainer;
@property (nonatomic) UIView *conversationListContainer;
@property (nonatomic) UILabel *noConversationLabel;
@property (nonatomic) ConversationListOnboardingHint *onboardingHint;

@property (nonatomic) PermissionDeniedViewController *pushPermissionDeniedViewController;

@property (nonatomic) NSLayoutConstraint *bottomBarBottomOffset;
@property (nonatomic) NSLayoutConstraint *bottomBarToolTipConstraint;

@property (nonatomic) CGFloat contentControllerBottomInset;

@property (nonatomic ,strong) UIViewController *currentVC;

@property (nonatomic, strong) ConversationCreationController *groupchat;

@property (nonatomic,strong) PerCenterViewController *vc;

- (void)setState:(ConversationListState)state animated:(BOOL)animated;

@end



@implementation ConversationListViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeUserProfileObserver];
}

- (void)removeUserProfileObserver
{
    self.userProfileObserverToken = nil;
}

- (void)loadView
{
    self.view = [[PassthroughTouchesView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)addSegmentView{
    listDic = [NSMutableDictionary dictionary];
    
    NSArray * _titles = @[@"消息", @"好友"];
    UISegmentedControl * _segmentedControl = [[UISegmentedControl alloc] initWithItems:_titles];
    _segmentedControl.selectedSegmentIndex = 0;
    [_segmentedControl setBackgroundImage:[UIImage imageWithColor:[UIColor blackColor]] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [_segmentedControl setBackgroundImage:[UIImage imageWithColor:[UIColor blackColor]] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [_segmentedControl setDividerImage:[UIImage imageWithColor:[UIColor whiteColor]] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [_segmentedControl setDividerImage:[UIImage imageWithColor:[UIColor whiteColor]] forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    _segmentedControl.layer.masksToBounds = YES;
    _segmentedControl.layer.cornerRadius = 5;
    _segmentedControl.layer.borderWidth = 1;
    _segmentedControl.layer.borderColor = [UIColor whiteColor].CGColor;
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor orangeColor],
                         NSForegroundColorAttributeName,
                         [UIFont systemFontOfSize:16],
                         NSFontAttributeName,nil];
    
    [ _segmentedControl setTitleTextAttributes:dic forState:UIControlStateSelected];
    
    NSDictionary *dic1 = [NSDictionary dictionaryWithObjectsAndKeys:UIColorFromRGB(0xffffff),
                          NSForegroundColorAttributeName,
                          [UIFont systemFontOfSize:16],
                          NSFontAttributeName,nil];
    
    [ _segmentedControl setTitleTextAttributes:dic1 forState:UIControlStateNormal];
    
    [_segmentedControl addTarget:self action:@selector(segmentValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:_segmentedControl];
    [_segmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.topBar.mas_centerY).offset(0);
        make.height.mas_equalTo(27);
        make.width.mas_equalTo(167);
    }];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.listContentController = [[ConversationListContentController alloc] init];
    self.listContentController.collectionView.contentInset = UIEdgeInsetsMake(0, 0, self.contentControllerBottomInset, 0);
    self.listContentController.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.listContentController.contentDelegate = self;
    self.listContentController.view.frame = CGRectMake(0, 70, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 70);
    [self.listContentController.collectionView scrollRectToVisible:CGRectMake(0, 0, self.view.bounds.size.width, 1) animated:NO];
    
    [self addChildViewController:self.listContentController];
    [self.view addSubview:self.listContentController.view];
    self.currentVC = self.listContentController;
    
    self.startcontroller = [[StartUIViewController alloc] init];
    self.startcontroller.delegate = self;
    self.startcontroller.view.frame = CGRectMake(0, 70, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 70);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NavigationBarPullDown) name:@"NavigationBarPullDown" object:nil];
    
}

-(void)segmentValueChanged:(UISegmentedControl *)seg{
    NSLog(@"seg.tag-->%ld",seg.selectedSegmentIndex);
    switch (seg.selectedSegmentIndex) {
        case 0:
            [self replaceController:self.currentVC newController:self.listContentController];
            break;
        case 1:
            [self replaceController:self.currentVC newController:self.startcontroller];
            break;
        case 2:
//            [self replaceController:self.currentVC newController:self.threeVC];
            break;
            
        default:
            break;
    }
}

- (void)replaceController:(UIViewController *)oldController newController:(UIViewController *)newController
{
    
    [self addChildViewController:newController];
    [self transitionFromViewController:oldController toViewController:newController duration:0.0 options:UIViewAnimationOptionTransitionNone animations:nil completion:^(BOOL finished) {
        
        if (finished) {
            
            [newController didMoveToParentViewController:self];
            [oldController willMoveToParentViewController:nil];
            [oldController removeFromParentViewController];
            self.currentVC = newController;
            
        }else{
            
            self.currentVC = oldController;
            
        }
    }];
}

- (void)CreateGroupChat{

    self.groupchat = [[ConversationCreationController alloc] init];
    _groupchat.delegate = self;
    UINavigationController *embeddedNavigationController = [_groupchat wrapInNavigationController];
    embeddedNavigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:embeddedNavigationController animated:YES completion:nil];
}

//- (void)backbtn{
//    [_groupchat dismissViewControllerAnimated:YES completion:nil];
//}

#pragma mark - ContactsViewControllerDelegate

- (void)contactsViewControllerDidCancel:(ContactsViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)contactsViewControllerDidNotShareContacts:(ContactsViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)Invitemore{
    InviteContactsViewController *inviteContactsViewController = [[InviteContactsViewController alloc] init];
    inviteContactsViewController.analyticsTracker = [AnalyticsTracker analyticsTrackerWithContext:NSStringFromInviteContext(InviteContextStartUI)];
    inviteContactsViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    inviteContactsViewController.delegate = self;
    [self presentViewController:inviteContactsViewController animated:YES completion:^() {
        [inviteContactsViewController.analyticsTracker tagEvent:AnalyticsEventInviteContactListOpened];
    }];
}

- (void)NavigationBarPullDown{
    __weak typeof(self)weakSelf = self;
    NSMutableArray *menuItems = [[NSMutableArray alloc] initWithObjects:
                                 [IFMMenuItem itemWithImage:[UIImage imageNamed:@"XC创建群聊"]
                                                      title:@"创建群聊"
                                                     action:^(IFMMenuItem *item) {
                                                         [weakSelf CreateGroupChat];
                                                     }],
                                 [IFMMenuItem itemWithImage:[UIImage imageNamed:@"XC邀请好友"]
                                                      title:@"邀请好友"
                                                     action:^(IFMMenuItem *item) {
                                                         [weakSelf Invitemore];
                                                     }], nil];
    
    IFMMenu *menu = [[IFMMenu alloc] initWithItems:menuItems];
    menu.menuBackGroundColor = [UIColor blackColor];
    menu.titleFont = [UIFont systemFontOfSize:15];
    menu.titleColor = [UIColor whiteColor];
    menu.segmenteLineColor = UIColorFromRGB(0xdddddd);
    menu.menuCornerRadiu = 2.f;
    menu.gapBetweenImageTitle = 20.f;
    menu.edgeInsets = UIEdgeInsetsMake(1, 24, 1, 10);
    menu.showShadow = NO;
    menu.minMenuItemHeight = 44;
    menu.minMenuItemWidth = 150;
    
    [menu showFromRect:CGRectMake(self.view.bounds.size.width - 30, 80, 0, 0) inView:self.view];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.contentControllerBottomInset = 16;
    
    self.contentContainer = [[UIView alloc] initForAutoLayout];
//    self.contentContainer.backgroundColor = [UIColor orangeColor];
//    self.contentContainer.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.contentContainer];

    self.userProfile = ZMUserSession.sharedSession.userProfile;
    self.userObserverToken = [UserChangeInfo addObserver:self forUser:[ZMUser selfUser] userSession:[ZMUserSession sharedSession]];
    
    self.onboardingHint = [[ConversationListOnboardingHint alloc] init];
    [self.contentContainer addSubview:self.onboardingHint];

    self.conversationListContainer = [[UIView alloc] initForAutoLayout];
    self.conversationListContainer.backgroundColor = [UIColor clearColor];
    [self.contentContainer addSubview:self.conversationListContainer];

    self.initialSyncObserverToken = [ZMUserSession addInitialSyncCompletionObserver:self userSession:[ZMUserSession sharedSession]];

    [self createNoConversationLabel];
//    [self createListContentController];
    [self createBottomBarController];
    [self createTopBar];

    [self createViewConstraints];
    
    [self hideNoContactLabelAnimated:NO];
    [self updateNoConversationVisibility];
    [self updateArchiveButtonVisibility];
    
    [self updateObserverTokensForActiveTeam];
    [self showPushPermissionDeniedDialogIfNeeded];
    
    [self addSegmentView];
}

- (void)updateObserverTokensForActiveTeam
{
    self.allConversationsObserverToken = [ConversationListChangeInfo addObserver:self
                                                                         forList:[ZMConversationList conversationsIncludingArchivedInUserSession:[ZMUserSession sharedSession]]
                                                                     userSession:[ZMUserSession sharedSession]];
    self.connectionRequestsObserverToken = [ConversationListChangeInfo addObserver:self
                                                                           forList:[ZMConversationList pendingConnectionConversationsInUserSession:[ZMUserSession sharedSession]]
                                                                       userSession:[ZMUserSession sharedSession]];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[ZMUserSession sharedSession] enqueueChanges:^{
        [self.selectedConversation savePendingLastRead];
    }];

    [self requestSuggestedHandlesIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (! IS_IPAD_FULLSCREEN) {
        [Settings sharedSettings].lastViewedScreen = SettingsLastScreenList;
    }
    
    _state = ConversationListStateConversationList;
    
    [self updateBottomBarSeparatorVisibilityWithContentController:self.listContentController];
    [self closePushPermissionDialogIfNotNeeded];
}

- (void)requestSuggestedHandlesIfNeeded
{
    if (nil == ZMUser.selfUser.handle &&
        ZMUserSession.sharedSession.hasCompletedInitialSync &&
        !ZMUserSession.sharedSession.isPendingHotFixChanges) {
        
        self.userProfileObserverToken = [self.userProfile addObserver:self];
        [self.userProfile suggestHandles];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if (self.presentedViewController != nil) {
        return self.presentedViewController.preferredStatusBarStyle;
    }
    else {
        return UIStatusBarStyleLightContent;
    }
}

- (void)createNoConversationLabel;
{
    self.noConversationLabel = [[UILabel alloc] initForAutoLayout];
    self.noConversationLabel.attributedText = self.attributedTextForNoConversationLabel;
    self.noConversationLabel.numberOfLines = 0;
    [self.contentContainer addSubview:self.noConversationLabel];
}

- (NSAttributedString *)attributedTextForNoConversationLabel
{
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.paragraphSpacing = 10;
    paragraphStyle.alignment = NSTextAlignmentCenter;

    NSDictionary *titleAttributes = @{
                                      NSForegroundColorAttributeName : [UIColor whiteColor],
                                      NSFontAttributeName : [UIFont fontWithMagicIdentifier:@"style.text.small.font_spec_bold"],
                                      NSParagraphStyleAttributeName : paragraphStyle
                                      };

    paragraphStyle.paragraphSpacing = 4;

    NSString *titleLocalizationKey = @"conversation_list.empty.all_archived.message";
    NSString *titleString = NSLocalizedString(titleLocalizationKey, nil);

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[titleString uppercaseString]
                                                                                         attributes:titleAttributes];
    
    return attributedString;
}

- (void)createBottomBarController
{
    self.bottomBarController = [[ConversationListBottomBarController alloc] initWithDelegate:self];
    self.bottomBarController.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.bottomBarController.showArchived = YES;
    [self addChildViewController:self.bottomBarController];
    [self.conversationListContainer addSubview:self.bottomBarController.view];
    [self.bottomBarController didMoveToParentViewController:self];
}

- (ArchivedListViewController *)createArchivedListViewController
{
    ArchivedListViewController *archivedViewController = [ArchivedListViewController new];
    archivedViewController.delegate = self;
    return archivedViewController;
}

- (StartUIViewController *)createPeoplePickerController
{
    StartUIViewController *startUIViewController = [[StartUIViewController alloc] init];
    startUIViewController.delegate = self;
    return startUIViewController;
}

- (SettingsNavigationController *)createSettingsViewController
{
    SettingsNavigationController *settingsViewController = [SettingsNavigationController settingsNavigationController];

    return settingsViewController;
}

- (void)createListContentController
{
    self.listContentController = [[ConversationListContentController alloc] init];
    self.listContentController.collectionView.contentInset = UIEdgeInsetsMake(0, 0, self.contentControllerBottomInset, 0);
    self.listContentController.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.listContentController.contentDelegate = self;

    [self addChildViewController:self.listContentController];
    [self.conversationListContainer addSubview:self.listContentController.view];
    [self.listContentController didMoveToParentViewController:self];
}

- (void)setState:(ConversationListState)state animated:(BOOL)animated
{
    [self setState:state animated:animated completion:nil];
}

- (void)setState:(ConversationListState)state animated:(BOOL)animated completion:(dispatch_block_t)completion
{
    if (_state == state) {
        if (completion) {
            completion();
        }
        return;
    }
    self.state = state;

    switch (state) {
        case ConversationListStateConversationList: {
            self.view.alpha = 1;
            
            if (self.presentedViewController != nil) {
                [self.presentedViewController dismissViewControllerAnimated:YES completion:completion];
            }
            else {
                if (completion) {
                    completion();
                }
            }
        }
            break;
        case ConversationListStatePeoplePicker: {
            StartUIViewController *startUIViewController = self.createPeoplePickerController;
            UINavigationController *navigationWrapper = [startUIViewController wrapInNavigationController:[ClearBackgroundNavigationController class]];
            
            [self showViewController:navigationWrapper animated:YES completion:^{
                [startUIViewController showKeyboardIfNeeded];
                if (completion) {
                    completion();
                }
            }];
        }
            break;
        case ConversationListStateArchived: {
            [self showViewController:self.createArchivedListViewController animated:animated completion:^{
                if (completion) {
                    completion();
                }
            }];
        }
            break;
        default:
            break;
    }
}

- (void)showViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(dispatch_block_t)completion
{
    viewController.transitioningDelegate = self;
    viewController.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    [self presentViewController:viewController animated:animated completion:^{
        if (completion) {
            completion();
        }
    }];
}

- (void)createViewConstraints
{
    [self.conversationListContainer autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
    
    [self.bottomBarController.view autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [self.bottomBarController.view autoPinEdgeToSuperviewEdge:ALEdgeRight];
    self.bottomBarBottomOffset = [self.bottomBarController.view autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    
    [self.topBar autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
    [self.topBar autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.conversationListContainer];
    [self.contentContainer autoPinEdgesToSuperviewEdgesWithInsets:UIScreen.safeArea];
    
    [self.noConversationLabel autoCenterInSuperview];
    [self.noConversationLabel autoSetDimension:ALDimensionHeight toSize:120.0f];
    [self.noConversationLabel autoSetDimension:ALDimensionWidth toSize:240.0f];
    
    [self.onboardingHint autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.bottomBarController.view];
    [self.onboardingHint autoPinEdgeToSuperviewMargin:ALEdgeLeft];
    [self.onboardingHint autoPinEdgeToSuperviewMargin:ALEdgeRight];

    [self.listContentController.view autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [self.listContentController.view autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.bottomBarController.view];
    [self.listContentController.view autoPinEdgeToSuperviewEdge:ALEdgeLeading];
    [self.listContentController.view autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
         // we reload on rotation to make sure that the list cells lay themselves out correctly for the new
         // orientation
        [self.listContentController reload];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)definesPresentationContext
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)setBackgroundColorPreference:(UIColor *)color
{
    [UIView animateWithDuration:0.4 animations:^{
        self.view.backgroundColor = color;
        self.listContentController.view.backgroundColor = color;
    }];
}

- (void)hideArchivedConversations
{
    [self setState:ConversationListStateConversationList animated:YES];
}

#pragma mark - Selection

- (void)selectConversation:(ZMConversation *)conversation
{
    [self selectConversation:conversation focusOnView:NO animated:NO];
}

- (void)selectConversation:(ZMConversation *)conversation focusOnView:(BOOL)focus animated:(BOOL)animated
{
    [self selectConversation:conversation focusOnView:focus animated:animated completion:nil];
}

- (void)selectConversation:(ZMConversation *)conversation focusOnView:(BOOL)focus animated:(BOOL)animated completion:(dispatch_block_t)completion
{
    self.selectedConversation = conversation;
    
    @weakify(self);
    [self dismissPeoplePickerWithCompletionBlock:^{
        @strongify(self);
        [self.listContentController selectConversation:self.selectedConversation focusOnView:focus animated:animated completion:completion];
    }];
}

- (void)selectInboxAndFocusOnView:(BOOL)focus
{
    [self setState:ConversationListStateConversationList animated:NO];
    [self.listContentController selectInboxAndFocusOnView:focus];
}

- (void)scrollToCurrentSelectionAnimated:(BOOL)animated
{
    [self.listContentController scrollToCurrentSelectionAnimated:animated];
}

- (void)showActionMenuForConversation:(ZMConversation *)conversation
{
    ActionSheetController *controller = [ActionSheetController dialogForConversationDetails:conversation style:ActionSheetControllerStyleDark];
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Push permissions

- (void)showPushPermissionDeniedDialogIfNeeded
{
    // We only want to present the notification takeover when the user already has a handle
    // and is not coming from the registration flow (where we alreday ask for permissions).
    if (! self.isComingFromRegistration || nil == ZMUser.selfUser.handle) {
        return;
    }

    if (AutomationHelper.sharedHelper.skipFirstLoginAlerts || self.usernameTakeoverViewController != nil) {
        return;
    }
    
    BOOL pushAlertHappenedMoreThan1DayBefore = [[Settings sharedSettings] lastPushAlertDate] == nil ||
    fabs([[[Settings sharedSettings] lastPushAlertDate] timeIntervalSinceNow]) > 60 * 60 * 24;
    
    BOOL pushNotificationsDisabled = ! [[UIApplication sharedApplication] isRegisteredForRemoteNotifications] ||
    [[UIApplication sharedApplication] currentUserNotificationSettings].types == UIUserNotificationTypeNone;
    
    if (pushNotificationsDisabled && pushAlertHappenedMoreThan1DayBefore) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[Settings sharedSettings] setLastPushAlertDate:[NSDate date]];
        PermissionDeniedViewController *permissions = [PermissionDeniedViewController pushDeniedViewController];
        permissions.analyticsTracker = [AnalyticsTracker analyticsTrackerWithContext:AnalyticsContextPostLogin];
        permissions.delegate = self;
        
        [self addChildViewController:permissions];
        [self.view addSubview:permissions.view];
        [permissions didMoveToParentViewController:self];
        
        [permissions.view autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
        self.pushPermissionDeniedViewController = permissions;
        
        self.contentContainer.alpha = 0.0f;
    }
}

- (void)closePushPermissionDialogIfNotNeeded
{
    BOOL pushNotificationsDisabled = ! [[UIApplication sharedApplication] isRegisteredForRemoteNotifications] ||
    [[UIApplication sharedApplication] currentUserNotificationSettings].types == UIUserNotificationTypeNone;
    
    if (self.pushPermissionDeniedViewController != nil && ! pushNotificationsDisabled) {
        [self closePushPermissionDeniedDialog];
    }
}

- (void)closePushPermissionDeniedDialog
{
    [self.pushPermissionDeniedViewController willMoveToParentViewController:nil];
    [self.pushPermissionDeniedViewController.view removeFromSuperview];
    [self.pushPermissionDeniedViewController removeFromParentViewController];
    self.pushPermissionDeniedViewController = nil;
    
    self.contentContainer.alpha = 1.0f;
}

- (void)applicationDidBecomeActive:(NSNotification *)notif
{
    [self closePushPermissionDialogIfNotNeeded];
}

#pragma mark - Conversation Collection Vertical Pan Gesture Handling

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)presentPeoplePickerAnimated:(BOOL)animated
{
    [self setState:ConversationListStatePeoplePicker animated:animated];
}

//点击头像123
- (void)presentSettings
{
    SettingsNavigationController *settingsViewController = [self createSettingsViewController];
    KeyboardAvoidingViewController *keyboardAvoidingWrapperController = [[KeyboardAvoidingViewController alloc] initWithViewController:settingsViewController];

    if (self.wr_splitViewController.layoutSize == SplitViewControllerLayoutSizeCompact) {
        keyboardAvoidingWrapperController.topInset = UIScreen.safeArea.top;
        @weakify(keyboardAvoidingWrapperController);
        settingsViewController.dismissAction = ^(SettingsNavigationController *controller) {
            @strongify(keyboardAvoidingWrapperController);
            [keyboardAvoidingWrapperController dismissViewControllerAnimated:YES completion:nil];
        };

        keyboardAvoidingWrapperController.modalPresentationStyle = UIModalPresentationCurrentContext;
        keyboardAvoidingWrapperController.transitioningDelegate = self;
        [self presentViewController:keyboardAvoidingWrapperController animated:YES completion:nil];
    }
    else {
        @weakify(self);
        settingsViewController.dismissAction = ^(SettingsNavigationController *controller) {
            @strongify(self);
            [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
        };
        keyboardAvoidingWrapperController.modalPresentationStyle = UIModalPresentationFormSheet;
        keyboardAvoidingWrapperController.view.backgroundColor = [UIColor blackColor];
        [self.parentViewController presentViewController:keyboardAvoidingWrapperController animated:YES completion:nil];
    }
//    self.vc = [[PerCenterViewController alloc] init];
//    typeof(self)weakself = self;
//    _vc.dismissBlock = ^{
//        [weakself.vc.view removeFromSuperview];
//    };
//    [self addChildViewController:_vc];
//    [self.view addSubview:_vc.view];
//    [UIView animateWithDuration:1 animations:^{
//    } completion:^(BOOL finished) {
//        _vc.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
//    }];
}

- (void)dismissPeoplePickerWithCompletionBlock:(dispatch_block_t)block
{
    [self setState:ConversationListStateConversationList animated:YES completion:block];
}

- (void)showNoContactLabel;
{
    if (self.state == ConversationListStateConversationList) {
        [UIView animateWithDuration:0.20
                         animations:^{
                             self.noConversationLabel.alpha = self.hasArchivedConversations ? 1.0f : 0.0f;
                             self.onboardingHint.alpha = self.hasArchivedConversations ? 0.0f : 1.0f;
                         }];
    }
}

- (void)hideNoContactLabelAnimated:(BOOL)animated;
{
    [UIView animateWithDuration:animated ? 0.20 : 0.0
                     animations:^{
                         self.noConversationLabel.alpha = 0.0f;
                         self.onboardingHint.alpha = 0.0f;
                     }];
}

- (void)updateNoConversationVisibility;
{
    if (!self.hasConversations) {
        [self showNoContactLabel];
    } else {
        [self hideNoContactLabelAnimated:YES];
    }
}

- (BOOL)hasConversations
{
    ZMUserSession *session = ZMUserSession.sharedSession;
    NSUInteger conversationsCount = [ZMConversationList conversationsInUserSession:session].count +
                                    [ZMConversationList pendingConnectionConversationsInUserSession:session].count;
    return conversationsCount > 0;
}

- (BOOL)hasArchivedConversations
{
    return [ZMConversationList archivedConversationsInUserSession:ZMUserSession.sharedSession].count > 0;
}

@end



@implementation ConversationListViewController (Content)

- (void)updateBottomBarSeparatorVisibilityWithContentController:(ConversationListContentController *)controller
{
    CGFloat controllerHeight = CGRectGetHeight(controller.view.bounds);
    CGFloat contentHeight = controller.collectionView.contentSize.height;
    CGFloat offsetY = controller.collectionView.contentOffset.y;
    BOOL showSeparator = contentHeight - offsetY + self.contentControllerBottomInset > controllerHeight;
    
    if (self.bottomBarController.showSeparator != showSeparator) {
        self.bottomBarController.showSeparator = showSeparator;
    }
}

- (void)conversationListDidScroll:(ConversationListContentController *)controller
{
    [self updateBottomBarSeparatorVisibilityWithContentController:controller];
    
    [self.topBar scrollViewDidScroll:controller.collectionView];
}

- (void)conversationList:(ConversationListViewController *)controller didSelectConversation:(ZMConversation *)conversation focusOnView:(BOOL)focus
{
    _selectedConversation = conversation;
}

- (void)conversationList:(ConversationListContentController *)controller willSelectIndexPathAfterSelectionDeleted:(NSIndexPath *)conv
{
    if (IS_IPAD_PORTRAIT_LAYOUT) {
        [[ZClientViewController sharedZClientViewController] transitionToListAnimated:YES completion:nil];
    }
}

- (void)conversationListContentController:(ConversationListContentController *)controller wantsActionMenuForConversation:(ZMConversation *)conversation
{
    [self showActionMenuForConversation:conversation];
}

@end


@implementation ConversationListViewController (PermissionDenied)

- (void)continueWithoutPermission:(PermissionDeniedViewController *)viewController
{
    [self closePushPermissionDeniedDialog];
}

@end

#pragma mark - ConversationListBottomBarDelegate

@implementation ConversationListViewController (BottomBarDelegate)

- (void)conversationListBottomBar:(ConversationListBottomBarController *)bar didTapButtonWithType:(enum ConversationListButtonType)buttonType
{
    switch (buttonType) {
        case ConversationListButtonTypeArchive:
            [self setState:ConversationListStateArchived animated:YES];
            [Analytics.shared tagArchiveOpened];
            break;

        case ConversationListButtonTypeStartUI:
            [self presentPeoplePicker];
            break;

        case ConversationListButtonTypeCompose:
            [self presentDraftsViewController];
            break;
            
        case ConversationListButtonTypeCamera:
            [self showCameraPicker];
            break;
    }
}

- (void)presentDraftsViewController
{
    DraftsRootViewController *draftsController = [[DraftsRootViewController alloc] init];
    [ZClientViewController.sharedZClientViewController presentViewController:draftsController animated:YES completion:nil];
}

- (void)presentPeoplePicker
{
    [self setState:ConversationListStatePeoplePicker animated:YES completion:nil];
}

@end

@implementation ConversationListViewController (Archive)

- (void)archivedListViewControllerWantsToDismiss:(ArchivedListViewController *)controller
{
    [self setState:ConversationListStateConversationList animated:YES];
}

- (void)archivedListViewController:(ArchivedListViewController *)controller didSelectConversation:(ZMConversation *)conversation
{
    @weakify(self)
    [ZMUserSession.sharedSession enqueueChanges:^{
        conversation.isArchived = NO;
    } completionHandler:^{
        [Analytics.shared tagUnarchivedConversation];
        [self setState:ConversationListStateConversationList animated:YES completion:^{
            @strongify(self)
            [self.listContentController selectConversation:conversation focusOnView:YES animated:YES];
        }];
    }];
}

@end

@implementation ConversationListViewController (ConversationListObserver)

- (void)conversationListDidChange:(ConversationListChangeInfo *)changeInfo
{
    [self updateNoConversationVisibility];
    [self updateArchiveButtonVisibility];
}

- (void)updateArchiveButtonVisibility
{
    BOOL showArchived = self.hasArchivedConversations;
    if (showArchived == self.bottomBarController.showArchived) {
        return;
    }

    [UIView transitionWithView:self.bottomBarController.view
                      duration:0.35
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.bottomBarController.showArchived = showArchived;
    } completion:nil];
}

@end


@implementation ConversationListViewController (InitialSyncObserver)

- (void)initialSyncCompleted
{
    [self requestSuggestedHandlesIfNeeded];
}

@end
