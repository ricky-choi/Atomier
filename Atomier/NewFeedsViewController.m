//
//  NewFeedsViewController.m
//  Atomier
//
//  Created by Choi Jaeyoung on 12. 3. 13..
//  Copyright (c) 2012년 Appcid. All rights reserved.
//

#import "NewFeedsViewController.h"

@interface NewFeedsViewController ()

// View Layout
- (void)layout;
- (void)preparePages;

- (void)loadScrollViewWithPage:(int)page;
- (void)unloadScrollViewWithPage:(int)page;

- (void)markRead:(int)page;

- (BOOL)isNSNull:(id)object;

@end

@implementation NewFeedsViewController {
	
    NSInteger pageCount;
    BOOL pendingOrientationChange;
	
	BOOL fullscreen;
	
	CGFloat bottomPaddingPortrait;
	CGFloat bottomPaddingLandscape;
	CGFloat bottomPaddingPortraitMin;
	CGFloat bottomPaddingLandscapeMin;
}

@synthesize feeds = _feeds;
@synthesize pages = _pages;
@synthesize pageIndex;

@synthesize delegate = _delegate;
@synthesize scrollView = _scrollView;
@synthesize nextButton;
@synthesize previousButton;
@synthesize topImageView = _topImageView;
@synthesize bottomImageView = _bottomImageView;
@synthesize bottomView = _bottomView;
@synthesize pageLabel = _pageLabel;

- (void)layoutForOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
	    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
			self.topImageView.image = [UIImage imageNamed:@"feedsTop-Portrait~ipad"];
			self.bottomImageView.image = [UIImage imageNamed:@"feedsBottom-Portrait~ipad"];
		}
		else {
			self.topImageView.image = [UIImage imageNamed:@"feedsTop-Landscape~ipad"];
			self.bottomImageView.image = [UIImage imageNamed:@"feedsBottom-Landscape~ipad"];
		}
	}
	else {
		CGRect viewRect = self.view.bounds;
		CGFloat padding;
		CGFloat bottomViewHeight;
		if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
			padding = fullscreen ? bottomPaddingPortraitMin : bottomPaddingPortrait;
			bottomViewHeight = bottomPaddingPortrait;
			if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
				viewRect = CGRectMake(0, 0, viewRect.size.height, viewRect.size.width);
			}
			
			self.topImageView.image = [UIImage imageNamed:@"feedsTop_portrait"];
			self.bottomImageView.image = [UIImage imageNamed:@"syndi_toolbar_portrait"];
		}
		else {
			padding = fullscreen ? bottomPaddingLandscapeMin : bottomPaddingLandscape;
			bottomViewHeight = bottomPaddingLandscape;
			if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
				viewRect = CGRectMake(0, 0, viewRect.size.height, viewRect.size.width);
			}
			
			self.topImageView.image = [UIImage imageNamed:@"feedsTop_landscape"];
			self.bottomImageView.image = [UIImage imageNamed:@"syndi_toolbar_landscape"];
		}
		
		self.scrollView.frame = CGRectMake(0, 0, viewRect.size.width, viewRect.size.height - padding);
		self.bottomView.frame = CGRectMake(0, self.scrollView.frame.size.height, self.scrollView.frame.size.width, bottomViewHeight);
	}
}

- (IBAction)toggleFullScreen:(id)sender {
	
	CGFloat padding;
	CGFloat paddingMin;
	
	if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
		padding = bottomPaddingPortrait;
		paddingMin = bottomPaddingPortraitMin;
	}
	else {
		padding = bottomPaddingLandscape;
		paddingMin = bottomPaddingLandscapeMin;
	}
	
	[UIView beginAnimations:nil context:NULL];
	
	if (fullscreen) {
		// 원래 크기로
		self.scrollView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - padding);
	} else {
		// 풀스크린으로 변경
		self.scrollView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - paddingMin);
	}
	
	CGRect bottomBarRect = self.bottomView.frame;
	bottomBarRect.origin.y = self.scrollView.frame.size.height;
	self.bottomView.frame = bottomBarRect;
	
	[UIView commitAnimations];
	
	fullscreen = !fullscreen;
}

- (IBAction)fullscreenOn:(id)sender {
	if (fullscreen == NO) {
		[self toggleFullScreen:sender];
	}
}

- (IBAction)fullscreenOff:(id)sender {
	if (fullscreen == YES) {
		[self toggleFullScreen:sender];
	}
}

- (void)setup {
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		bottomPaddingLandscape = 70.0f;
		bottomPaddingLandscapeMin = 8.0f;
		bottomPaddingPortrait = bottomPaddingLandscape;
		bottomPaddingPortraitMin = bottomPaddingLandscapeMin;
	} else {
		bottomPaddingLandscape = 32.0f;
		bottomPaddingLandscapeMin = 4.0f;
		bottomPaddingPortrait = 44.0f;
		bottomPaddingPortraitMin = bottomPaddingLandscapeMin;
	}
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self setup];
	}
	
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
	for (int i = 0; i < [self.pages count]; i++) {
		if (i != pageIndex) {
			NewFeedViewController *page = [self.pages objectAtIndex:i];
			if (![self isNSNull:page]) {
				[page purge];
			}
		}
	}
}

- (void)markRead:(int)page {
	NewFeedViewController *viewController = [self.pages objectAtIndex:page];
	if (![self isNSNull:viewController]) {
		[viewController markAsRead:YES];
	}
}

- (BOOL)isNSNull:(id)object {
	if ((NSNull *)object == [NSNull null]) {
		return YES;
	}
	
	return NO;
}

- (void)loadScrollViewWithPage:(int)i {
	if (i < 0) return;
    if (i >= pageCount) return;
	
	NewFeedViewController *page = [self.pages objectAtIndex:i];
	if ([self isNSNull:page]) {
		page = [self.storyboard instantiateViewControllerWithIdentifier:@"NewFeedViewController"];
		page.delegate = self;
		page.feed = [self.feeds objectAtIndex:i];
		[self.pages replaceObjectAtIndex:i withObject:page];
		[self addChildViewController:page];
		
		CGRect frame = self.scrollView.frame;
        frame.origin.x = frame.size.width * i;
        frame.origin.y = 0;
        page.view.frame = frame;
		page.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.scrollView addSubview:page.view];
	}
	
	[page prepare];
}

- (void)unloadScrollViewWithPage:(int)i {
	if (i < 0) return;
    if (i >= pageCount) return;
	
	NewFeedViewController *page = [self.pages objectAtIndex:i];
	if (![self isNSNull:page]) {
		[page unprepare];
		[page.view removeFromSuperview];
		[page removeFromParentViewController];
		[self.pages replaceObjectAtIndex:i withObject:[NSNull null]];
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	self.scrollView.delegate = self;
	
	if ([self.feeds count] > 0) {
		self.pages = [NSMutableArray arrayWithCapacity:[self.feeds count]];
		for (unsigned i = 0; i < [self.feeds count]; i++) {
			[self.pages addObject:[NSNull null]];
		}
		
		//pageIndex = 0;
		pageCount = [self.pages count];
	}
	
	[self preparePages];
	[self layout];
    [self refreshPageLabel];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self layout];
	[self layoutForOrientation:self.interfaceOrientation];
	[self refreshPageLabel];
}

- (void)viewDidUnload
{
	[self setScrollView:nil];
	[self setNextButton:nil];
	[self setTopImageView:nil];
	[self setBottomImageView:nil];
	
	for (NewFeedViewController *page in self.pages) {
		if (![self isNSNull:page]) {
			[page unprepare];
		}        
    }
	
    [self setPageLabel:nil];
	
	[self setBottomView:nil];
	
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)dealloc
{
	self.scrollView.delegate = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	} else {
	    return YES;
	}
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	pendingOrientationChange = YES;
	
    [UIView animateWithDuration:duration animations:^{            
        [self layoutForOrientation:toInterfaceOrientation];
    }];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self layout];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    pendingOrientationChange = NO;
}

- (void)refreshPageLabel {
	self.pageLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d of %d", nil), pageIndex+1, pageCount];
}

#pragma mark - IBAction

- (IBAction)goHome:(id)sender {
	if (_delegate && [_delegate respondsToSelector:@selector(feedsViewControllerWillDismiss:)]) {
		[_delegate feedsViewControllerWillDismiss:self];
	}
	else {
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

- (void)showNoMore {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No More Feeds", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
	[alertView show];
}

- (IBAction)goNext:(id)sender {
	if (pageIndex == pageCount - 1) {
		[self showNoMore];
		return;
	}
	
	if (pageIndex < pageCount - 1) {
        ++pageIndex;
    }
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.bounds.size.width * pageIndex, 0.0) animated:YES];
    [self preparePages];
	[self refreshPageLabel];
}

- (IBAction)goPrevious:(id)sender {
	if (pageIndex > 0) {
        --pageIndex;
    }
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.bounds.size.width * pageIndex, 0.0) animated:YES];
    [self preparePages];
	[self refreshPageLabel];
}

#pragma mark -
#pragma mark Scrolling Support

- (void)scrollViewDidScroll:(UIScrollView *)sv
{
    // Because the orientation change may shrink the scroll view, which may send this message.
    // Basically ignore the message until the orientation change completes, and trust -layout
    // to place us correctly.
    if (pendingOrientationChange) {
        return;
    }
    
    // Infer the desired page from the new contentOffset.
    CGFloat offsetX = self.scrollView.contentOffset.x;
    CGFloat width = self.scrollView.bounds.size.width;
    NSInteger tmpIndex = floor((offsetX - width / 2) / width) + 1;// trunc(offsetX / width);
    if (tmpIndex != pageIndex) {
        pageIndex = tmpIndex;
        //[self preparePages];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[self preparePages];
	[self refreshPageLabel];
}

- (void)layout {
	CGRect placementRect = self.scrollView.bounds;
    self.scrollView.contentSize = CGSizeMake(placementRect.size.width * pageCount, placementRect.size.height);
    self.scrollView.contentOffset = CGPointMake(placementRect.size.width * pageIndex, 0.0);
    for (NSInteger i = 0; i < pageCount; ++i) {
        NewFeedViewController *page = [self.pages objectAtIndex:i];
		if (![self isNSNull:page]) {
			UIView *pageView = page.view;
			placementRect.origin.x = placementRect.size.width * i;
			pageView.frame = placementRect;
		}
    }
}

- (void)preparePages {
	NSInteger i = 0;
	
    for (; i < pageIndex - 1; ++i) {
		[self unloadScrollViewWithPage:i];		
    }
    for (; (i <= pageIndex + 1) && (i < pageCount); ++i) {
		[self loadScrollViewWithPage:i];		
    }
    for (; i < pageCount; ++i) {
		[self unloadScrollViewWithPage:i];		
    }
	
	[self markRead:pageIndex];
}

#pragma mark - NewFeedViewControllerDelegate

- (void)touchedEmptyContent {
	[self toggleFullScreen:nil];
}

- (void)forceFullscreen:(BOOL)on {
	if (on) {
		[self fullscreenOn:nil];
	} else {
		[self fullscreenOff:nil];
	}
}

@end
