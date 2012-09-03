//
//  Category.h
//  ReaderStandard
//
//  Created by Choi Jaeyoung on 12/8/11.
//  Copyright (c) 2011 Appcid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Feed;
@class Subscription;

@interface Category : NSManagedObject

@property (nonatomic, retain) NSString * keyId;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSSet *subscriptions;
@property (nonatomic, retain) NSNumber *unreadCount;
@property (nonatomic, retain) NSNumber *starredCount;

- (void)refreshUnreadCount;
- (void)refreshStarredCount;

- (NSUInteger)allCount;

- (Subscription *)anySubscription;
- (Feed *)anyFeed;

- (Feed *)latestFeed;
- (Feed *)unreadLatestFeed;
- (Feed *)starredLatestFeed;

@end

@interface Category (CoreDataGeneratedAccessors)

- (void)addSubscriptionsObject:(NSManagedObject *)value;
- (void)removeSubscriptionsObject:(NSManagedObject *)value;
- (void)addSubscriptions:(NSSet *)values;
- (void)removeSubscriptions:(NSSet *)values;

@end
