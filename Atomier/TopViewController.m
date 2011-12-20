//
//  TopViewController.m
//  Atomier
//
//  Created by Choi Jaeyoung on 12/16/11.
//  Copyright (c) 2011 Appcid. All rights reserved.
//

#import "TopViewController.h"
#import "AppDelegate.h"
#import "TopViewCell.h"
#import "Category.h"
#import "Subscription.h"
#import "Feed.h"
#import "ContentOrganizer.h"

@interface TopViewController ()

@property (nonatomic, retain) UIView *sectionView;

- (void)configureCell:(TopViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)addPreviewFeed:(PreviewFeed *)previewFeed;
- (BOOL)loadPreviewFeed:(NSFetchedResultsController *)controller;

@end

@implementation TopViewController

@synthesize tableView = _tableView;
@synthesize sectionView = _sectionView;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize fetchedResultsControllerForCategory = __fetchedResultsControllerForCategory;
@synthesize fetchedResultsControllerForSubscription = __fetchedResultsControllerForSubscription;
@synthesize currentSegment = _currentSegment;
@synthesize currentCacheNameForCategory = _currentCacheNameForCategory;
@synthesize currentCacheNameForSubscription = _currentCacheNameForSubscription;
@synthesize previewFeed = _previewFeed;
@synthesize tempPreviewFeed = _tempPreviewFeed;
@synthesize category = _category;

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

- (void)awakeFromNib {
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	self.managedObjectContext = appDelegate.managedObjectContext;
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

- (BOOL)loadPreviewFeed:(NSFetchedResultsController *)controller {
	if (self.previewFeed == nil || self.previewFeed.needRefresh == YES) {
		id <NSFetchedResultsSectionInfo> subscriptionSectionInfo = [[controller sections] objectAtIndex:0];
		NSUInteger subscriptionCount = [subscriptionSectionInfo numberOfObjects];
		if (subscriptionCount > 0) {
			id folder = [controller objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
			Feed *latestFeed;
			if (self.currentSegment == 0) {
				latestFeed = [folder unreadLatestFeed];
			}
			else if (self.currentSegment == 1) {
				latestFeed = [folder starredLatestFeed];
			}
			else {
				latestFeed = [folder latestFeed];
			}
			if (latestFeed) {
				self.tempPreviewFeed = [[PreviewFeed alloc] init];
				self.tempPreviewFeed.feed = latestFeed;
#if 0
				[self addPreviewFeed:self.tempPreviewFeed];
#else
				if ([self.tempPreviewFeed allDataExist]) {
					NSLog(@"add preview now");
					[self addPreviewFeed:self.tempPreviewFeed];
				}
				else {
					NSLog(@"add preview request (%@)", [latestFeed.keyId lastPathComponent]);
					self.tempPreviewFeed.delegate = self;
					[[ContentOrganizer sharedInstance] makeSummaryAndFirstImageForID:[latestFeed.keyId lastPathComponent]];
				}
#endif
			}
			
			return YES;
		}
	}
	
	return NO;
}

- (void)invalidateEditButton {
	[self.navigationItem.rightBarButtonItem setEnabled:([self.fetchedResultsControllerForSubscription.fetchedObjects count] > 0)];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	[self invalidateEditButton];
	
	if (self.category == nil) {
		UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
		self.navigationItem.leftBarButtonItem = refreshItem;
	}
	
	UISegmentedControl *segmentControl = [[UISegmentedControl alloc] initWithItems:
										  [NSArray arrayWithObjects:
										   NSLocalizedString(@"Unread", nil),
										   NSLocalizedString(@"Starred", nil),
										   NSLocalizedString(@"All Items", nil), nil]];
	segmentControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentControl.selectedSegmentIndex = _currentSegment;
	[segmentControl addTarget:self action:@selector(changeMode:) forControlEvents:UIControlEventValueChanged];
	
	UIBarButtonItem *segmentItem = [[UIBarButtonItem alloc] initWithCustomView:segmentControl];
	UIBarButtonItem *flexibleSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
	self.toolbarItems = [NSArray arrayWithObjects:flexibleSpaceItem, segmentItem, flexibleSpaceItem, nil];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	
	[self.tableView setEditing:editing animated:animated];
}

- (void)loadAnyPreview {
	BOOL load = [self loadPreviewFeed:self.fetchedResultsControllerForSubscription];
	if (load == NO) {
		[self loadPreviewFeed:self.fetchedResultsControllerForCategory];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewDidUnload
{
	[self setTableView:nil];
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

#pragma mark - UITableView Datasource and Delegate

- (NSUInteger)countForMode:(NSInteger)segment {
	if (self.category == nil) {
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Feed" inManagedObjectContext:self.managedObjectContext];
		[fetchRequest setEntity:entity];
		
		NSPredicate *predicate = nil;
		if (segment == 0) {
			predicate = [NSPredicate predicateWithFormat:@"unread = 1"];		
		}
		else if (segment == 1) {
			predicate = [NSPredicate predicateWithFormat:@"starred = 1"];		
		}
		
		if (predicate) {
			[fetchRequest setPredicate:predicate];
		}
		
		return [self.managedObjectContext countForFetchRequest:fetchRequest error:nil];
	}
	
	if (segment == 0) {
		return [[self.category unreadCount] unsignedIntegerValue];
	}
	else if (segment == 1) {
		return [[self.category starredCount] unsignedIntegerValue];
	}
	else if (segment == 2) {
		return [self.category allCount];
	}
	
	return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		static NSString *AllCellIdentifier = @"AllCell";
		
		UITableViewCell *allCell = [tableView dequeueReusableCellWithIdentifier:AllCellIdentifier];
		if (self.currentSegment == 0) {
			allCell.textLabel.text = NSLocalizedString(@"Unread", nil);
			allCell.imageView.image = [UIImage imageNamed:@"UnreadItem"];
		}
		else if (self.currentSegment == 1) {
			allCell.textLabel.text = NSLocalizedString(@"Starred", nil);
			allCell.imageView.image = [UIImage imageNamed:@"StarredItem"];
		}
		else if (self.currentSegment == 2) {
			allCell.textLabel.text = NSLocalizedString(@"All Items", nil);
			allCell.imageView.image = [UIImage imageNamed:@"FilterNoneBlack"];
		}
		
		NSUInteger count = [self countForMode:self.currentSegment];
		if (count > 0) {
			allCell.detailTextLabel.text = [NSString stringWithFormat:@"%d", count];
		} else {
			allCell.detailTextLabel.text = @"";
		}
		
		allCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		return allCell;
	}
	
	static NSString *CellIdentifier = @"FolderCell";
    
    TopViewCell *cell = (TopViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	[self configureCell:cell atIndexPath:indexPath];
	
    return cell;
}

- (void)configureCell:(TopViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
	id <NSFetchedResultsSectionInfo> subscriptionSectionInfo = [[self.fetchedResultsControllerForSubscription sections] objectAtIndex:0];
	NSUInteger subscriptionCount = [subscriptionSectionInfo numberOfObjects];
	if (indexPath.row < subscriptionCount) {
		// Subscriptions
		// title
		NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
		Subscription *subscription = [self.fetchedResultsControllerForSubscription objectAtIndexPath:newIndexPath];
		cell.titleLabel.text = subscription.title;
		
		// inner feed
		Feed *latestFeed = nil;
		NSUInteger feedCount = 0;
		if (self.currentSegment == 0) {
			latestFeed = [subscription unreadLatestFeed];
			feedCount = [subscription.unreadCount unsignedIntegerValue];
		}
		else if (self.currentSegment == 1) {
			latestFeed = [subscription starredLatestFeed];
			feedCount = [subscription.starredCount unsignedIntegerValue];
		}
		else {
			latestFeed = [subscription latestFeed];
			feedCount = [subscription allCount];
		}
		if (latestFeed) {
			cell.descriptionLabel.text = latestFeed.title;
		} else {
			cell.descriptionLabel.text = @"";
		}
		
		// count
		if (feedCount > 0) {
			cell.countLabel.text = [NSString stringWithFormat:@"%d", feedCount];
		} else {
			cell.countLabel.text = @"";
		}
		
		// icon image
		NSURL *sourceURL = [NSURL URLWithString:subscription.htmlUrl];
		UIImage *icon = [[ContentOrganizer sharedInstance] iconForSubscription:[sourceURL host]];
		if (icon) {
			cell.iconImageView.image = icon;
		} else {
			cell.iconImageView.image = [UIImage imageNamed:@"FeedDefaultIcon"];
		}	
		
		// accessory
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else {
		// Folders (Categories)
		// title
		NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row - subscriptionCount inSection:0];
		Category *category = [self.fetchedResultsControllerForCategory objectAtIndexPath:newIndexPath];
		cell.titleLabel.text = category.label;
		
		// inner feed
		Feed *latestFeed = nil;
		NSUInteger feedCount = 0;
		if (self.currentSegment == 0) {
			latestFeed = [category unreadLatestFeed];
			feedCount = [category.unreadCount unsignedIntegerValue];
		}
		else if (self.currentSegment == 1) {
			latestFeed = [category starredLatestFeed];
			feedCount = [category.starredCount unsignedIntegerValue];
		}
		else {
			latestFeed = [category latestFeed];
			feedCount = [category allCount];
		}
		if (latestFeed) {
			cell.descriptionLabel.text = latestFeed.title;
		} else {
			cell.descriptionLabel.text = @"";
		}
		
		// count
		if (feedCount > 0) {
			cell.countLabel.text = [NSString stringWithFormat:@"%d", feedCount];
		} else {
			cell.countLabel.text = @"";
		}
		
		// icon image
		cell.iconImageView.image = [UIImage imageNamed:@"Folder"];
		
		// accessory
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		return 44.0f;
	}
	
	return 66.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if (section == 0) {
		return 1;
	}
	
	id <NSFetchedResultsSectionInfo> subscriptionSectionInfo = [[self.fetchedResultsControllerForSubscription sections] objectAtIndex:0];
	id <NSFetchedResultsSectionInfo> categorySectionInfo = [[self.fetchedResultsControllerForCategory sections] objectAtIndex:0];
	
	return [subscriptionSectionInfo numberOfObjects] + [categorySectionInfo numberOfObjects];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.section == 0) {
		return NO;
	}
	
	id <NSFetchedResultsSectionInfo> subscriptionSectionInfo = [[self.fetchedResultsControllerForSubscription sections] objectAtIndex:0];
	if (indexPath.row < [subscriptionSectionInfo numberOfObjects]) {
		return YES;
	}
	
	return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {	
	return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
	return NSLocalizedString(@"Unsubscribe", nil);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
		Subscription *subscription = [self.fetchedResultsControllerForSubscription objectAtIndexPath:newIndexPath];
		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		[appDelegate unsubscribe:subscription];
	}
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	id <NSFetchedResultsSectionInfo> subscriptionSectionInfo = [[self.fetchedResultsControllerForSubscription sections] objectAtIndex:0];
	NSUInteger subscriptionCount = [subscriptionSectionInfo numberOfObjects];
	
	NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row - subscriptionCount inSection:0];
	Category *category = [self.fetchedResultsControllerForCategory objectAtIndexPath:newIndexPath];
	
	TopViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TopViewController"];
	newTopViewController.category = category;
	newTopViewController.title = category.label;
	newTopViewController.currentSegment = self.currentSegment;
	
	[self.navigationController pushViewController:newTopViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section == 1) {
		return 10.0f;
	}
	
	return 0;
}

#if 0

#define SECTION_HEIGHT 30.0f

- (UIView *)sectionView {
	if (_sectionView == nil) {
		_sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, SECTION_HEIGHT)];
		_sectionView.backgroundColor = [UIColor blueColor];
		
		UISegmentedControl *segmentControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Unread", @"Starred", @"All Items", nil]];
		segmentControl.segmentedControlStyle = UISegmentedControlStyleBar;
		segmentControl.frame = _sectionView.bounds;
		segmentControl.center = _sectionView.center;
		segmentControl.selectedSegmentIndex = 0;
		_currentSegment = segmentControl.selectedSegmentIndex;
		[segmentControl addTarget:self action:@selector(changeMode:) forControlEvents:UIControlEventValueChanged];
		
		[_sectionView addSubview:segmentControl];
	}
	
	return _sectionView;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return self.sectionView;
	}
	
	return nil;
}

#endif

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsControllerForCategory
{
	if (self.category) {
		return nil;
	}
	
    if (__fetchedResultsControllerForCategory != nil) {
        return __fetchedResultsControllerForCategory;
    }
    
    // Set up the fetched results controller.
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"label" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
	
	NSString *cacheName = nil;
	NSPredicate *existUnreadPredicate = nil;
	if (self.currentSegment == 0) {
		//cacheName = @"CategoryUnread";
		existUnreadPredicate = [NSPredicate predicateWithFormat:@"unreadCount > 0"];
	}
	else if (self.currentSegment == 1) {
		//cacheName = @"CategoryStarred";
		existUnreadPredicate = [NSPredicate predicateWithFormat:@"starredCount > 0"];
	}
	else if (self.currentSegment == 2) {
		//cacheName = @"CategoryAll";
	}
	
	self.currentCacheNameForCategory = cacheName;
	
	if (existUnreadPredicate) {
		[fetchRequest setPredicate:existUnreadPredicate];
	}	
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:cacheName];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsControllerForCategory = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsControllerForCategory performFetch:&error]) {
	    /*
	     Replace this implementation with code to handle the error appropriately.
		 
	     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	     */
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return __fetchedResultsControllerForCategory;
}    

- (NSFetchedResultsController *)fetchedResultsControllerForSubscription
{
    if (__fetchedResultsControllerForSubscription != nil) {
        return __fetchedResultsControllerForSubscription;
    }
    
    // Set up the fetched results controller.
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Subscription" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
	
	NSString *cacheName = nil;
	NSPredicate *noCategoryPredicate = nil;
	if (self.currentSegment == 0) {
		//cacheName = @"SubscriptionUnread";
		if (self.category) {
			noCategoryPredicate = [NSPredicate predicateWithFormat:@"(ANY categories.keyId == %@) AND (unreadCount > 0)", self.category.keyId];
		} else {
			noCategoryPredicate = [NSPredicate predicateWithFormat:@"categories.@count == 0 AND unreadCount > 0"];
		}
		
	}
	else if (self.currentSegment == 1) {
		//cacheName = @"SubscriptionStarred";
		if (self.category) {
			noCategoryPredicate = [NSPredicate predicateWithFormat:@"(ANY categories.keyId == %@) AND (starredCount > 0)", self.category.keyId];
		} else {
			noCategoryPredicate = [NSPredicate predicateWithFormat:@"categories.@count == 0 AND starredCount > 0"];
		}
		
	}
	else if (self.currentSegment == 2) {
		//cacheName = @"SubscriptionAll";
		if (self.category) {
			noCategoryPredicate = [NSPredicate predicateWithFormat:@"ANY categories.keyId == %@", self.category.keyId];
		} else {
			noCategoryPredicate = [NSPredicate predicateWithFormat:@"categories.@count == 0"];
		}
		
	}
	
	self.currentCacheNameForSubscription = cacheName;

	if (noCategoryPredicate) {
		[fetchRequest setPredicate:noCategoryPredicate];
	}
	    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:cacheName];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsControllerForSubscription = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsControllerForSubscription performFetch:&error]) {
	    /*
	     Replace this implementation with code to handle the error appropriately.
		 
	     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	     */
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return __fetchedResultsControllerForSubscription;
}



- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	// In the simplest, most efficient, case, reload the table view.
	NSLog(@"controllerDidChangeContent: %@", controller);
	[self.tableView reloadData];
	
	[self invalidateEditButton];
}

- (void)previewFeedImageDownloadCompleted:(PreviewFeed *)sender {
	[self addPreviewFeed:sender];
}

- (void)addPreviewFeed:(PreviewFeed *)previewFeed {
	self.previewFeed = previewFeed;
	self.previewFeed.needRefresh = NO;
	
	UIView *tableHeaderView = [self.tableView tableHeaderView];
	if (tableHeaderView == nil) {
		// add
		[self.tableView setTableHeaderView:previewFeed.headerView];
	} else {
		// modify
		[self.tableView setTableHeaderView:previewFeed.headerView];
	}
}

#pragma mark - IBAction

- (IBAction)refresh:(id)sender {
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate refresh];
}

- (IBAction)changeMode:(id)sender {
	self.editing = NO;
	
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
	NSInteger segment = [segmentedControl selectedSegmentIndex];
	_currentSegment = segment;
	
	[NSFetchedResultsController deleteCacheWithName:self.currentCacheNameForCategory];
	[NSFetchedResultsController deleteCacheWithName:self.currentCacheNameForSubscription];
	
	self.fetchedResultsControllerForCategory = nil;
	self.fetchedResultsControllerForSubscription = nil;
	
#if 0
	[self.tableView reloadData];
#else
	[self.tableView beginUpdates];
	
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
	[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
	[self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
	
	[self.tableView endUpdates];
#endif
	
	[self invalidateEditButton];
}

@end
