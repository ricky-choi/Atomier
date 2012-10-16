//
//  ContentOrganizer.h
//  ReaderStandard
//
//  Created by Choi Jaeyoung on 12/12/11.
//  Copyright (c) 2011 Appcid. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContentOrganizer : NSObject

+ (id)sharedInstance;




- (void)save:(NSString *)contentString forID:(NSString *)contentID;
- (void)saveForChche:(NSString *)contentString forID:(NSString *)contentID;
- (NSString *)contentForID:(NSString *)contentID;



- (void)makeSummaryAndFirstImageForID:(NSString *)contentID;

- (void)saveSummary:(NSString *)summaryString forID:(NSString *)contentID;
- (NSString *)summaryForID:(NSString *)contentID;

- (NSArray *)imagesForID:(NSString *)contentID;
- (NSArray *)imageURLsForID:(NSString *)contentID;
- (UIImage *)firstImageForID:(NSString *)contentID;
- (NSURL *)firstImageURLForID:(NSString *)contentID;

- (BOOL)existSummaryAndFirstImageForID:(NSString *)contentID;
- (BOOL)existSummaryForID:(NSString *)contentID;
- (BOOL)existFirstImageForID:(NSString *)contentID;



- (UIImage *)iconForSubscription:(NSString *)host;
- (UIImage *)touchIconForSubscription:(NSString *)host;

- (void)makeIcon:(NSString *)host scheme:(NSString *)scheme;
- (void)makeIcon:(NSString *)host scheme:(NSString *)scheme withTouchIcon:(BOOL)touch;

@end
