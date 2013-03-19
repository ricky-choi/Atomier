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

@protocol NewFeedViewControllerDelegate <NSObject>
@optional
- (void)touchedEmptyContent;
- (void)forceFullscreen:(BOOL)on;

@end

@class Feed;

@interface NewFeedViewController : UIViewController <UIWebViewDelegate, NewWebViewControllerDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) id <NewFeedViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@property (strong, nonatomic) Feed *feed;

@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UIImageView *topBarImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *starButton;

@property (strong, nonatomic) UIActionSheet *actionSheet;

@property (strong, nonatomic) UITapGestureRecognizer *tapWebViewGesture;

@property (assign, nonatomic) BOOL fullscreen;

- (IBAction)action:(id)sender;
- (IBAction)toggleStar:(id)sender;

- (void)showFullScreen:(BOOL)fullscreen;

- (void)prepare;
- (void)unprepare;
- (void)purge;

- (void)markAsRead:(BOOL)read;

- (NSString *)feedTitle;
- (NSString *)contentForFeed:(Feed *)feed;

@end
