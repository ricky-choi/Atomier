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

@interface TopViewController ()

@property (nonatomic, retain) UIView *sectionView;

- (void)configureCell:(TopViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

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

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

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

#define SECTION_HEIGHT 30.0f

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"FolderCell";
    
    TopViewCell *cell = (TopViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	[self configureCell:cell atIndexPath:indexPath];
	
    return cell;
}

- (void)configureCell:(TopViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
	id <NSFetchedResultsSectionInfo> subscriptionSectionInfo = [[self.fetchedResultsControllerForSubscription sections] objectAtIndex:indexPath.section];
	NSUInteger subscriptionCount = [subscriptionSectionInfo numberOfObjects];
	if (indexPath.row < subscriptionCount) {
		// Subscriptions
		Subscription *subscription = [self.fetchedResultsControllerForSubscription objectAtIndexPath:indexPath];
		cell.titleLabel.text = subscription.title;
		Feed *latestFeed = [subscription unreadLatestFeed];
		if (latestFeed) {
			cell.descriptionLabel.text = latestFeed.title;
		} else {
			cell.descriptionLabel.text = @"";
		}
		
		NSUInteger unreadCount = [subscription.unreadCount unsignedIntegerValue];
		if (unreadCount > 0) {
			cell.countLabel.text = [subscription.unreadCount stringValue];
		} else {
			cell.countLabel.text = @"";
		}
		cell.iconImageView.image = [UIImage imageNamed:@"FeedDefaultIcon"];
	} else {
		// Folders (Categories)
		NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row - subscriptionCount inSection:indexPath.section];
		Category *category = [self.fetchedResultsControllerForCategory objectAtIndexPath:newIndexPath];
		cell.titleLabel.text = category.label;
		Feed *latestFeed = [category latestFeed];
		if (latestFeed) {
			cell.descriptionLabel.text = latestFeed.title;
		} else {
			cell.descriptionLabel.text = @"";
		}
		NSUInteger unreadCount = [category.unreadCount unsignedIntegerValue];
		if (unreadCount > 0) {
			cell.countLabel.text = [category.unreadCount stringValue];
		} else {
			cell.countLabel.text = @"";
		}
		cell.iconImageView.image = [UIImage imageNamed:@"Folder"];
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	id <NSFetchedResultsSectionInfo> subscriptionSectionInfo = [[self.fetchedResultsControllerForSubscription sections] objectAtIndex:section];
	id <NSFetchedResultsSectionInfo> categorySectionInfo = [[self.fetchedResultsControllerForCategory sections] objectAtIndex:section];
	
	return [subscriptionSectionInfo numberOfObjects] + [categorySectionInfo numberOfObjects];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return SECTION_HEIGHT;
	}
	
	return 0;
}

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsControllerForCategory
{
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
		noCategoryPredicate = [NSPredicate predicateWithFormat:@"categories.@count == 0 AND unreadCount > 0"];
	}
	else if (self.currentSegment == 1) {
		//cacheName = @"SubscriptionStarred";
		noCategoryPredicate = [NSPredicate predicateWithFormat:@"categories.@count == 0 AND starredCount > 0"];
	}
	else if (self.currentSegment == 2) {
		//cacheName = @"SubscriptionAll";
		noCategoryPredicate = [NSPredicate predicateWithFormat:@"categories.@count == 0"];
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
	[self.tableView reloadData];
}

#pragma mark - IBAction

- (IBAction)refresh:(id)sender {
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate refresh];
}

- (IBAction)changeMode:(id)sender {
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
	NSInteger segment = [segmentedControl selectedSegmentIndex];
	_currentSegment = segment;
	
	[NSFetchedResultsController deleteCacheWithName:self.currentCacheNameForCategory];
	[NSFetchedResultsController deleteCacheWithName:self.currentCacheNameForSubscription];
	
	self.fetchedResultsControllerForCategory = nil;
	self.fetchedResultsControllerForSubscription = nil;
	
	[self.tableView reloadData];
}

@end
