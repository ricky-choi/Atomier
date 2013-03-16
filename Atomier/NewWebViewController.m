//
//  NewWebViewController.m
//  Atomier
//
//  Created by Choi Jaeyoung on 12. 3. 13..
//  Copyright (c) 2012년 Appcid. All rights reserved.
//

#import "NewWebViewController.h"

@interface NewWebViewController ()

@end

@implementation NewWebViewController

@synthesize delegate = _delegate;

@synthesize webView = _webView;

@synthesize backItem = _backItem;
@synthesize forwardItem = _forwardItem;
@synthesize stopItem = _stopItem;
@synthesize reloadItem = _reloadItem;
@synthesize loadingItem = _loadingItem;
@synthesize actionItem = _actionItem;
@synthesize flexibleSpaceItem = _flexibleSpaceItem;

@synthesize spinner = _spinner;

@synthesize toolbarItemsWithStop = _toolbarItemsWithStop;
@synthesize toolbarItemsWithReload = _toolbarItemsWithReload;

@synthesize siteURL = _siteURL;
@synthesize siteRequest = _siteRequest;

@synthesize doneItem = _doneItem;

@synthesize actionSheet = _actionSheet;

- (UIWebView *)webView {
	if (_webView == nil) {
		_webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
		_webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_webView.delegate = self;
		_webView.scalesPageToFit = YES;
	}
	
	return _webView;
}

- (UIBarButtonItem *)backItem {
	if (_backItem == nil) {
		_backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self.webView action:@selector(goBack)];
	}
	
	return _backItem;
}

- (UIBarButtonItem *)forwardItem {
	if (_forwardItem == nil) {
		_forwardItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Forward"] style:UIBarButtonItemStylePlain target:self.webView action:@selector(goForward)];
	}
	
	return _forwardItem;
}

- (UIBarButtonItem *)stopItem {
	if (_stopItem == nil) {
		_stopItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self.webView action:@selector(stopLoading)];
	}
	
	return _stopItem;
}

- (UIBarButtonItem *)reloadItem {
	if (_reloadItem == nil) {
		_reloadItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self.webView action:@selector(reload)];
	}
	
	return _reloadItem;
}

- (UIActivityIndicatorView *)spinner {
	if (_spinner == nil) {
		UIActivityIndicatorViewStyle style;
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
			style = UIActivityIndicatorViewStyleGray;
		} else {
			style = UIActivityIndicatorViewStyleWhite;
		}
		_spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
		_spinner.hidesWhenStopped = YES;
	}
	
	return _spinner;
}

- (UIBarButtonItem *)loadingItem {
	if (_loadingItem == nil) {		
		_loadingItem = [[UIBarButtonItem alloc] initWithCustomView:self.spinner];
	}
	
	return _loadingItem;
}

- (void)startSpin {
	[self.spinner startAnimating];
}

- (void)stopSpin {
	[self.spinner stopAnimating];
}

- (UIBarButtonItem *)actionItem {
	if (_actionItem == nil) {
		_actionItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(moreAction:)];
	}
	
	return _actionItem;
}

- (UIActionSheet *)actionSheet {
	if (_actionSheet == nil) {
		_actionSheet = [[UIActionSheet alloc] initWithTitle:[self.webView.request.mainDocumentURL absoluteString] delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Open in Safari", nil), nil];
	}
	
	return _actionSheet;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.cancelButtonIndex) {
		return;
	}
	
	if (buttonIndex == actionSheet.firstOtherButtonIndex) {
		// Open in safari
		[self openURL:self.webView.request.mainDocumentURL];
	}
}

- (void)moreAction:(id)sender {
	if ([self.actionSheet isVisible]) {
		[self hideActionSheetAnimated:YES];
	}
	else {
		[self.actionSheet showFromBarButtonItem:sender animated:YES];
	}
}

- (void)hideActionSheetAnimated:(BOOL)animated {
	if ([self.actionSheet isVisible]) {
		[self.actionSheet dismissWithClickedButtonIndex:self.actionSheet.cancelButtonIndex animated:animated];
	}
}

- (UIBarButtonItem *)flexibleSpaceItem {
	if (_flexibleSpaceItem == nil) {
		_flexibleSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	}
	
	return _flexibleSpaceItem;
}

- (NSArray *)toolbarItemsWithStop {
	if (_toolbarItemsWithStop == nil) {
		_toolbarItemsWithStop = [[NSArray alloc] initWithObjects:
								 self.backItem,
								 self.flexibleSpaceItem,
								 self.forwardItem,
								 self.flexibleSpaceItem,
								 self.loadingItem,
								 self.flexibleSpaceItem,
								 self.stopItem,
								 self.flexibleSpaceItem,
								 self.actionItem, nil];
	}
	
	return _toolbarItemsWithStop;
}

- (NSArray *)toolbarItemsWithReload {
	if (_toolbarItemsWithReload == nil) {
		_toolbarItemsWithReload = [[NSArray alloc] initWithObjects:
								   self.backItem,
								   self.flexibleSpaceItem,
								   self.forwardItem,
								   self.flexibleSpaceItem,
								   self.loadingItem,
								   self.flexibleSpaceItem,
								   self.reloadItem,
								   self.flexibleSpaceItem,
								   self.actionItem, nil];
	}
	
	return _toolbarItemsWithReload;
}

- (UIBarButtonItem *)doneItem {
	if (_doneItem == nil) {
		_doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
	}
	
	return _doneItem;
}

- (void)done:(id)sender {
	if (_delegate && [_delegate respondsToSelector:@selector(webViewControllerAttempClose)]) {
		[_delegate webViewControllerAttempClose];
	}
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)invalidateControls {
	
	if ([self.webView isLoading]) {
		self.toolbarItems = self.toolbarItemsWithStop;
		[self startSpin];
	} else {
		self.toolbarItems = self.toolbarItemsWithReload;
		[self stopSpin];
	}
	
	self.backItem.enabled = [self.webView canGoBack];
	self.forwardItem.enabled = [self.webView canGoForward];
	
	self.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	// make toolbar
	[self.view addSubview:self.webView];
	
	// load
	if (self.siteRequest) {
		[self.webView loadRequest:self.siteRequest];
		[self invalidateControls];
	}
	else if (self.siteURL) {
		[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.siteURL]]];
		[self invalidateControls];
	}
	
	if (self.navigationController.topViewController == self) {
		self.navigationItem.leftBarButtonItem = self.doneItem;
	}
	
	[self.navigationController.navigationBar setBackgroundImage:nil 
									   forBarMetrics:UIBarMetricsDefault];
	[self.navigationController.toolbar setBackgroundImage:nil
							forToolbarPosition:UIToolbarPositionBottom
									barMetrics:UIBarMetricsDefault];
	[self.navigationController.navigationBar setBackgroundImage:nil 
									   forBarMetrics:UIBarMetricsLandscapePhone];
	[self.navigationController.toolbar setBackgroundImage:nil
							forToolbarPosition:UIToolbarPositionBottom
									barMetrics:UIBarMetricsLandscapePhone];
	
	[self.navigationItem.leftBarButtonItem setTintColor:nil];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (self.navigationController.toolbarHidden == YES) {
		[self.navigationController setToolbarHidden:NO animated:YES];
	}	
}

- (void)viewDidUnload
{
	if (_webView) {
		_webView.delegate = nil;
		_webView = nil;
	}
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma mark - UIWebViewDelegate

- (void)openURL:(NSURL *)url {
	UIApplication *app = [UIApplication sharedApplication];
	if ([app canOpenURL:url]) {
		[app openURL:url];
	}
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSURL *url = request.URL;
	NSString *scheme = url.scheme;
	NSString *host = url.host;
	
	if ([host isEqualToString:@"itunes.apple.com"]) {
		[self openURL:url];
		return NO;
	}
	else if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]) {
		return YES;
	} else {
		[self openURL:url];
		return NO;
	}
	
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
	
	if ([error code] == -1009) { // no internet connection
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
		[alertView show];
	}
}

@end
