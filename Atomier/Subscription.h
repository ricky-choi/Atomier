//
//  Subscription.h
//  ReaderStandard
//
//  Created by Choi Jaeyoung on 12/8/11.
//  Copyright (c) 2011 Appcid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Category, Feed;

@interface Subscription : NSManagedObject

@property (nonatomic, retain) NSString * htmlUrl;
@property (nonatomic, retain) NSString * keyId;
@property (nonatomic, retain) NSString * sortid;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *categories;
@property (nonatomic, retain) NSSet *feeds;
@property (nonatomic, retain) NSNumber *unreadCount;
@property (nonatomic, retain) NSNumber *starredCount;

- (void)refreshUnreadCount;
- (void)refreshStarredCount;
- (void)refreshUnreadCountWithCategory;
- (void)refreshStarredCountWithCategory;

- (NSArray *)feedsByDate:(BOOL)ascending;
- (Feed *)latestFeed;

- (NSArray *)unreadFeedsByDate:(BOOL)ascending;
- (Feed *)unreadLatestFeed;

- (NSArray *)starredFeedsByDate:(BOOL)ascending;
- (Feed *)starredLatestFeed;

@end

@interface Subscription (CoreDataGeneratedAccessors)

- (void)addCategoriesObject:(Category *)value;
- (void)removeCategoriesObject:(Category *)value;
- (void)addCategories:(NSSet *)values;
- (void)removeCategories:(NSSet *)values;

- (void)addFeedsObject:(Feed *)value;
- (void)removeFeedsObject:(Feed *)value;
- (void)addFeeds:(NSSet *)values;
- (void)removeFeeds:(NSSet *)values;

@end
