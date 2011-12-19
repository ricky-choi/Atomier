//
//  PreviewFeed.m
//  Atomier
//
//  Created by Choi Jaeyoung on 12/18/11.
//  Copyright (c) 2011 Appcid. All rights reserved.
//

#import "PreviewFeed.h"
#import "Feed.h"
#import "ContentOrganizer.h"

@implementation PreviewFeed

@synthesize delegate = _delegate;
@synthesize feed = _feed;
@synthesize summary = _summary;
@synthesize image = _image;
@synthesize needRefresh = _needRefresh;
@synthesize headerView = _headerView;

- (void)dealloc {
	self.delegate = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setFeed:(Feed *)feed {
	if (_feed != feed) {
		_feed = feed;
		
		if (![self allDataExist]) {
			ContentOrganizer *contentOrganizer = [ContentOrganizer sharedInstance];
			NSString *contentID = [feed.keyId lastPathComponent];
			
			if (_summary == nil) {
				self.summary = [contentOrganizer summaryForID:contentID];
			}
			
			if (_image == nil) {
				if ([contentOrganizer existFirstImageForID:contentID]) {
					self.image = [contentOrganizer firstImageForID:contentID];
				} else {
					[[NSNotificationCenter defaultCenter] addObserver:self
															 selector:@selector(imageDownloaded:)
																 name:@"ImageDownload"
															   object:nil];
				}
			}
		}
	}
}

- (void)imageDownloaded:(NSNotification *)notification {
	NSDictionary *userInfo = [notification userInfo];
	NSString *downloadedImageContentID = [userInfo valueForKey:@"contentID"];
	NSString *thisContentID = [_feed.keyId lastPathComponent];
	NSLog(@"image downloaded: %@ < %@", thisContentID, downloadedImageContentID);
	
	if ([thisContentID isEqualToString:downloadedImageContentID]) {
		[[NSNotificationCenter defaultCenter] removeObserver:self
														name:@"ImageDownload"
													  object:nil];
		UIImage *downloadedImage = [notification object];
		self.image = downloadedImage;
		
		if (_delegate && [_delegate respondsToSelector:@selector(previewFeedImageDownloadCompleted:)]) {
			[_delegate previewFeedImageDownloadCompleted:self];
		}
	}
}

- (BOOL)allDataExist {
	return _feed && _summary && _image;
}

- (UIView *)headerView {
	if (_headerView == nil) {
		_headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
		
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 160, 100)];
		imageView.image = self.image;
		
		UILabel *summaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 0, 160, 100)];
		summaryLabel.text = self.summary;
		
		[_headerView addSubview:imageView];
		[_headerView addSubview:summaryLabel];
	}
	
	return _headerView;
}

@end
