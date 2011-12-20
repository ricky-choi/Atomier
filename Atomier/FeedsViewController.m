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
#import "ContentOrganizer.h"
#import "AppDelegate.h"
#import "FeedsViewCell.h"

@interface FeedsViewController ()

- (void)configureCell:(FeedsViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation FeedsViewController

@synthesize tableView = _tableView;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize currentSegment = _currentSegment;
@synthesize category = _category;
@synthesize subscription = _subscription;

- (void)awakeFromNib {
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	self.managedObjectContext = appDelegate.managedObjectContext;
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

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	UIBarButtonItem *markAll = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Mark all as read", nil) 
																style:UIBarButtonItemStyleBordered 
															   target:self
															   action:@selector(markAllAsRead)];
	self.toolbarItems = [NSArray arrayWithObjects:markAll, nil];
}

- (void)markAllAsRead {
	NSArray *feeds = [self.fetchedResultsController fetchedObjects];
	
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate markAsAllRead:feeds];
	
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
}

- (void)viewDidUnload
{
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

#pragma mark - TableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"FeedsCell";
    
    FeedsViewCell *cell = (FeedsViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	[self configureCell:cell atIndexPath:indexPath];
	
    return cell;
}

- (void)configureCell:(FeedsViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
	Feed *feed = [self.fetchedResultsController objectAtIndexPath:indexPath];
	cell.titleLabel.text = feed.title;
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
		cell.unreadImageView.image = [UIImage imageNamed:@"UnreadItem"];
	} else {
		cell.unreadImageView.image = nil;
	}
	
	if ([feed.starred boolValue]) {
		cell.starredImageView.image = [UIImage imageNamed:@"StarredItem"];
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
	
	NSString *titleString = [NSDateFormatter localizedStringFromDate:date
														   dateStyle:NSDateFormatterFullStyle
														   timeStyle:NSDateFormatterNoStyle];
	
	return titleString;
#endif
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	
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
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"updatedDate" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
	
	NSPredicate *predicate = nil;

	if (self.subscription) {
		if (self.currentSegment == 0) {
			predicate = [NSPredicate predicateWithFormat:@"(ANY subscription.keyId == %@) AND (unread = 1)", self.subscription.keyId];
		}
		else if (self.currentSegment == 1) {
			predicate = [NSPredicate predicateWithFormat:@"(ANY subscription.keyId == %@) AND (starred = 1)", self.subscription.keyId];
		}
		else if (self.currentSegment == 2) {
			predicate = [NSPredicate predicateWithFormat:@"ANY subscription.keyId == %@", self.subscription.keyId];
		}
	}
	else if (self.category) {
		if (self.currentSegment == 0) {
			predicate = [NSPredicate predicateWithFormat:@"(ANY subscription.categories.keyId == %@) AND (unread = 1)", self.category.keyId];
		}
		else if (self.currentSegment == 1) {
			predicate = [NSPredicate predicateWithFormat:@"(ANY subscription.categories.keyId == %@) AND (starred = 1)", self.category.keyId];
		}
		else if (self.currentSegment == 2) {
			predicate = [NSPredicate predicateWithFormat:@"ANY subscription.categories.keyId == %@", self.category.keyId];
		}
	}
	else {
		if (self.currentSegment == 0) {
			predicate = [NSPredicate predicateWithFormat:@"unread = 1"];
		}
		else if (self.currentSegment == 1) {
			predicate = [NSPredicate predicateWithFormat:@"starred = 1"];
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
    
    return __fetchedResultsController;
} 

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	// In the simplest, most efficient, case, reload the table view.
	NSLog(@"controllerDidChangeContent: %@", controller);
	[self.tableView reloadData];
}

@end
