//
//  Subscription.m
//  ReaderStandard
//
//  Created by Choi Jaeyoung on 12/8/11.
//  Copyright (c) 2011 Appcid. All rights reserved.
//

#import "Subscription.h"
#import "Category.h"
#import "Feed.h"


@implementation Subscription

@dynamic htmlUrl;
@dynamic keyId;
@dynamic sortid;
@dynamic title;
@dynamic categories;
@dynamic feeds;
@dynamic unreadCount;
@dynamic starredCount;

- (void)refreshUnreadCount {
	__block NSUInteger count = 0;
	[self.feeds enumerateObjectsUsingBlock:^(id obj, BOOL *stop){
		Feed *aFeed = (Feed *)obj;
		if ([[aFeed unread] boolValue] == YES) {
			count++;
		}
	}];
	self.unreadCount = [NSNumber numberWithUnsignedInteger:count];
}

- (void)refreshStarredCount {
	__block NSUInteger count = 0;
	[self.feeds enumerateObjectsUsingBlock:^(id obj, BOOL *stop){
		Feed *aFeed = (Feed *)obj;
		if ([[aFeed starred] boolValue] == YES) {
			count++;
		}
	}];
	self.starredCount = [NSNumber numberWithUnsignedInteger:count];
}

- (void)refreshUnreadCountWithCategory {
	[self refreshUnreadCount];
	
	[self.categories enumerateObjectsUsingBlock:^(id obj, BOOL *stop){
		Category *aCategory = (Category *)obj;
		[aCategory refreshUnreadCount];
	}];
}

- (void)refreshStarredCountWithCategory {
	[self refreshStarredCount];
	
	[self.categories enumerateObjectsUsingBlock:^(id obj, BOOL *stop){
		Category *aCategory = (Category *)obj;
		[aCategory refreshStarredCount];
	}];
}

- (NSUInteger)allCount {
	return [self.feeds count];
}

- (NSArray *)feedsByDate:(BOOL)ascending {
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updatedDate" ascending:ascending];
	return [self.feeds sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}

- (Feed *)latestFeed {
	return [[self feedsByDate:YES] lastObject];
}

- (NSArray *)unreadFeedsByDate:(BOOL)ascending {
	NSPredicate *unreadPredicate = [NSPredicate predicateWithFormat:@"unread = 1"];
	NSSet *unreadFeeds = [self.feeds filteredSetUsingPredicate:unreadPredicate];
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updatedDate" ascending:ascending];
	return [unreadFeeds sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}

- (Feed *)unreadLatestFeed {
	return [[self unreadFeedsByDate:YES] lastObject];
}

- (NSArray *)starredFeedsByDate:(BOOL)ascending {
	NSPredicate *starredPredicate = [NSPredicate predicateWithFormat:@"starred = 1"];
	NSSet *starredFeeds = [self.feeds filteredSetUsingPredicate:starredPredicate];
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updatedDate" ascending:ascending];
	return [starredFeeds sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}

- (Feed *)starredLatestFeed {
	return [[self starredFeedsByDate:YES] lastObject];
}


@end
