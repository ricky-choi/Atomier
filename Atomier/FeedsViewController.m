//
//  FeedsViewController.m
//  Atomier
//
//  Created by Choi Jaeyoung on 12/19/11.
//  Copyright (c) 2011 Appcid. All rights reserved.
//

#import "FeedsViewController.h"
#import "Category.h"
#import "Subscription.h"
#import "Feed.h"
#import "Content.h"
#import "ContentOrganizer.h"
#import "AppDelegate.h"
#import "FeedsViewCell.h"
#import "WebViewController.h"
#import "NSString+HTML.h"
#import "Element.h"
#import "DocumentRoot.h"
#import "StandViewController.h"

#define SORT_DATE @"sortDateAscending"

@interface FeedsViewController ()

@property (nonatomic, strong) Feed *selectedFeed;

- (void)configureCell:(FeedsViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)refreshTitle;

@end

@implementation FeedsViewController {
	SEL toggleReadSelector;
	SEL toggleStarSelector;
}

@synthesize managedObjectContext = __managedObjectContext;
@synthesize fetchedResultsController = __fetchedResultsController;

- (NSArray *)toolbarItemsPortrait {
	if (_toolbarItemsPortrait == nil) {
		UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		
		UIButton *checkAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
		UIImage *checkAllImage = [UIImage imageNamed:@"checkall_portrait"];
		[checkAllButton setImage:checkAllImage forState:UIControlStateNormal];
		checkAllButton.imageEdgeInsets = UIEdgeInsetsMake(2, 0, -2, 0);
		checkAllButton.showsTouchWhenHighlighted = YES;
		checkAllButton.frame = CGRectMake(0, 0, checkAllImage.size.width, checkAllImage.size.height);
		[checkAllButton addTarget:self action:@selector(markAllAsRead:) forControlEvents:UIControlEventTouchUpInside];
		UIBarButtonItem *checkAllItem = [[UIBarButtonItem alloc] initWithCustomView:checkAllButton];
		
		CGFloat shadowOffset = 1.0f / checkAllImage.scale;
		
		UIButton *sortButton = [UIButton buttonWithType:UIButtonTypeCustom];
		sortButton.frame = CGRectMake(0, 0, 60, 44);
		sortButton.showsTouchWhenHighlighted = YES;
		[sortButton setBackgroundImage:[UIImage imageNamed:@"transparent"] forState:UIControlStateNormal];
		[sortButton setTitle:NSLocalizedString(@"Sort", nil) forState:UIControlStateNormal];
		[sortButton setTitleColor:[UIColor colorWithRed:63.0f/255.0f green:23.0f/255.0f blue:0 alpha:1] forState:UIControlStateNormal];
		[sortButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
		sortButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
		sortButton.titleLabel.shadowOffset = CGSizeMake(0, shadowOffset);
		sortButton.titleEdgeInsets = UIEdgeInsetsMake(7, 0, 0, 0);
		[sortButton addTarget:self action:@selector(sort:) forControlEvents:UIControlEventTouchUpInside];
		UIBarButtonItem *sortItem = [[UIBarButtonItem alloc] initWithCustomView:sortButton];
		
		_toolbarItemsPortrait = [NSArray arrayWithObjects:checkAllItem, flexibleSpace, sortItem, nil];
	}
	
	return _toolbarItemsPortrait;
}

- (NSArray *)toolbarItemsLandscape {
	if (_toolbarItemsLandscape == nil) {
		
	}
	
	return _toolbarItemsLandscape;
}

#pragma mark -

- (void)awakeFromNib {
	self.sortDateAscending = [[NSUserDefaults standardUserDefaults] boolForKey:SORT_DATE];
	toggleReadSelector = @selector(toggleReadStatus:);
	toggleStarSelector = @selector(toggleStarStatus:);
}

- (NSManagedObjectContext *)managedObjectContext {
	if (__managedObjectContext == nil) {
		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		__managedObjectContext = appDelegate.managedObjectContext;
	}
	
	return __managedObjectContext;
}

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

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	
	[self.tableView setEditing:editing animated:animated];
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

- (void)refreshTitle {

	if (self.subscription) {
		self.title = self.subscription.title;
	}
	else if (self.category) {
		self.title = self.category.label;
	}
	else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		NSUInteger count = [[self.fetchedResultsController fetchedObjects] count];
		if (self.currentSegment == 0) {
			self.title = [NSString stringWithFormat:@"%@ (%d)", NSLocalizedString(@"Unread", nil), count];
		}
		else if (self.currentSegment == 1) {
			self.title = [NSString stringWithFormat:@"%@ (%d)", NSLocalizedString(@"Starred", nil), count];
		}
		else if (self.currentSegment == 2) {
			self.title = [NSString stringWithFormat:@"%@ (%d)", NSLocalizedString(@"All Items", nil), count];
		}
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self refreshTitle];
	
	UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
	[backItem setTintColor:[UIColor colorWithRed:63.0f/255.0f green:23.0f/255.0f blue:0 alpha:1]];
	self.navigationItem.backBarButtonItem = backItem;
	
//	if (self.subscription.htmlUrl) {
//		UIBarButtonItem *siteItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Homepage", nil)
//																	 style:UIBarButtonItemStyleBordered
//																	target:self
//																	action:@selector(goSourceOfSubscription)];
//
//		self.navigationItem.rightBarButtonItem = siteItem;
//	}

	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
	    UIBarButtonItem *actionItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(markAllAsRead:)];
		[actionItem setTintColor:[UIColor colorWithRed:63.0f/255.0f green:23.0f/255.0f blue:0 alpha:1]];
		self.navigationItem.rightBarButtonItem = actionItem;
	} else {
		self.toolbarItems = self.toolbarItemsPortrait;
	}
}

- (void)feedViewControllerWillClose:(Feed *)currentFeed {
	[self dismissViewControllerAnimated:YES completion:^{
		NSIndexPath *selectedIndexPath = [self.fetchedResultsController indexPathForObject:currentFeed];
		if (selectedIndexPath) {
			[self.tableView selectRowAtIndexPath:selectedIndexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
			[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(deselectTemp) userInfo:nil repeats:NO];
		}
	}];
}

- (void)deselectTemp {
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)sort:(id)sender {
	if ([self.actionSheet isVisible]) {
		[self.actionSheet dismissWithClickedButtonIndex:self.actionSheet.cancelButtonIndex animated:YES];
	}
	else {
		self.actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Sort", nil)
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
										 destructiveButtonTitle:nil
											  otherButtonTitles:NSLocalizedString(@"Ascending", nil), NSLocalizedString(@"Descending", nil), nil];
		
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
			[self.actionSheet showFromBarButtonItem:sender animated:YES];
		} else {
			[self.actionSheet showFromToolbar:self.navigationController.toolbar];
		}
	}
}

- (void)showOldestFeed {
	NSUInteger sectionCount = [[self.fetchedResultsController sections] count];
	if (sectionCount > 0) {
		id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:sectionCount-1];
		NSUInteger rowCount = [sectionInfo numberOfObjects];
		
		if (rowCount > 0) {
			[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rowCount-1 inSection:sectionCount-1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
		}
	}
}

- (void)goSourceOfSubscription {
	WebViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
	viewController.siteURL = self.subscription.htmlUrl;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	[self presentModalViewController:navigationController animated:YES];
}

- (void)markAllAsRead:(id)sender {
	if ([self.actionSheet isVisible]) {
		[self.actionSheet dismissWithClickedButtonIndex:self.actionSheet.cancelButtonIndex animated:YES];
	}
	else {
		self.actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Mark all items from this list as read?", nil)
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
										 destructiveButtonTitle:NSLocalizedString(@"Mark all as read", nil)
											  otherButtonTitles:nil];
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
			[self.actionSheet showFromBarButtonItem:sender animated:YES];
		} else {
			[self.actionSheet showFromToolbar:self.navigationController.toolbar];
		}
	}
}

- (void)changeSortByDate:(BOOL)ascending {
	self.sortDateAscending = ascending;
	[[NSUserDefaults standardUserDefaults] setBool:ascending forKey:SORT_DATE];
	[[NSUserDefaults standardUserDefaults] synchronize];
	self.fetchedResultsController = nil;
	[self.tableView reloadData];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.cancelButtonIndex) {
		return;
	}
	
	if (buttonIndex == actionSheet.destructiveButtonIndex) {
		// Mark all as read
		NSArray *feeds = [self.fetchedResultsController fetchedObjects];
		
		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		[appDelegate markAsAllRead:feeds];
	}
	else if (buttonIndex == actionSheet.firstOtherButtonIndex) {
		// Sort Ascending
		[self changeSortByDate:YES];
	}
	else if (buttonIndex == actionSheet.firstOtherButtonIndex + 1) {
		// Sort Descending
		[self changeSortByDate:NO];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
	    [self.navigationController setToolbarHidden:YES animated:animated];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma mark - TableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"FeedsCell";
    
    FeedsViewCell *cell = (FeedsViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	[self configureCell:cell atIndexPath:indexPath];
	
	UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showMenuForFeed:)];
	[cell addGestureRecognizer:longPressGesture];
	
    return cell;
}

- (void)showMenuForFeed:(UILongPressGestureRecognizer *)gesture {
	if (gesture.state == UIGestureRecognizerStateBegan) {
		if ([gesture.view isKindOfClass:[FeedsViewCell class]]) {
			FeedsViewCell *cell = (FeedsViewCell *)gesture.view;
			Feed *feed = [self feedForCell:cell];
			if (feed) {
				self.selectedFeed = feed;
				
				UIMenuController * menu = [UIMenuController sharedMenuController];
				UIMenuItem *readMenuItem;
				UIMenuItem *starMenuItem;
				
				if ([feed.unread boolValue]) {
					readMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Mark as read", nil)
															  action:toggleReadSelector];
				} else {
					readMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Mark as unread", nil)
															  action:toggleReadSelector];
				}
				
				if ([feed.starred boolValue]) {
					starMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Unstar", nil)
															  action:toggleStarSelector];
				} else {
					starMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Star", nil)
															  action:toggleStarSelector];
				}
				
				menu.menuItems = @[readMenuItem, starMenuItem];
				[menu setTargetRect:cell.frame inView:self.tableView];
				[menu setMenuVisible: YES animated: YES];
			}
		}
	}
}

- (BOOL)canBecomeFirstResponder {
	return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
	if (action == toggleReadSelector || action == toggleStarSelector) {
		return YES;
	}
	
	return NO;
}

- (Feed *)feedForCell:(FeedsViewCell *)cell {
	NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
	return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (void)toggleReadStatus:(id)sender {
	if (self.selectedFeed) {
		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		if ([self.selectedFeed.unread boolValue]) {
			[appDelegate markAsRead:self.selectedFeed];
		} else {
			[appDelegate markAsUnread:self.selectedFeed];
		}
		
		self.selectedFeed = nil;
	}
}

- (void)toggleStarStatus:(id)sender {
	if (self.selectedFeed) {
		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		if ([self.selectedFeed.starred boolValue]) {
			[appDelegate markAsUnstarred:self.selectedFeed];
		} else {
			[appDelegate markAsStarred:self.selectedFeed];
		}
		
		self.selectedFeed = nil;
	}
}

#define SUMMARY_MAX_LENGTH 350

- (void)configureCell:(FeedsViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
	Feed *feed = [self.fetchedResultsController objectAtIndexPath:indexPath];
	cell.titleLabel.text = [feed.title stringByReplacingHTMLEntities];
	
	cell.descriptionLabel.text = [[ContentOrganizer sharedInstance] summaryForID:[feed.keyId lastPathComponent]];
	cell.subtitleLabel.text = feed.subscription.title;
	
	NSURL *sourceURL = [NSURL URLWithString:feed.subscription.htmlUrl];
	UIImage *icon = [[ContentOrganizer sharedInstance] iconForSubscription:[sourceURL host]];
	if (icon) {
		cell.iconImageView.image = icon;
	} else {
		cell.iconImageView.image = [UIImage imageNamed:@"FeedDefaultIcon"];
	}
	
	if ([feed.unread boolValue]) {
		cell.unreadImageView.image = [UIImage imageNamed:@"unread"];
	} else {
		cell.unreadImageView.image = nil;
	}
	
	if ([feed.starred boolValue]) {
		cell.starredImageView.image = [UIImage imageNamed:@"star"];
	} else {
		cell.starredImageView.image = nil;
	}
	
	cell.dateLabel.text = [NSDateFormatter localizedStringFromDate:feed.updatedDate
														 dateStyle:NSDateFormatterNoStyle
														 timeStyle:NSDateFormatterShortStyle];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [[self.fetchedResultsController sections] count];
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 100.0f;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section { 
#if 0
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
#else
	id <NSFetchedResultsSectionInfo> theSection = [[self.fetchedResultsController sections] objectAtIndex:section];
    
    NSInteger numericSection = [[theSection name] integerValue];
    
	NSInteger year = numericSection / 10000;
	NSInteger month = (numericSection - (year * 10000)) / 100;
	NSInteger day = numericSection - (year * 10000) - (month * 100);
	
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	[comps setYear:year];
	[comps setMonth:month];
	[comps setDay:day];
	NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:comps];
	
	static NSDateFormatter *dateFormatter = nil;
	if (dateFormatter == nil) {
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDoesRelativeDateFormatting:YES];
		[dateFormatter setDateStyle:NSDateFormatterFullStyle];
		[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	}
	
	NSString *titleString = [dateFormatter stringFromDate:date];
	
	return titleString;
#endif
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	
	return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Feed *feed = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		//[self performSegueWithIdentifier:@"ModalForIPad" sender:feed];
		
		UIStoryboard *ipadStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
		
		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		StandViewController *modalParentViewController = [appDelegate standViewController];
		
		NewFeedsViewController *feedsViewController = [ipadStoryboard instantiateViewControllerWithIdentifier:@"NewFeedsViewController"];
		feedsViewController.feeds = [self.fetchedResultsController fetchedObjects];
		feedsViewController.pageIndex = [feedsViewController.feeds indexOfObject:feed];
		//feedsViewController.delegate = self;
		feedsViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		
		[modalParentViewController presentViewController:feedsViewController animated:YES completion:nil];
	} else {
		[self performSegueWithIdentifier:@"NewPushForIPhone" sender:feed];
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	
	if ([segue.identifier isEqualToString:@"ModalForIPad"]) {
		FeedViewController *viewController = nil;
		UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
		viewController = (FeedViewController *)navigationController.topViewController;	
		viewController.delegate = self;
		navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		Feed *feed = (Feed *)sender;
		viewController.feed = feed;
		viewController.feeds = [self.fetchedResultsController fetchedObjects];
	}
	else if ([segue.identifier isEqualToString:@"PushForIPhone"]) {
		FeedViewController *viewController = nil;
		viewController = (FeedViewController *)segue.destinationViewController;
		Feed *feed = (Feed *)sender;
		viewController.feed = feed;
		viewController.feeds = [self.fetchedResultsController fetchedObjects];
	}
	else if ([segue.identifier isEqualToString:@"NewPushForIPhone"]) {
		NewFeedsViewController *feedsViewController = (NewFeedsViewController *)segue.destinationViewController;
		feedsViewController.feeds = [self.fetchedResultsController fetchedObjects];
		
		Feed *feed = (Feed *)sender;
		feedsViewController.pageIndex = [feedsViewController.feeds indexOfObject:feed];
		feedsViewController.delegate = self;
		
//		[self.navigationController setNavigationBarHidden:YES animated:NO];
//		[self.navigationController setToolbarHidden:YES animated:NO];
	}
	
}

- (void)feedsViewControllerWillDismiss:(NewFeedsViewController *)viewController {
//	[self.navigationController setNavigationBarHidden:NO animated:NO];
//	[self.navigationController setToolbarHidden:NO animated:NO];
	
	//[self.navigationController popViewControllerAnimated:YES];
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{	
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    // Set up the fetched results controller.
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Feed" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"updatedDate" ascending:self.sortDateAscending];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
	
	NSPredicate *predicate = nil;

	if (self.subscription) {
		if (self.currentSegment == 0) {
			predicate = [NSPredicate predicateWithFormat:@"(subscription.keyId == %@) AND ((unread = 1) OR (stay = 1))", self.subscription.keyId];
		}
		else if (self.currentSegment == 1) {
			predicate = [NSPredicate predicateWithFormat:@"(subscription.keyId == %@) AND ((starred = 1) OR (stay = 1))", self.subscription.keyId];
		}
		else if (self.currentSegment == 2) {
			predicate = [NSPredicate predicateWithFormat:@"subscription.keyId == %@", self.subscription.keyId];
		}
	}
	else if (self.category) {
		if (self.currentSegment == 0) {
			predicate = [NSPredicate predicateWithFormat:@"(ANY subscription.categories.keyId == %@) AND ((unread = 1) OR (stay = 1))", self.category.keyId];
		}
		else if (self.currentSegment == 1) {
			predicate = [NSPredicate predicateWithFormat:@"(ANY subscription.categories.keyId == %@) AND ((starred = 1) OR (stay = 1))", self.category.keyId];
		}
		else if (self.currentSegment == 2) {
			predicate = [NSPredicate predicateWithFormat:@"ANY subscription.categories.keyId == %@", self.category.keyId];
		}
	}
	else {
		if (self.currentSegment == 0) {
			predicate = [NSPredicate predicateWithFormat:@"(unread = 1) OR (stay = 1)"];
		}
		else if (self.currentSegment == 1) {
			predicate = [NSPredicate predicateWithFormat:@"(starred = 1) OR (stay = 1)"];
		}
		else if (self.currentSegment == 2) {
			
		}
	}
	
	if (predicate) {
		[fetchRequest setPredicate:predicate];
	}	
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"sectionIdentifier" cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	    /*
	     Replace this implementation with code to handle the error appropriately.
		 
	     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	     */
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
	
	if (self.currentSegment == 0 || self.currentSegment == 1) {
		for (Feed *feed in __fetchedResultsController.fetchedObjects) {
			feed.stay = [NSNumber numberWithBool:NO];
		}
	}
	
	[self refreshTitle];
    
    return __fetchedResultsController;
} 

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	// In the simplest, most efficient, case, reload the table view.
	NSLog(@"controllerDidChangeContent: %@", controller);
	[self.tableView reloadData];
	
	if (self.navigationController.visibleViewController == self) {
		NSArray *feeds = [self.fetchedResultsController fetchedObjects];
		if (feeds == nil || [feeds count] == 0) {
			[self.navigationController popViewControllerAnimated:YES];
		}
	}	
	
	[self refreshTitle];
}

- (void)setCurrentSegment:(NSInteger)segment {
	if (_currentSegment != segment) {
		_currentSegment = segment;
		
		self.fetchedResultsController = nil;
		
		if (self.tableView) {
			[self.tableView reloadData];
		}	
	}	
}

- (void)unsubscribe {
	if (self.subscription) {
		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		[appDelegate unsubscribe:self.subscription];
	}
}

@end
