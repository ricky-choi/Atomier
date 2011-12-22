//
//  WebViewController.m
//  Atomier
//
//  Created by Choi Jaeyoung on 12/20/11.
//  Copyright (c) 2011 Appcid. All rights reserved.
//

#import "WebViewController.h"

@implementation WebViewController

@synthesize webView = _webView;
@synthesize siteURL = _siteURL;
@synthesize siteRequest = _siteRequest;
@synthesize stopItem = _stopItem;
@synthesize backItem = _backItem;
@synthesize forwardItem = _forwardItem;
@synthesize refreshItem = _refreshItem;

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

- (void)invalidateControls {
	self.backItem.enabled = [self.webView canGoBack];
	self.forwardItem.enabled = [self.webView canGoForward];
	if ([self.webView isLoading]) {
		self.stopItem.enabled = YES;
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	} else {
		self.stopItem.enabled = NO;
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	}
	self.refreshItem.enabled = !self.stopItem.enabled;
	
	self.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (void)invalidateWebViewInsets {
	UIScrollView *scrollView = self.webView.scrollView;
	
	CGFloat barHeight;

	if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
		barHeight = 44.0f;
	} else {
		barHeight = 32.0f;
	}
	scrollView.contentInset = UIEdgeInsetsMake(barHeight, 0, 0, 0);
	
	self.webView.frame = CGRectMake(0, - barHeight, self.view.frame.size.width, self.view.frame.size.height + barHeight);
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	if ([[self.navigationController viewControllers] count] == 1) {
		UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
		self.navigationItem.leftBarButtonItem = doneItem;
	}
	
	if (self.siteRequest) {
		[self.webView loadRequest:self.siteRequest];
		[self invalidateControls];
	}
	else if (self.siteURL) {
		[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.siteURL]]];
		[self invalidateControls];
	}
	
	UIScrollView *scrollView = self.webView.scrollView;
	scrollView.delegate = self;
	
	[self invalidateWebViewInsets];
	
	
}

- (void)done {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self resetNavigationBarForScrollView:self.webView.scrollView];
	
	if (self.navigationController.toolbarHidden == YES) {
		[self.navigationController setToolbarHidden:NO animated:YES];
	}
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
	CGFloat barHeight = self.navigationController.navigationBar.frame.size.height;
	CGFloat barWidth = self.webView.frame.size.width;
	CGFloat statusBarHeight = 20.0;
	self.navigationController.navigationBar.frame = CGRectMake(0, statusBarHeight, barWidth, barHeight);
}

- (void)viewDidUnload
{
	self.webView.delegate = nil;
	[self setWebView:nil];
	[self setStopItem:nil];
	[self setBackItem:nil];
	[self setForwardItem:nil];
	[self setRefreshItem:nil];

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

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[self resetNavigationBarForScrollView:self.webView.scrollView];
	[self invalidateWebViewInsets];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[self invalidateControls];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[self invalidateControls];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[self invalidateControls];
}

#pragma mark - UIScrollViewDelegate

- (void)resetNavigationBarForScrollView:(UIScrollView *)scrollView {
	CGPoint offset = scrollView.contentOffset;
	CGFloat barHeight = self.navigationController.navigationBar.frame.size.height;
	CGFloat barWidth = self.webView.frame.size.width;
	CGFloat statusBarHeight = 20.0;
	if (offset.y > -(scrollView.contentInset.top)) {
		CGFloat newY = -offset.y - barHeight + statusBarHeight;
		self.navigationController.navigationBar.frame = CGRectMake(0, newY, barWidth, barHeight);
	}
	else {
		self.navigationController.navigationBar.frame = CGRectMake(0, statusBarHeight, barWidth, barHeight);
	}
	
	float scrollInset = -offset.y;
	if (scrollInset < 0) {
		scrollInset = 0;
	}
	else if (scrollInset > barHeight) {
		scrollInset = barHeight;
	}
	
	scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(scrollInset, 0, 0, 0);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	//NSLog(@"scrollViewDidScroll: %@", scrollView);
	
	[self resetNavigationBarForScrollView:scrollView];
}
@end
