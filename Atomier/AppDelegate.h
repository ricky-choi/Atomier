//
//  AppDelegate.h
//  Atomier
//
//  Created by Choi Jaeyoung on 12/16/11.
//  Copyright (c) 2011 Appcid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogleReader.h"
#import "Subscription.h"
#import "Reachability.h"
#import "LoginViewController.h"

#define DEFAULT_KEY_LAST_UPDATE @"DEFAULT_KEY_LAST_UPDATE"
#define DEFAULT_KEY_SORT_DATE @"sortDateAscending"
#define DEFAULT_KEY_AD @"DEFAULT_KEY_AD"

#define kNOTIFICATION_LOGIN_SUCCESS @"kNOTIFICATION_LOGIN_SUCCESS"
#define kNOTIFICATION_LOGIN_FAILED @"kNOTIFICATION_LOGIN_FAILED"

#ifdef FREE_FOR_PROMOTION
#define kKEYCHAIN_SERVICE @"com.felaur.syndifree"
#else
#define kKEYCHAIN_SERVICE @"com.felaur.syndi"
#endif

#define kKEYCHAIN_ACCOUNT_ID @"SyndiAccountID"
#define kKEYCHAIN_ACCOUNT_PASSWORD @"SyndiAccountPW"

#define MY_BANNER_UNIT_ID @"a14f26a1d66744d"

@class LoginViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, GoogleReaderDelegate, LoginViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) NSMutableDictionary *savedCategoryIDs;
@property (strong, nonatomic) NSMutableDictionary *savedSubscriptionIDs;
@property (strong, nonatomic) NSMutableDictionary *savedFeedIDs;
@property (strong, nonatomic) NSMutableDictionary *savedTags;

@property (strong, nonatomic) NSMutableArray *readyGetIcons;

@property (strong, nonatomic) LoginViewController *loginViewController;

- (NSString *)savedGoogleID;

- (void)requestSession;
- (void)requestSessionWithEmail:(NSString *)email password:(NSString *)password;
- (void)signout;
- (void)deleteAllData;
- (NSURL *)storeURL;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (NSURL *)applicationCachesDirectory;

- (void)refresh;
- (void)unsubscribe:(Subscription *)subscription;

- (void)markAsRead:(Feed *)feed;
- (void)markAsUnread:(Feed *)feed;
- (void)markAsAllRead:(NSArray *)feeds;

- (void)markAsStarred:(Feed *)feed;
- (void)markAsUnstarred:(Feed *)feed;

- (BOOL)isBadge;
- (int)syncRule;

- (void)setBadge:(BOOL)on;
- (void)setSyncRule:(int)rule;

- (NSUInteger)unreadCount;

- (NetworkStatus)reachability;
- (BOOL)isWiFi;
- (BOOL)isConnectedToNetwork;

- (void)showNoInternet;

- (BOOL)showAD;

@end
