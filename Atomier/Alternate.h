//
//  Alternate.h
//  ReaderStandard
//
//  Created by Choi Jaeyoung on 12/8/11.
//  Copyright (c) 2011 Appcid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Feed;

@interface Alternate : NSManagedObject

@property (nonatomic, retain) NSString * href;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) Feed *feed;

@end
