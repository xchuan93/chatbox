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


#import "AppDelegate.h"

#import "WireSyncEngine+iOS.h"
#import "Wire-Swift.h"

// Helpers
#import "Constants.h"
#import "AppDelegate+Hockey.h"
#import "Application+runDuration.h"
#import "AppDelegate+Logging.h"
#import "ZClientViewController.h"
#import "Analytics.h"
#import "AnalyticsTracker+Registration.h"
#import "AnalyticsTracker+Permissions.h"


// Performance Measurement
#import "StopWatch.h"


NSString *const ZMUserSessionDidBecomeAvailableNotification = @"ZMUserSessionDidBecomeAvailableNotification";


static AppDelegate *sharedAppDelegate = nil;


@interface AppDelegate ()

@property (nonatomic) AppRootViewController *rootViewController;
@property (nonatomic, assign) BOOL trackedResumeEvent;
@property (nonatomic, assign, readwrite) ApplicationLaunchType launchType;
@property (nonatomic, copy) NSDictionary *launchOptions;


@property (nonatomic, assign) BOOL isWindow;

@property (nonatomic,copy)NSArray *customArr;
@end


@interface AppDelegate (PushNotifications)
@end


@implementation AppDelegate

+ (instancetype)sharedAppDelegate;
{
    return sharedAppDelegate;
}

+(instancetype _Nullable )initwithDataSource:(NSDictionary *_Nonnull)dic{
    return sharedAppDelegate;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        sharedAppDelegate = self;
    }
    return self;
}

- (void)setupBackendEnvironment
{
    NSString *BackendEnvironmentTypeKey = @"ZMBackendEnvironmentType";
    NSString *backendEnvironment = [[NSUserDefaults standardUserDefaults] stringForKey:BackendEnvironmentTypeKey];
    
    [[NSUserDefaults sharedUserDefaults] setObject:backendEnvironment forKey:BackendEnvironmentTypeKey];
    
    if (backendEnvironment.length == 0 || [backendEnvironment isEqualToString:@"default"]) {
        NSString *defaultBackend = @STRINGIZE(DEFAULT_BACKEND);
        
        DDLogInfo(@"Backend environment is <not defined>. Using '%@'.", defaultBackend);
        [[NSUserDefaults standardUserDefaults] setObject:defaultBackend forKey:BackendEnvironmentTypeKey];
        [[NSUserDefaults sharedUserDefaults] setObject:defaultBackend forKey:BackendEnvironmentTypeKey];
    } else {
        DDLogInfo(@"Using '%@' backend environment", backendEnvironment);
    }
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setupLogging];

    DDLogInfo(@"application:willFinishLaunchingWithOptions %@ (applicationState = %ld)", launchOptions, (long)application.applicationState);
    
    // Initial log line to indicate the client version and build
    DDLogInfo(@"Wire-ios version %@ (%@)",
              [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],
              [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *) kCFBundleVersionKey]);
    
    // Note: if we instantiate the root view controller (& windows) any earlier,
    // the windows will not receive any info about device orientation.
    self.rootViewController = [[AppRootViewController alloc] init];
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    DDLogInfo(@"application:didFinishLaunchingWithOptions START %@ (applicationState = %ld)", launchOptions, (long)application.applicationState);
    [self setupBackendEnvironment];

    [self setupTracking];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userSessionDidBecomeAvailable:)
                                                 name:ZMUserSessionDidBecomeAvailableNotification
                                               object:nil];

    
//    UIStatusBarStyleLightContent
    self.homeVC = [[HomeViewController alloc] init];
    __weak typeof(self) weakself = self;
    _homeVC.rootinit = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            weakself.isWindow = NO;
            weakself.homeVC.homeWindow.hidden = YES;
            weakself.rootViewController.mainWindow.hidden = NO;
            [weakself.rootViewController.mainWindow makeKeyWindow];
            [weakself.rootViewController.mainWindow makeKeyAndVisible];
        });
    };
    
    [self setupHockeyWithCompletion:^() {
        
        [self.rootViewController launchWith:launchOptions];
    }];
    self.launchOptions = launchOptions;
    
    DDLogInfo(@"application:didFinishLaunchingWithOptions END %@", launchOptions);
    DDLogInfo(@"Application was launched with arguments: %@",[[NSProcessInfo processInfo]arguments]);

    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    DDLogInfo(@"applicationWillEnterForeground: (applicationState = %ld)", (long)application.applicationState);
}

- (void)applicationDidBecomeActive:(UIApplication *)application;
{
    DDLogInfo(@"applicationDidBecomeActive START (applicationState = %ld)", (long)application.applicationState);
    
    switch (self.launchType) {
        case ApplicationLaunchURL:
        case ApplicationLaunchPush:
            break;
        default:
            self.launchType = ApplicationLaunchDirect;
            break;
    }
    
    if (! self.trackedResumeEvent) {
        [[Analytics shared] tagAppLaunchWithType:self.launchType];
    }
    
    self.trackedResumeEvent = NO;
    
    DDLogInfo(@"applicationDidBecomeActive END");
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    DDLogInfo(@"applicationWillResignActive:  (applicationState = %ld)", (long)application.applicationState);
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    DDLogInfo(@"applicationDidEnterBackground:  (applicationState = %ld)", (long)application.applicationState);
    
    self.launchType = ApplicationLaunchUnknown;
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    DDLogInfo(@"applicationWillTerminate:  (applicationState = %ld)", (long)application.applicationState);
    
    // In case of normal termination we do not need the run duration to persist
    [[UIApplication sharedApplication] resetRunDuration];
}

- (void)setupTracking
{
    // Migrate analytics settings
    [[TrackingManager shared] migrateFromLocalytics];
    
    BOOL containsConsoleAnalytics = [[[NSProcessInfo processInfo] arguments] indexOfObjectPassingTest:^BOOL(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:AnalyticsProviderFactory.ZMConsoleAnalyticsArgumentKey]) {
            *stop = YES;
            return YES;
        }
        return NO;
    }] != NSNotFound;
    
    [AnalyticsProviderFactory shared].useConsoleAnalytics = containsConsoleAnalytics;
    [Analytics loadSharedWithOptedOut:[[TrackingManager shared] disableCrashAndAnalyticsSharing]];
}

- (void)trackLaunchAnalyticsWithLaunchOptions:(NSDictionary *)launchOptions
{
    self.launchType = ApplicationLaunchDirect;
    if (launchOptions[UIApplicationLaunchOptionsURLKey] != nil) {
        self.launchType = ApplicationLaunchURL;
    }
    
    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey] != nil ||
        launchOptions[UIApplicationLaunchOptionsLocalNotificationKey] != nil) {
        self.launchType = ApplicationLaunchPush;
    }
    [[UIApplication sharedApplication] setupRunDurationCalculation];
    [[Analytics shared] tagAppLaunchWithType:self.launchType];
    self.trackedResumeEvent = YES;
}

- (void)userSessionDidBecomeAvailable:(NSNotification *)notification
{
    [self trackLaunchAnalyticsWithLaunchOptions:self.launchOptions];
    [self trackErrors];
}

#pragma mark - URL handling

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    DDLogInfo(@"application:handleOpenURL: %@", url);
    return YES;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler
{
    DDLogInfo(@"application:continueUserActivity:restorationHandler: %@", userActivity);
    return [[SessionManager shared] continueUserActivity:userActivity restorationHandler:restorationHandler];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    DDLogInfo(@"application:openURL:sourceApplication:annotation: URL: %@, souce app: %@", url, sourceApplication);
    
    self.launchType = ApplicationLaunchURL;
    [[Analytics shared] tagAppLaunchWithType:ApplicationLaunchURL];
    self.trackedResumeEvent = YES;
    
    BOOL succeded = NO;
    
    if ([[url scheme] isEqualToString:WireURLScheme] || [[url scheme] isEqualToString:WireURLSchemeInvite]) {
        succeded = YES;
        
        if ([[url host] isEqualToString:@"email-verified"]) {
            [[Analytics shared] tagAppLaunchWithType:ApplicationLaunchRegistration];
        }
        else if ([[url scheme] isEqualToString:WireURLSchemeInvite]) {
            [[AnalyticsTracker analyticsTrackerWithContext:nil] tagAcceptedGenericInvite];
        }
        
        [self.rootViewController performWhenAuthenticated:^{
            [[ZMUserSession sharedSession] didLaunchWithURL:url];
        }];
    }
    
    if (! succeded) {
        // Intentional NSLog
        NSLog(@"INFO: Received URL: %@", [url absoluteString]);
    }

    return NO;
}

#pragma mark - AppController

- (UnauthenticatedSession *)unauthenticatedSession
{
    return [[SessionManager shared] unauthenticatedSession];
}

- (NotificationWindowRootViewController *)notificationWindowController
{
    return (NotificationWindowRootViewController *)self.rootViewController.overlayWindow.rootViewController;
}

- (SessionManager *)sessionManager
{
    return self.rootViewController.sessionManager;
}

- (UIWindow *)window
{
    return self.rootViewController.mainWindow;
}

- (void)setWindow:(UIWindow *)window
{
    NSAssert(1, @"cannot set window");
}

- (UIWindow *)notificationsWindow
{
    return self.rootViewController.overlayWindow;
}

- (MediaPlaybackManager *)mediaPlaybackManager
{
    if ([self.rootViewController.visibleViewController isKindOfClass:ZClientViewController.class]) {
        ZClientViewController *clientViewController = (ZClientViewController *)self.rootViewController.visibleViewController;
        return clientViewController.mediaPlaybackManager;
    }
    
    return nil;
}

@end

@implementation AppDelegate (PushNotifications)
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    BOOL userGavePermissions = (notificationSettings.types != UIUserNotificationTypeNone);
    AnalyticsTracker *analyticsTracker = [AnalyticsTracker analyticsTrackerWithContext:nil];
    [analyticsTracker tagPushNotificationsPermissions:userGavePermissions];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken
{
    NSString *newToken = [newDeviceToken description];
    
    newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    
    newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
 
    DDLogWarn(@"Received APNS token: %@", newDeviceToken);
    
    [[SessionManager shared] didRegisteredForRemoteNotificationsWith:newDeviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    DDLogInfo(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
    if (error != nil) {
        [[Analytics shared] tagApplicationError:error.localizedDescription
                                  timeInSession:[[UIApplication sharedApplication] lastApplicationRunDuration]];
    }
    DDLogWarn(@"Error registering for push with APNS: %@", error);
    
    AnalyticsTracker *analyticsTracker = [AnalyticsTracker analyticsTrackerWithContext:nil];
    [analyticsTracker tagPushNotificationsPermissions:NO];
}

@end

@implementation AppDelegate (BackgroundUpdates)

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    DDLogInfo(@"application:didReceiveRemoteNotification:fetchCompletionHandler: notification: %@", userInfo);
    if (application.applicationState == UIApplicationStateActive) {
        [[Analytics shared] tagAppLaunchWithType:ApplicationLaunchPush];
        self.trackedResumeEvent = YES;
    }
    
    [[SessionManager shared] didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
    
    self.launchType = (application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground) ? ApplicationLaunchPush: ApplicationLaunchDirect;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    DDLogInfo(@"application:didReceiveLocalNotification: %@", notification);
    
    [[SessionManager shared] didReceiveLocalNotification:notification application:application];
    
    self.launchType = (application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground) ? ApplicationLaunchPush: ApplicationLaunchDirect;
}

- (void)application:(UIApplication *)application
handleActionWithIdentifier:(NSString *)identifier
forLocalNotification:(UILocalNotification *)notification
  completionHandler:(void (^)())completionHandler
{
    DDLogInfo(@"application:handleActionWithIdentifier:forLocalNotification: identifier: %@, notification: %@", identifier, notification);
    
    [[SessionManager shared] handleActionWithIdentifier:identifier
                                   forLocalNotification:notification
                                       withResponseInfo:[NSDictionary dictionary]
                                      completionHandler:completionHandler
                                            application:application];
}

- (void)application:(UIApplication *)application
handleActionWithIdentifier:(NSString *)identifier
forLocalNotification:(UILocalNotification *)notification
   withResponseInfo:(NSDictionary *)responseInfo
  completionHandler:(void(^)())completionHandler;
{
    DDLogInfo(@"application:handleActionWithIdentifier:forLocalNotification: identifier: %@, notification: %@ responseInfo: %@", identifier, notification, responseInfo);
    
    [[SessionManager shared] handleActionWithIdentifier:identifier
                                   forLocalNotification:notification
                                       withResponseInfo:responseInfo
                                      completionHandler:completionHandler
                                            application:application];
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler;
{
    DDLogInfo(@"application:performFetchWithCompletionHandler:");
    
    [self.rootViewController performWhenAuthenticated:^{
        [[ZMUserSession sharedSession] application:application performFetchWithCompletionHandler:completionHandler];
    }];
}


- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler;
{
    DDLogInfo(@"application:handleEventsForBackgroundURLSession:completionHandler: session identifier: %@", identifier);
    
    [self.rootViewController performWhenAuthenticated:^{
        [[ZMUserSession sharedSession] application:application handleEventsForBackgroundURLSession:identifier completionHandler:completionHandler];
    }];
}

@end
