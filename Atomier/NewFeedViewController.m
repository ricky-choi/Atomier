//
//  NewFeedViewController.m
//  Atomier
//
//  Created by Choi Jaeyoung on 12. 3. 13..
//  Copyright (c) 2012년 Appcid. All rights reserved.
//

#import <Social/Social.h>
#import <Twitter/Twitter.h>
#import "NewFeedViewController.h"
#import "Feed.h"
#import "ContentOrganizer.h"
#import "NSString+HTML.h"
#import "Subscription.h"
#import "Alternate.h"
#import "AppDelegate.h"

@interface NewFeedViewController ()

- (void)invalidateSize:(BOOL)fullscreen;

@end

@implementation NewFeedViewController

@synthesize delegate = _delegate;
@synthesize webView = _webView;

@synthesize feed = _feed;
@synthesize topBar = _topBar;

@synthesize topBarImageView = _topBarImageView;

@synthesize titleLabel = _titleLabel;
@synthesize starButton = _starButton;

@synthesize actionSheet = _actionSheet;

@synthesize tapWebViewGesture = _tapWebViewGesture;

@synthesize fullscreen = _fullscreen;

- (void)dealloc {
	self.delegate = nil;
}

- (UIActionSheet *)actionSheet {
	if (_actionSheet == nil) {
		Alternate *alternate = [self.feed.alternates anyObject];
		NSURL *sourceURL = [NSURL URLWithString:alternate.href];
		if (sourceURL) {
			
			NSString *markString = nil;
			if ([[self.feed unread] boolValue]) {
				markString = NSLocalizedString(@"Mark as read", nil);
			} else {
				markString = NSLocalizedString(@"Mark as unread", nil);
			}
            
            if ([SLComposeViewController class]) {
                // enable facebook and sinaweibo
                self.actionSheet = [[UIActionSheet alloc] initWithTitle:alternate.href
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                 destructiveButtonTitle:markString
                                                      otherButtonTitles:NSLocalizedString(@"Open in Safari", nil)
                                    , NSLocalizedString(@"Copy Link", nil)
                                    , NSLocalizedString(@"Mail Link", nil)
                                    , NSLocalizedString(@"Mail Article", nil)
                                    , NSLocalizedString(@"Send to Twitter", nil)
                                    , NSLocalizedString(@"Send to Facebook", nil)
                                    , NSLocalizedString(@"Send to SinaWeibo", nil)
                                    , nil];
            } else {
                // enable twitter only
                self.actionSheet = [[UIActionSheet alloc] initWithTitle:alternate.href
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                 destructiveButtonTitle:markString
                                                      otherButtonTitles:NSLocalizedString(@"Open in Safari", nil)
                                    , NSLocalizedString(@"Copy Link", nil)
                                    , NSLocalizedString(@"Mail Link", nil)
                                    , NSLocalizedString(@"Mail Article", nil)
                                    , NSLocalizedString(@"Send to Twitter", nil)
                                    , nil];
            }
		}
	}
	
	return _actionSheet;
}

-(void)launchMailAppOnDevice:(NSString *)title body:(NSString *)body
{
	NSString *email = [[NSString stringWithFormat:@"mailto:?subject=%@&body=%@", title, body] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

-(void)displayComposerSheet:(NSString *)title body:(NSString *)body
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	[picker.navigationItem.leftBarButtonItem setTintColor:[UIColor redColor]];
	[picker.navigationItem.rightBarButtonItem setTintColor:nil];
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
	
	if (buttonIndex == actionSheet.destructiveButtonIndex) {
		[self markAsRead:[[self.feed unread] boolValue]];		
	} else {
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
			NSString *link = [NSString stringWithFormat:@"<a href=\"%@\">%@</a><br><br>Sent with <a href=\"%@\">%@</a>", alternate.href, alternate.href, @"http://itunes.apple.com/us/app/syndi-rss-reader/id498935649?ls=1&mt=8", @"Syndi RSS"];
			[self mail:[self feedTitle] body:link];
		}
		else if (buttonIndex == actionSheet.firstOtherButtonIndex + 3) {
			// Mail Article
			NSString *body = [NSString stringWithFormat:@"<p><a href=\"%@\">%@</a></p>%@<p>Sent with <a href=\"%@\">%@</a></p>", alternate.href, alternate.href, [self contentForFeed:self.feed], @"http://itunes.apple.com/us/app/syndi-rss-reader/id498935649?ls=1&mt=8", @"Syndi RSS"];
			[self mail:[self feedTitle] body:body];
		}
		else if (buttonIndex == actionSheet.firstOtherButtonIndex + 4) {
            // Send to Twitter
            if ([SLComposeViewController class]) {
                [self composeSocialMessageForServiceType:SLServiceTypeTwitter];
            } else {
                [self composeSocialMessageForLegacyTwitter];
            }
		}
		else if (buttonIndex == actionSheet.firstOtherButtonIndex + 5) {
            // facebook
			[self composeSocialMessageForServiceType:SLServiceTypeFacebook];
		}
        else if (buttonIndex == actionSheet.firstOtherButtonIndex + 6) {
            // Sina Weibo
            [self composeSocialMessageForServiceType:SLServiceTypeSinaWeibo];
        }
	}
}

- (void)composeSocialMessageForLegacyTwitter {
	if ([TWTweetComposeViewController canSendTweet]) {
		// Set up the built-in twitter composition view controller.
		TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
		
		// Set the initial tweet text. See the framework for additional properties that can be set.
		[tweetViewController setInitialText:[self feedTitle]];
		
		Alternate *alternate = [self.feed.alternates anyObject];
		NSURL *sourceURL = [NSURL URLWithString:alternate.href];
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
	} else {
		[self showUnavailableAlertForServiceName:NSLocalizedString(@"Twitter", nil)];
	}
}

- (void)composeSocialMessageForServiceType:(NSString *)serviceType {
    if ([SLComposeViewController class]) {
		if ([SLComposeViewController isAvailableForServiceType:serviceType]) {
			SLComposeViewController *viewController = [SLComposeViewController composeViewControllerForServiceType:serviceType];
			[viewController setInitialText:[self feedTitle]];
			
			Alternate *alternate = [self.feed.alternates anyObject];
			NSURL *sourceURL = [NSURL URLWithString:alternate.href];
			[viewController addURL:sourceURL];
			
			[self presentViewController:viewController animated:YES completion:nil];
		} else {
			[self showUnavailableAlertForServiceType:serviceType];
		}
    }
}

- (void)showUnavailableAlertForServiceType:(NSString *)serviceType
{
	NSString *serviceName = @"";
	if (serviceType == SLServiceTypeFacebook) {
		serviceName = NSLocalizedString(@"Facebook", nil);
	}
	else if (serviceType == SLServiceTypeSinaWeibo) {
		serviceName = NSLocalizedString(@"Sina Weibo", nil);
	}
	else if (serviceType == SLServiceTypeTwitter) {
		serviceName = NSLocalizedString(@"Twitter", nil);
	}
	
	[self showUnavailableAlertForServiceName:serviceName];
}

- (void)showUnavailableAlertForServiceName:(NSString *)serviceName {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Account", nil)
														message:[NSString stringWithFormat:NSLocalizedString(@"Need Social Account Message", nil), serviceName]
													   delegate:nil
											  cancelButtonTitle:NSLocalizedString(@"OK", nil)
											  otherButtonTitles:nil];
	[alertView show];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSString *)feedTitle {
	if (self.feed) {
		return [self.feed.title stringByReplacingHTMLEntities];
	}
	
	return nil;
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
	
	NSString *content = [self contentForFeed:feed];
	NSString *source = [(Alternate *)[feed.alternates anyObject] href];
	NSString *dateString = [NSDateFormatter localizedStringFromDate:feed.updatedDate
														  dateStyle:NSDateFormatterLongStyle
														  timeStyle:NSDateFormatterShortStyle];
	NSString *feedTitle = feed.title;
	NSString *subscriptionTitle = feed.subscription.title;
	NSString *author = feed.author;
	
	if (content == nil || [content isEqualToString:@"(null)"]) {
		content = @"";
	}
	
	if (source == nil || [source isEqualToString:@"(null)"]) {
		source = @"";
	}
	
	if (dateString == nil || [dateString isEqualToString:@"(null)"]) {
		dateString = @"";
	}
	
	if (feedTitle == nil || [feedTitle isEqualToString:@"(null)"]) {
		feedTitle = @"";
	}
	
	if (subscriptionTitle == nil || [subscriptionTitle isEqualToString:@"(null)"]) {
		subscriptionTitle = @"";
	}
	
	if (author == nil || [author isEqualToString:@"(null)"]) {
		author = @"";
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	if (self.webView == nil) {
		self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
	}
	
	self.webView.delegate = self;
	self.webView.scrollView.bounces = NO;
	
	[self invalidateSize:self.fullscreen];
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    self.titleLabel.userInteractionEnabled = YES;
		UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLabel:)];
		[self.titleLabel addGestureRecognizer:tapGesture];
	}
	
	UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
	[self.webView addGestureRecognizer:pinchGestureRecognizer];
}

- (void)tapLabel:(UITapGestureRecognizer *)gesture {
	[self.webView.scrollView scrollRectToVisible:self.view.bounds animated:YES];
}

- (void)pinch:(UIPinchGestureRecognizer *)gesture {
	if (gesture.view == self.webView && gesture.state == UIGestureRecognizerStateChanged) {

		if ([_delegate respondsToSelector:@selector(forceFullscreen:)]) {
			[_delegate forceFullscreen:([gesture velocity] > 0)];
		}
	}
}

- (void)invalidateSize:(BOOL)fullscreen {
	CGFloat topBarHeight = self.topBar.frame.size.height;
	
	if (fullscreen) {
		self.topBar.frame = CGRectMake(0.0f, -topBarHeight, self.view.bounds.size.width, topBarHeight);
		self.webView.frame = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, self.view.bounds.size.height);
	} else {
		self.topBar.frame = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, topBarHeight);
		self.webView.frame = CGRectMake(0.0f, topBarHeight, self.view.bounds.size.width, self.view.bounds.size.height - topBarHeight);
	}
}

- (void)showFullScreen:(BOOL)fullscreen {
	[UIView beginAnimations:nil context:NULL];
	
	[self invalidateSize:fullscreen];
	
	[UIView commitAnimations];
	
	self.fullscreen = fullscreen;
}

- (void)viewDidUnload
{
	[self setTopBarImageView:nil];
	
	[self setTitleLabel:nil];
	[self setStarButton:nil];
	[self setWebView:nil];
	[self setTopBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (IBAction)action:(id)sender {
	UIView *senderView = (UIView *)sender;
	[self.actionSheet showFromRect:senderView.bounds inView:senderView animated:YES];
}

- (IBAction)toggleStar:(id)sender {
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if ([self.feed.starred boolValue] == NO) {
		[appDelegate markAsStarred:self.feed];
		
		UIImage *starImage = nil;
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
			starImage = [UIImage imageNamed:@"feedStar~ipad"];
		} else {
			starImage = [UIImage imageNamed:@"feedStar"];
		}
		[self.starButton setImage:starImage forState:UIControlStateNormal];
	}
	else {
		[appDelegate markAsUnstarred:self.feed];
		
		UIImage *starImage = nil;
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
			starImage = [UIImage imageNamed:@"feedUnstar~ipad"];
		} else {
			starImage = [UIImage imageNamed:@"feedUnstar"];
		}
		[self.starButton setImage:starImage forState:UIControlStateNormal];
	}
	
	[appDelegate saveContext];
}

- (void)markAsRead:(BOOL)read {
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if (read) {
		[appDelegate markAsRead:self.feed];
	} else {
		[appDelegate markAsUnread:self.feed];
	}
	
	[appDelegate saveContext];
	
	self.actionSheet = nil;
}

- (void)prepare {
	if (self.feed) {	
		if (self.webView.request == nil || [self.webView.request.URL.absoluteString isEqualToString:@"about:blank"]) {
			[self showFeed:self.feed toView:self.webView];
		}
		
		self.titleLabel.text = [self feedTitle];
		
		if ([self.feed.starred boolValue] == NO) {
			
			UIImage *starImage = nil;
			if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
				starImage = [UIImage imageNamed:@"feedUnstar~ipad"];
			} else {
				starImage = [UIImage imageNamed:@"feedUnstar"];
			}
			[self.starButton setImage:starImage forState:UIControlStateNormal];
		}
		else {
			
			UIImage *starImage = nil;
			if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
				starImage = [UIImage imageNamed:@"feedStar~ipad"];
			} else {
				starImage = [UIImage imageNamed:@"feedStar"];
			}
			[self.starButton setImage:starImage forState:UIControlStateNormal];
		}
	}
}

- (void)unprepare {
	[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
}

- (void)purge {
	[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
}

#pragma mark - UIWebViewDelegate

- (void)openURL:(NSURL *)url {
	UIApplication *app = [UIApplication sharedApplication];
	if ([app canOpenURL:url]) {
		[app openURL:url];
	}
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		NSURL *url = request.URL;
		NSString *scheme = url.scheme;
		NSString *host = url.host;
		
		if ([host isEqualToString:@"itunes.apple.com"]) {
			[self openURL:url];
		}
		else if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]) {
			NewWebViewController *viewController = [[NewWebViewController alloc] init];
			viewController.siteRequest = request;
			viewController.delegate = self;
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
			[self presentViewController:navigationController animated:YES completion:nil];
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

- (void)webViewControllerAttempClose {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)description {
	if (self.feed) {
		return [self contentForFeed:self.feed];
	}
	
	return [super description];
}

@end
