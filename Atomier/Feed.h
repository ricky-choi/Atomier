//
//  Feed.h
//  ReaderStandard
//
//  Created by Choi Jaeyoung on 12/8/11.
//  Copyright (c) 2011 Appcid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Subscription;
@class Content;

@interface Feed : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * keyId;
@property (nonatomic, retain) NSDate * publishedDate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * unread;
@property (nonatomic, retain) NSNumber * starred;
@property (nonatomic, retain) NSSet *alternates;
@property (nonatomic, retain) NSSet *tags;
@property (nonatomic, retain) Content *content;
@property (nonatomic, retain) Subscription *subscription;

@property (nonatomic, retain) NSDate * updatedDate;
@property (nonatomic, retain) NSDate * primitiveUpdatedDate;
@property (nonatomic, retain) NSString *sectionIdentifier;
@property (nonatomic, retain) NSString *primitiveSectionIdentifier;

@property (nonatomic, retain) NSNumber * stay;

@end

@interface Feed (CoreDataGeneratedAccessors)

- (void)addAlternatesObject:(NSManagedObject *)value;
- (void)removeAlternatesObject:(NSManagedObject *)value;
- (void)addAlternates:(NSSet *)values;
- (void)removeAlternates:(NSSet *)values;

- (void)addTagsObject:(NSManagedObject *)value;
- (void)removeTagsObject:(NSManagedObject *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
