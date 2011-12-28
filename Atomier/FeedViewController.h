//
//  FeedViewController.h
//  Atomier
//
//  Created by Choi Jaeyoung on 12/20/11.
//  Copyright (c) 2011 Appcid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "WebViewController.h"

@class Feed;

@interface FeedViewController : WebViewController <UIWebViewDelegate, UIScrollViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) NSArray *feeds;
@property (strong, nonatomic) Feed *feed;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *unreadItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *starredItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionItem;

@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UIView *bottomView;

- (IBAction)previousFeed:(id)sender;
- (IBAction)nextFeed:(id)sender;
- (IBAction)toggleUnread:(id)sender;
- (IBAction)toggleStarred:(id)sender;
- (IBAction)shareAction:(id)sender;


@end
