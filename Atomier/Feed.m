//
//  Feed.m
//  ReaderStandard
//
//  Created by Choi Jaeyoung on 12/8/11.
//  Copyright (c) 2011 Appcid. All rights reserved.
//

#import "Feed.h"
#import "Content.h"
#import "Subscription.h"

#define kSectionIdentifier @"sectionIdentifier"
#define kUpdatedDate @"updatedDate"

@implementation Feed

@dynamic author;
@dynamic keyId;
@dynamic publishedDate;
@dynamic title;
@dynamic unread;
@dynamic starred;
@dynamic alternates;
@dynamic tags;
@dynamic content;
@dynamic subscription;

@dynamic updatedDate;
@dynamic primitiveUpdatedDate;
@dynamic sectionIdentifier;
@dynamic primitiveSectionIdentifier;

- (NSString *)sectionIdentifier {
	[self willAccessValueForKey:kSectionIdentifier];
	NSString *tmp = [self primitiveSectionIdentifier];
	[self didAccessValueForKey:kSectionIdentifier];
	
	if (!tmp) {
		NSCalendar *calendar = [NSCalendar currentCalendar];
		
		NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self.updatedDate];
		tmp = [NSString stringWithFormat:@"%d", ([components year] * 10000) + ([components month] * 100) + [components day]];
		[self setPrimitiveSectionIdentifier:tmp];
	}
	
	return tmp;
}

- (void)setUpdatedDate:(NSDate *)newDate {
	[self willChangeValueForKey:kUpdatedDate];
	[self setPrimitiveUpdatedDate:newDate];
	[self didChangeValueForKey:kUpdatedDate];
	
	[self setPrimitiveSectionIdentifier:nil];
}

+ (NSSet *)keyPathsForValuesAffectingSectionIdentifier {
	return [NSSet setWithObject:kUpdatedDate];
}

@end
