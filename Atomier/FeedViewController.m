//
//  FeedViewController.m
//  Atomier
//
//  Created by Choi Jaeyoung on 12/20/11.
//  Copyright (c) 2011 Appcid. All rights reserved.
//

#import <Twitter/Twitter.h>
#import "FeedViewController.h"
#import "Feed.h"
#import "Content.h"
#import "ContentOrganizer.h"
#import "Subscription.h"
#import "AppDelegate.h"
#import "Alternate.h"
#import "NSString+HTML.h"
#import "SimpleFeedsViewController.h"

#define HELPERVIEW_HEIGHT 80.0f
#define LABEL_HEIGHT 20.0f
#define USE_CONTENT_ORGANIZER 0

@interface FeedViewController ()

- (void)invalidateFeedNavigateButtons;
- (void)resetTopAndBottomView:(UIScrollView *)scrollView;
- (void)setHelperViewTitle:(NSString *)title description:(NSString *)description top:(BOOL)top;
- (void)removeShadowAtWebView:(UIWebView *)webview;

- (NSString *)contentForFeed:(Feed *)feed;

@end

@implementation FeedViewController {
	BOOL animating;
}

@synthesize delegate = _delegate;

@synthesize feeds = _feeds;
@synthesize feed = _feed;

@synthesize previousButtonItem = _previousButtonItem;
@synthesize nextButtonItem = _nextButtonItem;
@synthesize unreadItem = _unreadItem;
@synthesize starredItem = _starredItem;
@synthesize actionItem = _actionItem;
@synthesize toggleListItem = _toggleListItem;

@synthesize topView = _topView;
@synthesize bottomView = _bottomView;

@synthesize popover = _popover;

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

- (NSString *)feedTitle {
	if (self.feed) {
		return [self.feed.title stringByReplacingHTMLEntities];
	}
	
	return nil;
}

- (void)selectFeedInList {
	
}

- (void)setFeed:(Feed *)feed {
	if (_feed != feed) {
		_feed = feed;
		
		[self selectFeedInList];
	}
}

- (void)setHelperViewTitle:(NSString *)title description:(NSString *)description top:(BOOL)top {
	UILabel *titleLabel, *descriptionLabel;
	if (top) {
		titleLabel = (UILabel *)[self.topView viewWithTag:101];
		descriptionLabel = (UILabel *)[self.topView viewWithTag:102];
	} else {
		titleLabel = (UILabel *)[self.bottomView viewWithTag:201];
		descriptionLabel = (UILabel *)[self.bottomView viewWithTag:202];
	}
	
	if (titleLabel) {
		titleLabel.text = title;
	}
	
	if (descriptionLabel) {
		descriptionLabel.text = description;
	}
}

- (UIView *)topView {
	if (_topView == nil) {
		_topView = [[UIView alloc] initWithFrame:CGRectMake(0, -HELPERVIEW_HEIGHT, self.webView.frame.size.width, HELPERVIEW_HEIGHT)];
		_topView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		_topView.backgroundColor = [UIColor clearColor];
		
		UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, HELPERVIEW_HEIGHT/2.0f - LABEL_HEIGHT, _topView.frame.size.width - 20, LABEL_HEIGHT)];
		titleLabel.tag = 101;
		titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.textAlignment = UITextAlignmentCenter;
		titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		[_topView addSubview:titleLabel];
		
		UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, HELPERVIEW_HEIGHT/2.0f, titleLabel.frame.size.width, LABEL_HEIGHT)];
		descriptionLabel.tag = 102;
		descriptionLabel.font = [UIFont systemFontOfSize:12.0];
		descriptionLabel.textColor = [UIColor lightGrayColor];
		descriptionLabel.backgroundColor = [UIColor clearColor];
		descriptionLabel.textAlignment = UITextAlignmentCenter;
		descriptionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		[_topView addSubview:descriptionLabel];
	}
	
	return _topView;
}

- (UIView *)bottomView {
	if (_bottomView == nil) {
		_bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, -HELPERVIEW_HEIGHT, self.webView.frame.size.width, HELPERVIEW_HEIGHT)];
		_bottomView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		_bottomView.backgroundColor = [UIColor clearColor];
		
		UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, HELPERVIEW_HEIGHT/2.0f - LABEL_HEIGHT, _bottomView.frame.size.width - 20, LABEL_HEIGHT)];
		titleLabel.tag = 201;
		titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.textAlignment = UITextAlignmentCenter;
		titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		[_bottomView addSubview:titleLabel];
		
		UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, HELPERVIEW_HEIGHT/2.0f, titleLabel.frame.size.width, LABEL_HEIGHT)];
		descriptionLabel.tag = 202;
		descriptionLabel.font = [UIFont systemFontOfSize:13.0];
		descriptionLabel.textColor = [UIColor lightGrayColor];
		descriptionLabel.backgroundColor = [UIColor clearColor];
		descriptionLabel.textAlignment = UITextAlignmentCenter;
		descriptionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		[_bottomView addSubview:descriptionLabel];
	}
	
	return _bottomView;
}

- (NSString *)contentForFeed:(Feed *)feed {
#if USE_CONTENT_ORGANIZER
	return [[ContentOrganizer sharedInstance] contentForID:[feed.keyId lastPathComponent]];
#else
	Content *contentManagedObject = feed.content;
	return contentManagedObject.content;
#endif
	
	return nil;
}

- (void)showFeed:(Feed *)feed toView:(UIWebView *)webView {
	
	// remove uiwebview shadow
	[self removeShadowAtWebView:webView];
	
	NSString *content = [self contentForFeed:feed];
	NSString *source = [(Alternate *)[feed.alternates anyObject] href];
	NSString *dateString = [NSDateFormatter localizedStringFromDate:feed.updatedDate
														 dateStyle:NSDateFormatterLongStyle
														 timeStyle:NSDateFormatterShortStyle];
	NSString *feedTitle = feed.title;
	NSString *subscriptionTitle = feed.subscription.title;
	NSString *author = feed.author;
	
	if (source == nil) {
		source = @"";
	}
	
	if (dateString == nil) {
		dateString = @"";
	}
	
	if (feedTitle == nil) {
		feedTitle = @"";
	}
	
	if (subscriptionTitle == nil) {
		subscriptionTitle = @"";
	}
	
	if (author == nil) {
		subscriptionTitle = @"";
	}
	
	NSString *cssFile = nil;
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		cssFile = @"main~ipad.css";
	} else {
	    cssFile = @"main~iphone.css";
	}
	
	NSString *template = [NSString stringWithFormat:@"<meta name = \"viewport\" content = \"width = device-width, user-scalable = no, initial-scale = 1.0\" /><link href=\"%@\" rel=\"stylesheet\" type=\"text/css\" /><body><div class=\"header\"><span id=\"subscription\">%@</span><a id=\"header\" href=\"%@\"><span id=\"title\">%@</span><span id=\"author\">%@</span></a><span id=\"date\">%@</span></div><div class=\"syndi-content\">%@</div></body>", cssFile, subscriptionTitle, source, feedTitle, author, dateString, content];
	
	NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
	[webView loadHTMLString:template baseURL:baseURL];
	
	feed.stay = [NSNumber numberWithBool:YES];
	
	if ([feed.unread boolValue] == YES) {
		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		[appDelegate markAsRead:feed];
		[appDelegate saveContext];
	}
}

- (void)removeShadowAtWebView:(UIWebView *)webview {
//	for (UIView *subview in [webview.scrollView subviews]) {
//		if ([subview isKindOfClass:[UIImageView class]]) {
//			subview.hidden = YES;
//		}
//	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	
	
	self.unreadItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"UnreadOff"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleUnread:)];
	self.starredItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"StarredOff"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleStarred:)];
	self.previousButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(previousFeed:)];
	self.nextButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(nextFeed:)];
	self.actionItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareAction:)];
	
	UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//		UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
//		self.toggleListItem = [[UIBarButtonItem alloc] initWithTitle:@"List" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleList:)];
//		
//		self.navigationItem.leftBarButtonItem = nil;
//		self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:doneItem, self.toggleListItem, nil];
		
	    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.actionItem, self.starredItem, self.unreadItem, nil];
		self.toolbarItems = [NSArray arrayWithObjects:self.previousButtonItem, flexibleItem, self.nextButtonItem, nil];
	} else {
		//self.navigationItem.rightBarButtonItem = self.actionItem;
	    self.toolbarItems = [NSArray arrayWithObjects:self.unreadItem, flexibleItem, self.starredItem, flexibleItem, self.previousButtonItem, flexibleItem, self.nextButtonItem, flexibleItem, self.actionItem, nil];
	}
	
	if (self.feed) {		
		[self showFeed:self.feed toView:self.webView];
		//self.title = [self feedTitle];
		
		//[self invalidateFeedNavigateButtons];
		
		[self.view addSubview:self.topView];
		[self.view addSubview:self.bottomView];
		
		
	} 
}

- (void)done {
	if ([self.actionSheet isVisible]) {
		[self.actionSheet dismissWithClickedButtonIndex:self.actionSheet.cancelButtonIndex animated:YES];
	}
	
	if (_delegate && [_delegate respondsToSelector:@selector(feedViewControllerWillClose:)]) {
		[_delegate feedViewControllerWillClose:self.feed];
	}
	else {
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

- (UIPopoverController *)popover {
	if (_popover) {
		return _popover;
	}
	
	SimpleFeedsViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SimpleFeedsViewController"];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	_popover = [[UIPopoverController alloc] initWithContentViewController:navigationController];
	
	return _popover;
}

- (void)toggleList:(UIBarButtonItem *)item {
	if ([self.popover isPopoverVisible]) {
		[self.popover dismissPopoverAnimated:YES];
	} else {
		[self.popover presentPopoverFromBarButtonItem:item permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (self.feed) {		
		[self invalidateFeedNavigateButtons];
	} 
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	if (_popover) {
		if ([self.popover isPopoverVisible]) {
			[self.popover dismissPopoverAnimated:YES];
		}
	}
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
	
	if (self.topView.hidden == NO) {
		NSUInteger index = [self.feeds indexOfObject:self.feed];
		if (index > 0) {
			Feed *newFeed = [self.feeds objectAtIndex:index-1];
			[self setHelperViewTitle:[newFeed.title stringByReplacingHTMLEntities] description:newFeed.subscription.title top:YES];
		}
	}
	if (self.bottomView.hidden == NO) {
		NSUInteger index = [self.feeds indexOfObject:self.feed];
		if (index < [self.feeds count] - 1) {
			Feed *newFeed = [self.feeds objectAtIndex:index+1];
			[self setHelperViewTitle:[newFeed.title stringByReplacingHTMLEntities] description:newFeed.subscription.title top:NO];
		}
	}
	
	if ([self.feed.unread boolValue]) {
		[self.unreadItem setImage:[UIImage imageNamed:@"UnreadOn"]];
	} else {
		[self.unreadItem setImage:[UIImage imageNamed:@"UnreadOff"]];
	}
	
	if ([self.feed.starred boolValue]) {
		[self.starredItem setImage:[UIImage imageNamed:@"StarredOn"]];
	} else {
		[self.starredItem setImage:[UIImage imageNamed:@"StarredOff"]];
	}
}

- (void)viewDidUnload
{
    [self setPreviousButtonItem:nil];
    [self setNextButtonItem:nil];

    [self setUnreadItem:nil];
    [self setStarredItem:nil];
    [self setActionItem:nil];
	
	[self setToggleListItem:nil];
	
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
	return YES;
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		NSURL *url = request.URL;
		NSString *scheme = url.scheme;
		NSString *host = url.host;
		
		if ([host isEqualToString:@"itunes.apple.com"]) {
			[self openURL:url];
		}
		else if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]) {
			WebViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
			viewController.siteRequest = request;
			if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
				[self.navigationController pushViewController:viewController animated:YES];
			} else {
				UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
				[self presentViewController:navigationController animated:YES completion:nil];
			}
			
		} else {
			[self openURL:url];
		}
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
	
	//[self removeShadowAtWebView:newWebView];
	
	UIScrollView *scrollView = newWebView.scrollView;
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    CGFloat barHeight;
		
		if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
			barHeight = 44.0f;
		} else {
			barHeight = 32.0f;
		}
		scrollView.contentInset = UIEdgeInsetsMake(barHeight, 0, 0, 0);
	}	
	
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
							
							//self.title = [self feedTitle];
							
							animating = NO;
							
							[self resetTopAndBottomView:scrollView];
						}
					}];
}

- (IBAction)previousFeed:(id)sender {
	if ([self.actionSheet isVisible]) {
		[self.actionSheet dismissWithClickedButtonIndex:self.actionSheet.cancelButtonIndex animated:YES];
	}
	
	if (!animating && self.feeds && self.feed) {
		NSUInteger index = [self.feeds indexOfObject:self.feed];
		if (index > 0) {
			Feed *newFeed = [self.feeds objectAtIndex:index-1];
			[self replaceWithNewFeed:newFeed direction:YES];
		}
	}
}

- (IBAction)nextFeed:(id)sender {
	if ([self.actionSheet isVisible]) {
		[self.actionSheet dismissWithClickedButtonIndex:self.actionSheet.cancelButtonIndex animated:YES];
	}
	
	if (!animating && self.feeds && self.feed) {
		NSUInteger index = [self.feeds indexOfObject:self.feed];
		if (index < [self.feeds count] - 1) {
			Feed *newFeed = [self.feeds objectAtIndex:index+1];
			[self replaceWithNewFeed:newFeed direction:NO];
		}
	}
}

- (IBAction)toggleUnread:(id)sender {
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if ([self.feed.unread boolValue]) {
		[appDelegate markAsRead:self.feed];
	} else {
		[appDelegate markAsUnread:self.feed];
	}
	[appDelegate saveContext];
	
	[self invalidateFeedNavigateButtons];
}

- (IBAction)toggleStarred:(id)sender {
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if ([self.feed.starred boolValue]) {
		[appDelegate markAsUnstarred:self.feed];
	} else {
		[appDelegate markAsStarred:self.feed];
	}
	[appDelegate saveContext];
	
	[self invalidateFeedNavigateButtons];
}

- (IBAction)shareAction:(id)sender {
	if ([self.actionSheet isVisible]) {
		[self.actionSheet dismissWithClickedButtonIndex:self.actionSheet.cancelButtonIndex animated:YES];
	}
	
	Alternate *alternate = [self.feed.alternates anyObject];
	NSURL *sourceURL = [NSURL URLWithString:alternate.href];
	if (sourceURL) {
		
		if ([TWTweetComposeViewController canSendTweet]) {
			self.actionSheet = [[UIActionSheet alloc] initWithTitle:alternate.href 
													  delegate:self
											 cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
										destructiveButtonTitle:nil
											 otherButtonTitles:NSLocalizedString(@"Open in Safari", nil)
						   , NSLocalizedString(@"Copy Link", nil)
						   , NSLocalizedString(@"Mail Link", nil)
						   , NSLocalizedString(@"Mail Article", nil)
						   , NSLocalizedString(@"Send to Twitter", nil)
						   , nil];
		}
		else {
			self.actionSheet = [[UIActionSheet alloc] initWithTitle:alternate.href 
													  delegate:self
											 cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
										destructiveButtonTitle:nil
											 otherButtonTitles:NSLocalizedString(@"Open in Safari", nil)
						   , NSLocalizedString(@"Copy Link", nil)
						   , NSLocalizedString(@"Mail Link", nil)
						   , NSLocalizedString(@"Mail Article", nil)
						   , nil];
		}
		
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
			[self.actionSheet showFromBarButtonItem:sender animated:YES];
		} else {
			[self.actionSheet showFromToolbar:self.navigationController.toolbar];
		}
				 
	}	
}

-(void)launchMailAppOnDevice:(NSString *)title body:(NSString *)body
{
	NSString *email = [[NSString stringWithFormat:@"mailto:?subject=%@&body=%@", title, body] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

-(void)displayComposerSheet:(NSString *)title body:(NSString *)body
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:title];
	[picker setMessageBody:body isHTML:YES];
	
	[self presentModalViewController:picker animated:YES];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			//message.text = @"Result: canceled";
			break;
		case MFMailComposeResultSaved:
			//message.text = @"Result: saved";
			break;
		case MFMailComposeResultSent:
			//message.text = @"Result: sent";
			break;
		case MFMailComposeResultFailed:
			//message.text = @"Result: failed";
			break;
		default:
			//message.text = @"Result: not sent";
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
}

- (void)mail:(NSString *)title body:(NSString *)body 
{
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil)
	{
		// We must always check whether the current device is configured for sending emails
		if ([mailClass canSendMail])
		{
			[self displayComposerSheet:title body:body];
		}
		else
		{
			[self launchMailAppOnDevice:title body:body];
		}
	}
	else
	{
		[self launchMailAppOnDevice:title body:body];
	}
}
									  
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.cancelButtonIndex) {
		return;
	}
	
	Alternate *alternate = [self.feed.alternates anyObject];
	NSURL *sourceURL = [NSURL URLWithString:alternate.href];
	
	UIApplication *app = [UIApplication sharedApplication];
	
	if (buttonIndex == actionSheet.firstOtherButtonIndex) {
		// Open in Safari
		if ([app canOpenURL:sourceURL]) {
			[app openURL:sourceURL];
		}
	}
	else if (buttonIndex == actionSheet.firstOtherButtonIndex + 1) {
		// Copy Link
		UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
		pasteboard.URL = sourceURL;
	}
	else if (buttonIndex == actionSheet.firstOtherButtonIndex + 2) {
		// Mail Link
		NSString *link = [NSString stringWithFormat:@"<a href=\"%@\">%@</a>", alternate.href, alternate.href];
		[self mail:[self feedTitle] body:link];
	}
	else if (buttonIndex == actionSheet.firstOtherButtonIndex + 3) {
		// Mail Article
		[self mail:[self feedTitle] body:[self contentForFeed:self.feed]];
	}
	else if (buttonIndex == actionSheet.firstOtherButtonIndex + 4) {
		// Send to Twitter
		// Set up the built-in twitter composition view controller.
		TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
		
		// Set the initial tweet text. See the framework for additional properties that can be set.
		[tweetViewController setInitialText:[self feedTitle]];
		[tweetViewController addURL:sourceURL];
		
		// Create the completion handler block.
		[tweetViewController setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
			//NSString *output;
			
			switch (result) {
				case TWTweetComposeViewControllerResultCancelled:
					// The cancel button was tapped.
					//output = @"Tweet cancelled.";
					break;
				case TWTweetComposeViewControllerResultDone:
					// The tweet was sent.
					//output = @"Tweet done.";
					break;
				default:
					break;
			}
			
			//[self performSelectorOnMainThread:@selector(displayText:) withObject:output waitUntilDone:NO];
			
			// Dismiss the tweet composition view controller.
			[self dismissModalViewControllerAnimated:YES];
		}];
		
		// Present the tweet composition view controller modally.
		[self presentModalViewController:tweetViewController animated:YES];
		
	}
}

- (void)resetTopAndBottomView:(UIScrollView *)scrollView {
	CGPoint offset = scrollView.contentOffset;
	CGFloat barHeight = HELPERVIEW_HEIGHT;
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
