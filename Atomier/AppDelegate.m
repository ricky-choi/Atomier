//
//  AppDelegate.m
//  Atomier
//
//  Created by Choi Jaeyoung on 12/16/11.
//  Copyright (c) 2011 Appcid. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "Category.h"
#import "Subscription.h"
#import "Feed.h"
#import "Alternate.h"
#import "Tag.h"
#import "Content.h"

#import "ContentOrganizer.h"

#define REFRESH_COUNT_IMMEDIATE 0

#define DEFAULT_KEY_SYNCDATE @"DEFAULT_KEY_SYNCDATE"

@interface AppDelegate ()

- (BOOL)existSignInIDAndPassword;
- (void)showSignInView;

- (NSString *)savedGoogleID;
- (NSString *)savedGooglePassword;

- (void)startRefresh;
- (void)checkLoadDone;
- (BOOL)isLoading;

@end

@implementation AppDelegate {
	BOOL loadingForSubscriptions;
	BOOL loadingForUnreads;
	BOOL loadingForStarreds;
}

@synthesize window = _window;

@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

@synthesize savedCategoryIDs = _savedCategoryIDs;
@synthesize savedSubscriptionIDs = _savedSubscriptionIDs;
@synthesize savedFeedIDs = _savedFeedIDs;
@synthesize savedTags = _savedTags;

@synthesize readyGetIcons = _readyGetIcons;

- (NSMutableArray *)readyGetIcons {
	if (_readyGetIcons == nil) {
		_readyGetIcons = [NSMutableArray arrayWithCapacity:10];
	}
	
	return _readyGetIcons;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	self.savedCategoryIDs = [NSMutableDictionary dictionaryWithCapacity:10];
	self.savedSubscriptionIDs = [NSMutableDictionary dictionaryWithCapacity:50];
	self.savedFeedIDs = [NSMutableDictionary dictionaryWithCapacity:100];
	self.savedTags = [NSMutableDictionary dictionaryWithCapacity:100];
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSArray *allCategories = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
	NSLog(@"Saved Categories: %d", [allCategories count]);
	for (Category *aCategory in allCategories) {
		[self.savedCategoryIDs setValue:aCategory forKey:aCategory.keyId];
	}
	
	entity = [NSEntityDescription entityForName:@"Subscription" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	NSArray *allSubscriptions = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
	NSLog(@"Saved Subscriptions: %d", [allSubscriptions count]);
	for (Subscription *aSubscription in allSubscriptions) {
		[self.savedSubscriptionIDs setValue:aSubscription forKey:aSubscription.keyId];
	}
	
	entity = [NSEntityDescription entityForName:@"Feed" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	NSArray *allFeeds = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
	NSLog(@"Saved Feeds: %d", [allFeeds count]);
	for (Feed *aFeed in allFeeds) {
		[self.savedFeedIDs setValue:aFeed forKey:aFeed.keyId];
	}
	
	entity = [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	NSArray *allTags = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
	NSLog(@"Saved Tags: %d", [allTags count]);
	for (Tag *aTag in allTags) {
		[self.savedTags setValue:aTag forKey:aTag.tag];
	}
	
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
	/*
	 Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	 Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	 */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	/*
	 Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	 If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	 */
	[self saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	/*
	 Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	 */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	/*
	 Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	 */

	GoogleReader *reader = [GoogleReader sharedInstance];
	reader.delegate = self;
	[reader deleteToken];
	
	if ([reader isAuth]) {
		[reader requestToken];
	}
	else if ([reader isAuth] == NO) {
		[self requestSession];		
	}
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	/*
	 Called when the application is about to terminate.
	 Save data if appropriate.
	 See also applicationDidEnterBackground:.
	 */
}

#pragma mark -

- (void)requestSession {
	if ([self existSignInIDAndPassword]) {
		// 저장되어 있는 아이디와 패스워드가 있다.
		[self requestSessionWithEmail:[self savedGoogleID] password:[self savedGooglePassword]];
	} else {
		[self showSignInView];
	}
}

- (void)requestSessionWithEmail:(NSString *)email password:(NSString *)password {
	if (email && password) {
		GoogleReader *reader = [GoogleReader sharedInstance];
		reader.email = email;
		reader.password = password;
		[reader requestSession];
	}	
}

- (void)showSignInView {
	ViewController *viewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
	[self.window.rootViewController presentModalViewController:viewController animated:NO];
}

- (BOOL)existSignInIDAndPassword {
	return ([self savedGoogleID] && [self savedGooglePassword]);
}

- (NSString *)savedGoogleID {
	return nil;
}

- (NSString *)savedGooglePassword {
	return nil;
}

#pragma mark - GoogleReader Delegate

- (void)googleReaderAuthenticateSuccess {
	NSLog(@"googleReaderAuthenticateSuccess");
	
	NSDate *lastSyncDate = [[NSUserDefaults standardUserDefaults] valueForKey:DEFAULT_KEY_SYNCDATE];
	if (lastSyncDate) {
		NSDate *now = [NSDate date];
		NSTimeInterval interval = [now timeIntervalSinceDate:lastSyncDate];
		NSTimeInterval oneDay = 12 * 60 * 60;
		
		if (interval > oneDay) {
			[self refresh];
		}
	}
	else {
		[self refresh];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_LOGIN_SUCCESS
														object:nil
													  userInfo:nil];
}
- (void)googleReaderAuthenticateFailed {
	NSLog(@"googleReaderAuthenticateFailed");
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_LOGIN_FAILED
														object:nil
													  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Authenticate", @"Kind", nil]];
}

- (void)googleReaderRequestTokenFailed {
	NSLog(@"googleReaderRequestTokenFailed");
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_LOGIN_FAILED
														object:nil
													  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Token", @"Kind", nil]];
}

- (void)googleReaderAllSubscriptionsDidDownload:(NSArray *)allSubscriptions {
	NSLog(@"googleReaderAllSubscriptionsDidDownload");
	
	NSLog(@"start feed download: %@", @"allSubscriptions");
	NSMutableDictionary *existCategories = [self.savedCategoryIDs mutableCopy];
	NSMutableDictionary *existSubscriptions = [self.savedSubscriptionIDs mutableCopy];
	
	for (NSDictionary *aSubscription in allSubscriptions) {
		NSString *subscriptionID = [aSubscription valueForKey:@"id"];
		Subscription *subscription = [self.savedSubscriptionIDs valueForKey:subscriptionID];
		if (subscription) {
			[existSubscriptions removeObjectForKey:subscription.keyId];
			// 이미 있는 서브스크립션
			NSMutableSet *existCategoriesForThisSubscription = [subscription.categories mutableCopy];
			NSArray *categories = [aSubscription valueForKey:@"categories"];
			for (NSDictionary *aCategory in categories) {
				NSString *categoryID = [aCategory valueForKey:@"id"];
				
				Category *c = [self.savedCategoryIDs valueForKey:categoryID];
				if (c) {
					[existCategories removeObjectForKey:c.keyId];
					
					if ([subscription.categories containsObject:c]) {
						// 이미 등록되어 있는 카테고리
						[existCategoriesForThisSubscription removeObject:c];
					}		
					else {
						// 없던 카테고리
						[subscription addCategoriesObject:c];
					}
					
				} else {
					// 새로운 카테고리
					Category *newCategory = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
					if (newCategory) {
						newCategory.keyId = categoryID;
						newCategory.label = [aCategory valueForKey:@"label"];
						
						[subscription addCategoriesObject:newCategory];
						
						NSLog(@"ADDED Category: %@", [newCategory description]);
						
						[self.savedCategoryIDs setValue:newCategory forKey:categoryID];
					}					
				}				
			}
			// 이미 저장되어 있던 카테고리에서 새롭게 확인한 카테고리들은 삭제되었다.
			// existCategoriesForThisSubscription 에 남은게 있다면 저장소에서 삭제한다.
			if (existCategoriesForThisSubscription && [existCategoriesForThisSubscription count] > 0) {
				[subscription removeCategories:existCategoriesForThisSubscription];
			}
		}			
		else {
			// 새로운 서브스크립션
			subscription = [NSEntityDescription insertNewObjectForEntityForName:@"Subscription" inManagedObjectContext:self.managedObjectContext];
			
			NSArray *categories = [aSubscription valueForKey:@"categories"];
			for (NSDictionary *aCategory in categories) {
				NSString *categoryID = [aCategory valueForKey:@"id"];
				
				Category *c = [self.savedCategoryIDs valueForKey:categoryID];
				if (c) {
					[existCategories removeObjectForKey:c.keyId];
					[subscription addCategoriesObject:c];
				} else {
					// 새로운 카테고리
					Category *newCategory = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
					if (newCategory) {
						newCategory.keyId = categoryID;
						newCategory.label = [aCategory valueForKey:@"label"];
						
						[subscription addCategoriesObject:newCategory];
						
						NSLog(@"ADDED Category: %@", [newCategory description]);
						
						[self.savedCategoryIDs setValue:newCategory forKey:categoryID];
					}					
				}				
			}
			
			subscription.keyId = subscriptionID;
			subscription.sortid = [aSubscription valueForKey:@"sortid"];
			subscription.title = [aSubscription valueForKey:@"title"];
			
			NSLog(@"ADDED Subscription: %@", [subscription description]);
			
			[self.savedSubscriptionIDs setValue:subscription forKey:subscriptionID];
		}
	}
	
	for (NSString *key in existCategories) {
		Category *willDeleteCategory = [existCategories valueForKey:key];
		[self.managedObjectContext deleteObject:willDeleteCategory];
	}
	for (NSString *key in existSubscriptions) {
		Subscription *willDeleteSubscription = [existSubscriptions valueForKey:key];
		[self.managedObjectContext deleteObject:willDeleteSubscription];
	}
	NSLog(@"end feed download: %@", @"allSubscriptions");
	
	loadingForSubscriptions = NO;
	
	GoogleReader *reader = [GoogleReader sharedInstance];
	[reader getUnreadList];
}

- (void)newFeedsArrival:(NSArray *)arrivals unreadsOrStarred:(BOOL)unreadState {
	
	NSLog(@"start feed download: %@", unreadState ? @"unread" : @"starred");
	NSMutableArray *existFeedObjects = [NSMutableArray arrayWithArray:[self.savedFeedIDs allValues]];
	
	for (NSDictionary *aFeed in arrivals) {
		NSString *feedID = [aFeed valueForKey:@"id"];
		Feed *feed = [self.savedFeedIDs valueForKey:feedID];
		if (feed) {
			//NSLog(@"already exist(%@): %@", feed, unreadState ? @"unread" : @"starred");
			// 이미 있는 피드
			[existFeedObjects removeObject:feed];				
			
			if (unreadState) {
				// unread 목록
				BOOL unreadValue = [feed.unread boolValue];
				if (unreadValue == NO) {
					feed.unread = [NSNumber numberWithBool:YES];
#if REFRESH_COUNT_IMMEDIATE						
					[feed.subscription refreshUnreadCountWithCategory];
#endif
				}
			} else {
				// starred 목록
				BOOL starredValue = [feed.starred boolValue];
				if (starredValue == NO) {
					feed.starred = [NSNumber numberWithBool:YES];
#if REFRESH_COUNT_IMMEDIATE						
					[feed.subscription refreshStarredCountWithCategory];
#endif
				}
			}				
			
		} else {
			// 새로운 피드
			Feed *newFeed = [NSEntityDescription insertNewObjectForEntityForName:@"Feed" inManagedObjectContext:self.managedObjectContext];
			
			if (newFeed) {
				newFeed.unread = [NSNumber numberWithBool:unreadState];
				newFeed.starred = [NSNumber numberWithBool:!unreadState];
				
				NSArray *alternates = [aFeed valueForKey:@"alternate"];
				for (NSDictionary *aAlter in alternates) {
					NSString *href = [aAlter valueForKey:@"href"];
					NSString *type = [aAlter valueForKey:@"type"];
					if (href && type && [href length] > 0 && [type length] > 0) {
						Alternate *newAlternate = [NSEntityDescription insertNewObjectForEntityForName:@"Alternate" inManagedObjectContext:self.managedObjectContext];
						if (newAlternate) {
							newAlternate.href = href;
							newAlternate.type = type;
							
							[newFeed addAlternatesObject:newAlternate];
						}
					}						
				}
				
				NSString *author = [aFeed valueForKey:@"author"];
				if (author && [author length] > 0) {
					newFeed.author = author;
				}
				
				
				NSArray *tags = [aFeed valueForKey:@"categories"];
				for (NSString *aTag in tags) {
					if (aTag && [aTag length] > 0 && ![aTag hasPrefix:@"user/"]) {
						Tag *existTag = [self.savedTags valueForKey:aTag];
						if (existTag) {
							// 이미 있는 태그. 추가해준다.
							[newFeed addTagsObject:existTag];
						} else {
							// 없는 태그. 새로 만들고 추가해준다.
							Tag *newTag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:self.managedObjectContext];
							if (newTag) {
								newTag.tag = aTag;
								
								[newFeed addTagsObject:newTag];
								
								[self.savedTags setValue:newTag forKey:aTag];
							}								
						}
					}
				}
				
				newFeed.keyId = feedID;
				
				NSDictionary *origin = [aFeed valueForKey:@"origin"];
				if (origin) {
					NSString *htmlUrl = [origin valueForKey:@"htmlUrl"];
					NSString *streamId = [origin valueForKey:@"streamId"];
					if (streamId) {
						// 이미 있는 서브스크립션에서 찾는다.
						Subscription *subscriptionForFeed = [self.savedSubscriptionIDs valueForKey:streamId];
						if (subscriptionForFeed) {
							// 찾았다.
							// 원본 주소가 없으면 추가해준다.
							if (subscriptionForFeed.htmlUrl == nil && htmlUrl != nil) {
								subscriptionForFeed.htmlUrl = htmlUrl;
#if 0								
								NSURL *url = [NSURL URLWithString:htmlUrl];

								ContentOrganizer *contentOrganizer = [ContentOrganizer sharedInstance];
								[contentOrganizer makeIcon:[url host] scheme:[url scheme]];
#else
								[self.readyGetIcons addObject:[NSURL URLWithString:htmlUrl]];
#endif
							}
							newFeed.subscription = subscriptionForFeed;
#if REFRESH_COUNT_IMMEDIATE								
							if (unreadState) {
								[newFeed.subscription refreshUnreadCountWithCategory];
							} else {
								[newFeed.subscription refreshStarredCountWithCategory];
							}
#endif	
						} else {
							// 없네... 추가해야 되나?
						}
					}
				}
				
				NSNumber *published = [aFeed valueForKey:@"published"];
				if (published) {
					NSTimeInterval publishedTime = [published doubleValue];
					NSDate *publishedDate = [NSDate dateWithTimeIntervalSince1970:publishedTime];
					newFeed.publishedDate = publishedDate;
				}
				
				newFeed.title = [aFeed valueForKey:@"title"];
				
				NSNumber *updated = [aFeed valueForKey:@"updated"];
				if (updated) {
					NSTimeInterval updatedTime = [updated doubleValue];
					NSDate *updatedDate = [NSDate dateWithTimeIntervalSince1970:updatedTime];
					newFeed.updatedDate = updatedDate;
				}
				
				NSDictionary *content = [aFeed valueForKey:@"content"];
				if (!content) {
					content = [aFeed valueForKey:@"summary"];
				}
				
				if (content) {
					NSString *contentOfContent = [content valueForKey:@"content"];
					//NSLog(@"content: %@", contentOfContent);
					if (contentOfContent && [contentOfContent length] > 0) {
						// 새로운 컨텐트 추가
#if 1
						NSString *filename = [feedID lastPathComponent];
						[[ContentOrganizer sharedInstance] save:contentOfContent forID:filename];
#else
						Content *newContent = [NSEntityDescription insertNewObjectForEntityForName:@"Content" inManagedObjectContext:self.managedObjectContext];
						if (newContent) {
							newContent.content = contentOfContent;								
							newFeed.content = newContent;
						}
#endif
					}
				}
				
				NSLog(@"ADDED Feed: %@", [newFeed description]);
				
				[self.savedFeedIDs setValue:newFeed forKey:feedID];
			}
		}
	}
	
	NSLog(@"delete ready count: %d", [existFeedObjects count]);
	
	for (Feed *targetFeed in existFeedObjects) {
		if (unreadState) {
			targetFeed.unread = [NSNumber numberWithBool:NO];
#if REFRESH_COUNT_IMMEDIATE				
			[targetFeed.subscription refreshUnreadCountWithCategory];
#endif
		} else {
			targetFeed.starred = [NSNumber numberWithBool:NO];
#if REFRESH_COUNT_IMMEDIATE				
			[targetFeed.subscription refreshStarredCountWithCategory];
#endif
		}
	}
	
	NSLog(@"end feed download: %@", unreadState ? @"unread" : @"starred");

	
	if (unreadState) {
		loadingForUnreads = NO;
	} else {
		loadingForStarreds = NO;
	}
	
	[self checkLoadDone];
}

- (void)googleReaderUnreadsDidDownload:(NSArray *)allUnreads {
	NSLog(@"googleReaderUnreadsDidDownload");
	
	[self newFeedsArrival:allUnreads unreadsOrStarred:YES];
	
	GoogleReader *reader = [GoogleReader sharedInstance];
	[reader getStaredList];
}
- (void)googleReaderStaredDidDownload:(NSArray *)allStareds {
	NSLog(@"googleReaderStaredDidDownload");
	
	[self newFeedsArrival:allStareds unreadsOrStarred:NO];
}

#pragma mark - 

- (void)startRefresh {
	loadingForSubscriptions = YES;
	loadingForUnreads = YES;
	loadingForStarreds = YES;
}

- (void)refreshUnreadAndStarred:(int)state {
	// state 0: all
	// state 1: unread only
	// state 2: star only
	NSLog(@"refresh count all");
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Subscription" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	NSArray *allSubscriptions = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
	for (Subscription *aSubscription in allSubscriptions) {
		if (state == 1) {
			[aSubscription refreshUnreadCount];
		}
		else if (state == 2) {
			[aSubscription refreshStarredCount];
		}
		else {
			[aSubscription refreshUnreadCount];
			[aSubscription refreshStarredCount];
		}
		
	}
	
	entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	NSArray *allCategories = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
	for (Category *aCategory in allCategories) {
		if (state == 1) {
			[aCategory refreshUnreadCount];
		}
		else if (state == 2) {
			[aCategory refreshStarredCount];
		}
		else {
			[aCategory refreshUnreadCount];
			[aCategory refreshStarredCount];
		}
		
	}
}

- (void)checkLoadDone {
	NSLog(@"check load done: %@, %@, %@", loadingForSubscriptions ? @"YES" : @"NO", loadingForUnreads ? @"YES" : @"NO", loadingForStarreds ? @"YES" : @"NO");
	if (loadingForSubscriptions == NO && loadingForUnreads == NO && loadingForStarreds == NO) {
		// loading complete
		
		[[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:DEFAULT_KEY_SYNCDATE];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
#if (REFRESH_COUNT_IMMEDIATE == 0)
		[self refreshUnreadAndStarred:0];
#endif		
		
		[self saveContext];
		
		if ([self.readyGetIcons count] > 0) {
			for (NSURL *url in self.readyGetIcons) {
				ContentOrganizer *contentOrganizer = [ContentOrganizer sharedInstance];
				[contentOrganizer makeIcon:[url host] scheme:[url scheme]];
			}			
		}
		[self.readyGetIcons removeAllObjects];
		self.readyGetIcons = nil;
	}
}

- (BOOL)isLoading {
	return loadingForSubscriptions || loadingForUnreads || loadingForStarreds;
}

- (void)saveContext {
	NSLog(@"saveContext ready");
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges])
        {
			NSLog(@"saveContext hasChanges");
			if (![managedObjectContext save:&error]) {
				/*
				 Replace this implementation with code to handle the error appropriately.
				 
				 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
				 */
				NSLog(@"saveContext Unresolved error %@, %@", error, [error userInfo]);
				abort();
			}            
        } 
    }
}

- (NSURL *)applicationDocumentsDirectory {
	return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)applicationCachesDirectory {
	return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)refresh {
	if ([self isLoading]) {
		return;
	}

	[self startRefresh];
	
	GoogleReader *reader = [GoogleReader sharedInstance];
	[reader getSubscriptionList];
}

- (void)unsubscribe:(Subscription *)subscription {
	NSLog(@"unsubscribe: %@", subscription.keyId);
	[[GoogleReader sharedInstance] unsubscribeToRSSFeedURL:subscription.keyId];
	
	NSSet *willDeleteFeeds = subscription.feeds;
	for (Feed *willDeleteFeed in willDeleteFeeds) {
		NSSet *willDeleteAlternates = willDeleteFeed.alternates;
		for (Alternate *willDeleteAlternate in willDeleteAlternates) {
			NSLog(@"will delete alternate: %@", willDeleteAlternate);
			[self.managedObjectContext deleteObject:willDeleteAlternate];
		}
		
		NSLog(@"will delete feed: %@", willDeleteFeed);
		[self.savedFeedIDs removeObjectForKey:willDeleteFeed.keyId];
		[self.managedObjectContext deleteObject:willDeleteFeed];
	}
	
	NSLog(@"will delete subscription: %@", subscription);
	[self.savedSubscriptionIDs removeObjectForKey:subscription.keyId];
	[self.managedObjectContext deleteObject:subscription];
	
	[self saveContext];
}

- (void)markAsRead:(Feed *)feed {
	if ([feed.unread boolValue] == YES) {
		feed.unread = [NSNumber numberWithBool:NO];
		[[GoogleReader sharedInstance] markReadAtFeedID:feed.keyId forFeed:feed.subscription.keyId];
	}
}

- (void)markAsAllRead:(NSArray *)feeds {
	for (Feed *feed in feeds) {
		[self markAsRead:feed];
	}
	
	[self refreshUnreadAndStarred:1];
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
//    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ReaderStandard" withExtension:@"momd"];
//    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
	__managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationCachesDirectory] URLByAppendingPathComponent:@"ReaderStandard.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

@end
