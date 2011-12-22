//
//  FeedViewController.m
//  Atomier
//
//  Created by Choi Jaeyoung on 12/20/11.
//  Copyright (c) 2011 Appcid. All rights reserved.
//

#import "FeedViewController.h"
#import "Feed.h"
#import "ContentOrganizer.h"

@interface FeedViewController ()

- (void)resetTopAndBottomView:(UIScrollView *)scrollView;

@end

@implementation FeedViewController {
	BOOL animating;
}

@synthesize feeds = _feeds;
@synthesize feed = _feed;
@synthesize previousButtonItem = _previousButtonItem;
@synthesize nextButtonItem = _nextButtonItem;
@synthesize topView = _topView;
@synthesize bottomView = _bottomView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

- (UIView *)topView {
	if (_topView == nil) {
		_topView = [[UIView alloc] init];
		// #E6E3DE
		_topView.backgroundColor = [UIColor colorWithRed:230 green:227 blue:222 alpha:1];
	}
	
	return _topView;
}

- (UIView *)bottomView {
	if (_bottomView == nil) {
		_bottomView = [[UIView alloc] init];
		_bottomView.backgroundColor = [UIColor whiteColor];
	}
	
	return _bottomView;
}

- (void)invalidateFeedNavigateButtons {
	if ([self.feeds count] > 1) {
		NSUInteger index = [self.feeds indexOfObject:self.feed];
		if (index == 0) {
			self.previousButtonItem.enabled = NO;
			self.nextButtonItem.enabled = YES;
		}
		else if (index == [self.feeds count] - 1) {
			self.previousButtonItem.enabled = YES;
			self.nextButtonItem.enabled = NO;
		}
		else {
			self.previousButtonItem.enabled = YES;
			self.nextButtonItem.enabled = YES;
		}
	} else {
		self.previousButtonItem.enabled = NO;
		self.nextButtonItem.enabled = NO;
	}
	
	self.topView.hidden = !self.previousButtonItem.enabled;
	self.bottomView.hidden = !self.nextButtonItem.enabled;
}

- (void)showFeed:(Feed *)feed toView:(UIWebView *)webView {
	NSString *content = [[ContentOrganizer sharedInstance] contentForID:[feed.keyId lastPathComponent]];
	
	NSString *template = [NSString stringWithFormat:@"<meta name = \"viewport\" content = \"width = device-width, user-scalable = no, initial-scale = 1.0\" /><link href=\"main.css\" rel=\"stylesheet\" type=\"text/css\" /><body>%@</body>", content];
	
	NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
	[webView loadHTMLString:template baseURL:baseURL];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	if (self.feed) {		
		[self showFeed:self.feed toView:self.webView];
		
		[self invalidateFeedNavigateButtons];
		
		[self.view addSubview:self.topView];
		[self.view addSubview:self.bottomView];
	} 
}

- (void)viewDidUnload
{
    [self setPreviousButtonItem:nil];
    [self setNextButtonItem:nil];

    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	}
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		WebViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
		viewController.siteRequest = request;
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
		[self presentViewController:navigationController animated:YES completion:nil];
		
		return NO;
	}
	
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)replaceWithNewFeed:(Feed *)newFeed direction:(BOOL)up {
	animating = YES;
	
	CGRect rightFrame = self.webView.frame;
	CGRect beforeFrame = rightFrame;
	CGRect afterFrame = rightFrame;
	
	if (up) {
		beforeFrame.origin.y -= rightFrame.size.height;
		afterFrame.origin.y += rightFrame.size.height;
	} else {
		beforeFrame.origin.y += rightFrame.size.height;
		afterFrame.origin.y -= rightFrame.size.height;
	}
	
	UIWebView *newWebView = [[UIWebView alloc] initWithFrame:beforeFrame];
	newWebView.autoresizingMask = self.webView.autoresizingMask;
	newWebView.backgroundColor = self.webView.backgroundColor;
	newWebView.scalesPageToFit = self.webView.scalesPageToFit;
	newWebView.dataDetectorTypes = self.webView.dataDetectorTypes;
	newWebView.allowsInlineMediaPlayback = self.webView.allowsInlineMediaPlayback;
	newWebView.mediaPlaybackAllowsAirPlay = self.webView.mediaPlaybackAllowsAirPlay;
	newWebView.mediaPlaybackRequiresUserAction = self.webView.mediaPlaybackRequiresUserAction;
	
	UIScrollView *scrollView = newWebView.scrollView;
	
	CGFloat barHeight;
	
	if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
		barHeight = 44.0f;
	} else {
		barHeight = 32.0f;
	}
	scrollView.contentInset = UIEdgeInsetsMake(barHeight, 0, 0, 0);
	
	[self showFeed:newFeed toView:newWebView];
	[self.view insertSubview:newWebView atIndex:0];
	
	[UIView transitionWithView:self.view
					  duration:0.3
					   options:UIViewAnimationOptionCurveEaseInOut
					animations:^ {
						self.webView.frame = afterFrame;
						newWebView.frame = rightFrame;
					}
					completion:^(BOOL finished) {
						if (finished) {
							[self.webView setDelegate:nil];
							[self.webView.scrollView setDelegate:nil];
							[self.webView removeFromSuperview];
							
							self.webView = newWebView;
							self.webView.scrollView.delegate = self;
							self.feed = newFeed;
							self.webView.delegate = self;
							
							[self invalidateFeedNavigateButtons];							
							[self resetNavigationBarForScrollView:self.webView.scrollView];
							
							self.title = self.feed.title;
							
							animating = NO;
							
							[self resetTopAndBottomView:scrollView];
						}
					}];
}

- (IBAction)previousFeed:(id)sender {
	if (!animating && self.feeds && self.feed) {
		NSUInteger index = [self.feeds indexOfObject:self.feed];
		if (index > 0) {
			Feed *newFeed = [self.feeds objectAtIndex:index-1];
			[self replaceWithNewFeed:newFeed direction:YES];
		}
	}
}

- (IBAction)nextFeed:(id)sender {
	if (!animating && self.feeds && self.feed) {
		NSUInteger index = [self.feeds indexOfObject:self.feed];
		if (index < [self.feeds count] - 1) {
			Feed *newFeed = [self.feeds objectAtIndex:index+1];
			[self replaceWithNewFeed:newFeed direction:NO];
		}
	}
}

- (void)resetTopAndBottomView:(UIScrollView *)scrollView {
	CGPoint offset = scrollView.contentOffset;
	CGFloat barHeight = 60.0f;
	CGFloat barWidth = self.webView.frame.size.width;
	CGFloat newTopY = -offset.y - scrollView.contentInset.top - barHeight;
	self.topView.frame = CGRectMake(0, newTopY, barWidth, barHeight);
	
	CGFloat newBottomY = newTopY + scrollView.contentSize.height + barHeight;
	self.bottomView.frame = CGRectMake(0, newBottomY, barWidth, barHeight);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[super scrollViewDidScroll:scrollView];
	
	[self resetTopAndBottomView:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	
	if (self.topView.frame.origin.y > 0) {
		[self previousFeed:nil];
	}
	else if (self.bottomView.frame.origin.y < self.view.frame.size.height - self.bottomView.frame.size.height) {
		[self nextFeed:nil];
	}
}

@end
