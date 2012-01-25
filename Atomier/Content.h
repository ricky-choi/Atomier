//
//  Content.h
//  ReaderStandard
//
//  Created by Choi Jaeyoung on 12/8/11.
//  Copyright (c) 2011 Appcid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Feed;

@interface Content : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString *summary;
@property (nonatomic, retain) NSString *offlineContent;
@property (nonatomic, retain) Feed *feed;

@end
