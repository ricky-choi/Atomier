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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	if (self.siteURL) {
		[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.siteURL]]];
	}
	
	[self invalidateControls];
}


- (void)viewDidUnload
{
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

@end
