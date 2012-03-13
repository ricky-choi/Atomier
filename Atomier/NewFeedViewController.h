//
//  NewFeedViewController.h
//  Atomier
//
//  Created by Choi Jaeyoung on 12. 3. 13..
//  Copyright (c) 2012년 Appcid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "NewWebViewController.h"

#define USE_CONTENT_ORGANIZER 1

@class Feed;

@interface NewFeedViewController : UIViewController <UIWebViewDelegate, NewWebViewControllerDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (strong, nonatomic) Feed *feed;

@property (weak, nonatomic) IBOutlet UIImageView *topBarImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *starButton;

@property (strong, nonatomic) UIActionSheet *actionSheet;

- (IBAction)action:(id)sender;
- (IBAction)toggleStar:(id)sender;

- (void)prepare;
- (void)unprepare;
- (void)purge;

- (void)markAsRead:(BOOL)read;

- (NSString *)feedTitle;
- (NSString *)contentForFeed:(Feed *)feed;

@end
