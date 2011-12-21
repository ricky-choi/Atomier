//
//  FeedViewController.h
//  Atomier
//
//  Created by Choi Jaeyoung on 12/20/11.
//  Copyright (c) 2011 Appcid. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Feed;

@interface FeedViewController : UIViewController <UIWebViewDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (strong, nonatomic) NSArray *feeds;
@property (strong, nonatomic) Feed *feed;

@end
