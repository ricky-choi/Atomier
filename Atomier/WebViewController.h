//
//  WebViewController.h
//  Atomier
//
//  Created by Choi Jaeyoung on 12/20/11.
//  Copyright (c) 2011 Appcid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *stopItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshItem;

@property (strong, nonatomic) NSString *siteURL;
@property (strong, nonatomic) NSURLRequest *siteRequest;

@property (strong, nonatomic) UIActionSheet *actionSheet;

- (void)invalidateWebViewInsets;
- (void)resetNavigationBarForScrollView:(UIScrollView *)scrollView;
- (void)openURL:(NSURL *)url;

- (void)done;

@end
