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
#import "WebViewController.h"

@interface FeedViewController ()

- (void)toggleHiddenBars;
- (void)invalidateWebViewInsets;

@end

@implementation FeedViewController
@synthesize webView = _webView;
@synthesize feeds = _feeds;
@synthesize feed = _feed;

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

- (void)invalidateWebViewInsets {
	BOOL hidden = self.navigationController.navigationBar.hidden;
	UIScrollView *scrollView = self.webView.scrollView;
	
	if (hidden) {
		scrollView.contentInset = UIEdgeInsetsZero;
		scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
	} else {
		float statusBarHeight = 0;
		if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
			statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
		} else {
			statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.width;
		}
		UIEdgeInsets insets = UIEdgeInsetsMake(statusBarHeight + self.navigationController.navigationBar.frame.size.height, 0, self.navigationController.toolbar.frame.size.height, 0);
		NSLog(@"insets: %@", NSStringFromUIEdgeInsets(insets));
		scrollView.contentInset = insets;
		scrollView.scrollIndicatorInsets = insets;
	}
}

- (void)toggleHiddenBars {
	BOOL hidden = self.navigationController.navigationBar.hidden;
	
	self.navigationController.navigationBar.hidden = !hidden;
	self.navigationController.toolbar.hidden = !hidden;
	[[UIApplication sharedApplication] setStatusBarHidden:!hidden withAnimation:UIStatusBarAnimationNone];
	
	[self invalidateWebViewInsets];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	UIBarButtonItem *fullscreenItem = [[UIBarButtonItem alloc] initWithTitle:@"Full" style:UIBarButtonItemStyleBordered target:self action:@selector(fullscreen)];
	self.navigationItem.rightBarButtonItem = fullscreenItem;
	
	if (self.feed) {
		self.wantsFullScreenLayout = YES;
		
		NSString *content = [[ContentOrganizer sharedInstance] contentForID:[self.feed.keyId lastPathComponent]];
		
		NSString *template = [NSString stringWithFormat:@"<meta name = \"viewport\" content = \"width = device-width, user-scalable = no, initial-scale = 1.0\" /><link href=\"main.css\" rel=\"stylesheet\" type=\"text/css\" /><body>%@</body>", content];
		
		NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
		
		self.webView.delegate = self;
		[self.webView loadHTMLString:template baseURL:baseURL];
		
		UIScrollView *scrollView = self.webView.scrollView;
		scrollView.delegate = self;
		
		[self invalidateWebViewInsets];
	} 
}

- (void)fullscreen {
	[self toggleHiddenBars];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
	self.navigationController.toolbar.barStyle = self.navigationController.navigationBar.barStyle;
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
	self.navigationController.toolbar.barStyle = self.navigationController.navigationBar.barStyle;
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:animated];
}

- (void)viewDidUnload
{
	self.webView.delegate = nil;
	[self setWebView:nil];
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
	[self invalidateWebViewInsets];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		WebViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
		viewController.siteRequest = request;
		[self.navigationController pushViewController:viewController animated:YES];
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

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView                                               // any offset changes
{
	
}

// called on start of dragging (may require some time and or distance to move)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	
}
// called on finger up if the user dragged. velocity is in points/second. targetContentOffset may be changed to adjust where the scroll view comes to rest. not called when pagingEnabled is YES
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_5_0) {
	
}
// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView   // called on finger up as we are moving
{
	
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView      // called when scroll view grinds to a halt
{
	
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView // called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
{
	
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView      // called when scrolling animation finished. may be called immediately if already at top
{
	
}

@end
