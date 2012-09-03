//
//  PreviewFeed.h
//  Atomier
//
//  Created by Choi Jaeyoung on 12/18/11.
//  Copyright (c) 2011 Appcid. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Feed;
@class PreviewFeed;

@protocol PreviewFeedDelegate <NSObject>

@optional
- (void)previewFeedImageDownloadCompleted:(PreviewFeed *)sender;

@end

@interface PreviewFeed : NSObject

@property (nonatomic, weak) id <PreviewFeedDelegate> delegate;

@property (nonatomic, retain) Feed *feed;
@property (nonatomic, retain) NSString *summary;
@property (nonatomic, retain) UIImage *image;

@property (nonatomic, assign) BOOL needRefresh;
@property (nonatomic, retain) UIView *headerView;

- (BOOL)allDataExist;

@end
