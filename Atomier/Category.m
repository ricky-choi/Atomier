//
//  Category.m
//  ReaderStandard
//
//  Created by Choi Jaeyoung on 12/8/11.
//  Copyright (c) 2011 Appcid. All rights reserved.
//

#import "Category.h"
#import "Subscription.h"
#import "Feed.h"

@implementation Category

@dynamic keyId;
@dynamic label;
@dynamic subscriptions;
@dynamic unreadCount;
@dynamic starredCount;

- (void)refreshUnreadCount {
	__block NSUInteger count = 0;
	[self.subscriptions enumerateObjectsUsingBlock:^(id obj, BOOL *stop){
		Subscription *aSubscription = (Subscription *)obj;
		count += [[aSubscription unreadCount] unsignedIntegerValue];
	}];
	self.unreadCount = [NSNumber numberWithUnsignedInteger:count];
}

- (void)refreshStarredCount {
	__block NSUInteger count = 0;
	[self.subscriptions enumerateObjectsUsingBlock:^(id obj, BOOL *stop){
		Subscription *aSubscription = (Subscription *)obj;
		count += [[aSubscription starredCount] unsignedIntegerValue];
	}];
	self.starredCount = [NSNumber numberWithUnsignedInteger:count];
}

- (NSUInteger)allCount {
	NSUInteger value = 0;
	
	for (Subscription *subscription in self.subscriptions) {
		value += [subscription allCount];
	}
	
	return value;
}

- (Feed *)latestFeed {	
	__block Subscription *returnSubscription = nil;
	[self.subscriptions enumerateObjectsUsingBlock:^(id obj, BOOL *stop){
		Subscription *subscription = (Subscription *)obj;
		if (returnSubscription) {
			if ([subscription latestFeed]) {
				if ([subscription latestFeed].updatedDate > [returnSubscription latestFeed].updatedDate) {
					returnSubscription = subscription;
				}
			}
		} else if ([subscription latestFeed]) {
			returnSubscription = subscription;
		}
	}];
	
	return [returnSubscription latestFeed];
}

- (Feed *)unreadLatestFeed {
	__block Subscription *returnSubscription = nil;
	[self.subscriptions enumerateObjectsUsingBlock:^(id obj, BOOL *stop){
		Subscription *subscription = (Subscription *)obj;
		if (returnSubscription) {
			if ([subscription unreadLatestFeed]) {
				if ([subscription unreadLatestFeed].updatedDate > [returnSubscription unreadLatestFeed].updatedDate) {
					returnSubscription = subscription;
				}
			}
		} else if ([subscription unreadLatestFeed]) {
			returnSubscription = subscription;
		}
	}];
	
	return [returnSubscription unreadLatestFeed];
}

- (Feed *)starredLatestFeed {
	__block Subscription *returnSubscription = nil;
	[self.subscriptions enumerateObjectsUsingBlock:^(id obj, BOOL *stop){
		Subscription *subscription = (Subscription *)obj;
		if (returnSubscription) {
			if ([subscription starredLatestFeed]) {
				if ([subscription starredLatestFeed].updatedDate > [returnSubscription starredLatestFeed].updatedDate) {
					returnSubscription = subscription;
				}
			}
		} else if ([subscription starredLatestFeed]) {
			returnSubscription = subscription;
		}
	}];
	
	return [returnSubscription starredLatestFeed];
}

- (Subscription *)anySubscription {
	return [self.subscriptions anyObject];
}

- (Feed *)anyFeed {
	return [[[self anySubscription] feeds] anyObject];
}

@end
