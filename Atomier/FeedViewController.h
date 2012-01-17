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

@property (strong, nonatomic) IBOutlet UIBarButtonItem *previousButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *nextButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *unreadItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *starredItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *actionItem;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *toggleListItem;

@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UIView *bottomView;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (void)replaceWithNewFeed:(Feed *)newFeed direction:(BOOL)up;

- (IBAction)previousFeed:(id)sender;
- (IBAction)nextFeed:(id)sender;
- (IBAction)toggleUnread:(id)sender;
- (IBAction)toggleStarred:(id)sender;
- (IBAction)shareAction:(id)sender;

- (NSString *)feedTitle;


@end
