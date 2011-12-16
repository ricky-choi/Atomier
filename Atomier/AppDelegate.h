//
//  AppDelegate.h
//  Atomier
//
//  Created by Choi Jaeyoung on 12/16/11.
//  Copyright (c) 2011 Appcid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogleReader.h"

#define kNOTIFICATION_LOGIN_SUCCESS @"kNOTIFICATION_LOGIN_SUCCESS"
#define kNOTIFICATION_LOGIN_FAILED @"kNOTIFICATION_LOGIN_FAILED"

@interface AppDelegate : UIResponder <UIApplicationDelegate, GoogleReaderDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) NSMutableDictionary *savedCategoryIDs;
@property (strong, nonatomic) NSMutableDictionary *savedSubscriptionIDs;
@property (strong, nonatomic) NSMutableDictionary *savedFeedIDs;
@property (strong, nonatomic) NSMutableDictionary *savedTags;

- (void)requestSession;
- (void)requestSessionWithEmail:(NSString *)email password:(NSString *)password;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (NSURL *)applicationCachesDirectory;

- (void)refresh;

@end
