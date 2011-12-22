//
//  FeedViewController.h
//  Atomier
//
//  Created by Choi Jaeyoung on 12/20/11.
//  Copyright (c) 2011 Appcid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebViewController.h"

@class Feed;

@interface FeedViewController : WebViewController <UIWebViewDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) NSArray *feeds;
@property (strong, nonatomic) Feed *feed;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButtonItem;

- (IBAction)previousFeed:(id)sender;
- (IBAction)nextFeed:(id)sender;


@end
