//
//  NewWebViewController.h
//  Atomier
//
//  Created by Choi Jaeyoung on 12. 3. 13..
//  Copyright (c) 2012년 Appcid. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NewWebViewControllerDelegate <NSObject>

- (void)webViewControllerAttempClose;

@end

@interface NewWebViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) id <NewWebViewControllerDelegate> delegate;

@property (strong, nonatomic) UIWebView *webView;

@property (strong, nonatomic) UIBarButtonItem *backItem;
@property (strong, nonatomic) UIBarButtonItem *forwardItem;
@property (strong, nonatomic) UIBarButtonItem *stopItem;
@property (strong, nonatomic) UIBarButtonItem *reloadItem;
@property (strong, nonatomic) UIBarButtonItem *loadingItem;
@property (strong, nonatomic) UIBarButtonItem *actionItem;
@property (strong, nonatomic) UIBarButtonItem *flexibleSpaceItem;

@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@property (strong, nonatomic) NSArray *toolbarItemsWithStop;
@property (strong, nonatomic) NSArray *toolbarItemsWithReload;

@property (strong, nonatomic) NSString *siteURL;
@property (strong, nonatomic) NSURLRequest *siteRequest;

@property (strong, nonatomic) UIBarButtonItem *doneItem;

@property (strong, nonatomic) UIActionSheet *actionSheet;

- (void)startSpin;
- (void)stopSpin;

- (void)hideActionSheetAnimated:(BOOL)animated;

- (void)openURL:(NSURL *)url;

@end
