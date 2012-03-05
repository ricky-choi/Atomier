//
//  CoverViewController.m
//  Atomier
//
//  Created by Choi Jaeyoung on 12. 3. 1..
//  Copyright (c) 2012년 Appcid. All rights reserved.
//

#import "CoverViewController.h"
#import "NASegmentedControl.h"
#import "TopViewController.h"
#import "AppDelegate.h"
#import "SearchViewController.h"

@interface CoverViewController ()

- (void)showUpdateStatus;

@end

@implementation CoverViewController

@synthesize segmentControlPortrait = _segmentControlPortrait;
@synthesize updateLabel;
@synthesize statusLabel;
@synthesize spinner = _spinner;
	
- (NASegmentedControl *)segmentControlPortrait {
	if (_segmentControlPortrait == nil) {
		UIButton *segButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
		UIImage *segNormalImage1 = [UIImage imageNamed:@"segment_1_normal_portrait"];
		
		CGFloat shadowOffset = 1.0f / segNormalImage1.scale;
		
		UIImage *segSelectedImage1 = [UIImage imageNamed:@"segment_1_selected_portrait"];
		[segButton1 setFrame:CGRectMake(0, 0, segNormalImage1.size.width, segNormalImage1.size.height)];
		[segButton1 setBackgroundImage:segNormalImage1 forState:UIControlStateNormal];
		[segButton1 setBackgroundImage:segSelectedImage1 forState:UIControlStateHighlighted]; 
		[segButton1 setTitle:[TopViewController modeNameForSegment:0] forState:UIControlStateNormal];
		[segButton1 setTitleColor:[UIColor colorWithRed:63.0f/255.0f green:23.0f/255.0f blue:0 alpha:1] forState:UIControlStateNormal];
		[segButton1 setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
		segButton1.titleLabel.font = [UIFont boldSystemFontOfSize:14];
		segButton1.titleLabel.shadowOffset = CGSizeMake(0, shadowOffset);
		segButton1.titleEdgeInsets = UIEdgeInsetsMake(7, 0, 0, 0);
		
		UIButton *segButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
		UIImage *segNormalImage2 = [UIImage imageNamed:@"segment_2_normal_portrait"];
		UIImage *segSelectedImage2 = [UIImage imageNamed:@"segment_2_selected_portrait"];
		[segButton2 setFrame:CGRectMake(0, 0, segNormalImage2.size.width, segNormalImage2.size.height)];
		[segButton2 setBackgroundImage:segNormalImage2 forState:UIControlStateNormal];
		[segButton2 setBackgroundImage:segSelectedImage2 forState:UIControlStateHighlighted];
		[segButton2 setTitle:[TopViewController modeNameForSegment:1] forState:UIControlStateNormal];
		[segButton2 setTitleColor:[UIColor colorWithRed:63.0f/255.0f green:23.0f/255.0f blue:0 alpha:1] forState:UIControlStateNormal];
		[segButton2 setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
		segButton2.titleLabel.font = [UIFont boldSystemFontOfSize:14];
		segButton2.titleLabel.shadowOffset = CGSizeMake(0, shadowOffset);
		segButton2.titleEdgeInsets = UIEdgeInsetsMake(7, 0, 0, 0);
		
		UIButton *segButton3 = [UIButton buttonWithType:UIButtonTypeCustom];
		UIImage *segNormalImage3 = [UIImage imageNamed:@"segment_3_normal_portrait"];
		UIImage *segSelectedImage3 = [UIImage imageNamed:@"segment_3_selected_portrait"];
		[segButton3 setFrame:CGRectMake(0, 0, segNormalImage3.size.width, segNormalImage3.size.height)];
		[segButton3 setBackgroundImage:segNormalImage3 forState:UIControlStateNormal];
		[segButton3 setBackgroundImage:segSelectedImage3 forState:UIControlStateHighlighted];
		[segButton3 setTitle:[TopViewController modeNameForSegment:2] forState:UIControlStateNormal];
		[segButton3 setTitleColor:[UIColor colorWithRed:63.0f/255.0f green:23.0f/255.0f blue:0 alpha:1] forState:UIControlStateNormal];
		[segButton3 setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
		segButton3.titleLabel.font = [UIFont boldSystemFontOfSize:14];
		segButton3.titleLabel.shadowOffset = CGSizeMake(0, shadowOffset);
		segButton3.titleEdgeInsets = UIEdgeInsetsMake(7, 0, 0, 0);
		
		_segmentControlPortrait = [[NASegmentedControl alloc] initWithButtons:
								   [NSArray arrayWithObjects:
									segButton1, segButton2, segButton3, nil]];
		
		[_segmentControlPortrait addTarget:self action:@selector(changeMode:) forControlEvents:UIControlEventValueChanged];
	}
	
	return _segmentControlPortrait;
}

- (void)changeMode:(id)sender {
	
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
	NSInteger segment = [segmentedControl selectedSegmentIndex];
	
	[self performSegueWithIdentifier:@"ShowMainView" sender:[NSNumber numberWithInteger:segment]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	
	UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
	
	if ([segue.identifier isEqualToString:@"ShowMainView"]) {		
		TopViewController *mainViewController = (TopViewController *)navigationController.topViewController;
		mainViewController.currentSegment = [(NSNumber *)sender integerValue];
	}	
	else if ([segue.identifier isEqualToString:@"ShowSearch"]) {
		SearchViewController *searchController = (SearchViewController *)navigationController.topViewController;
		searchController.mode = SearchViewControllerModeSearch;
	}
	else if ([segue.identifier isEqualToString:@"ShowSubscription"]) {
		SearchViewController *searchController = (SearchViewController *)navigationController.topViewController;
		searchController.mode = SearchViewControllerModeSubscription;
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

/*
- (void)loadView
{
    // If you create your views manually, you MUST override this method and use it to create your views.
    // If you use Interface Builder to create your views, then you must NOT override this method.
}
*/

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	self.segmentControlPortrait.center = CGPointMake(160, 458);
	
	[self.view addSubview:self.segmentControlPortrait];
	
	[self showUpdateStatus];
	[self refreshUnreadCount];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	self.segmentControlPortrait.selectedSegmentIndex = -1;
	[self refreshUnreadCount];
}

- (void)viewDidUnload
{
	[self setUpdateLabel:nil];
	[self setStatusLabel:nil];
    [self setSpinner:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -

- (IBAction)next:(id)sender {
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	NSUInteger count = [appDelegate unreadCount];
	
	if (count == 0) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"You have no unread items.", nil)
															message:nil 
														   delegate:self 
												  cancelButtonTitle:NSLocalizedString(@"OK", nil)
												  otherButtonTitles:NSLocalizedString(@"Refresh All", nil), nil];
		[alertView show];
	}
	else {
		[self performSegueWithIdentifier:@"ShowFeeds" sender:sender];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == alertView.firstOtherButtonIndex) {
		[self refresh:nil];
	}
}

- (IBAction)refresh:(id)sender {
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate refresh];
}

- (void)notifyUpdating {
	self.updateLabel.text = NSLocalizedString(@"Updating...", nil);
	[self.spinner startAnimating];
}

- (void)notifyUpdateDone {
	[self showUpdateStatus];
	[self refreshUnreadCount];
	[self.spinner stopAnimating];
}

- (void)refreshUnreadCount {
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	NSUInteger count = [appDelegate unreadCount];
	
	if (count == 0) {
		self.statusLabel.text = NSLocalizedString(@"You have no unread items.", nil);
	}
	else if (count == 1) {
		self.statusLabel.text = NSLocalizedString(@"1 new item", nil);
	} 
	else {
		self.statusLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d new items", nil), count];
	}
}

- (void)showUpdateStatus {
	NSDate *lastUpdateDate = [[NSUserDefaults standardUserDefaults] objectForKey:DEFAULT_KEY_LAST_UPDATE];
	if (lastUpdateDate) {
		static NSDateFormatter *dateFormatter = nil;
		if (dateFormatter == nil) {
			dateFormatter = [[NSDateFormatter alloc] init];
			[dateFormatter setDoesRelativeDateFormatting:YES];
			[dateFormatter setDateStyle:NSDateFormatterShortStyle];
			[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		}
		
		self.updateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Update: %@", nil), [dateFormatter stringFromDate:lastUpdateDate]];
	} else {
		self.updateLabel.text = @"";
	}
}

@end
