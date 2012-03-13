//
//  SearchViewController.m
//  Atomier
//
//  Created by Choi Jaeyoung on 12. 3. 5..
//  Copyright (c) 2012년 Appcid. All rights reserved.
//

#import "SearchViewController.h"
#import "Category.h"
#import "Subscription.h"
#import "Feed.h"
#import "ContentOrganizer.h"
#import "AppDelegate.h"
#import "TopViewController.h"
#import "FeedsViewController.h"
#import "FeedViewController.h"

@interface SearchViewController ()

@end

@implementation SearchViewController

@synthesize mode;
@synthesize searchResults = _searchResults;
@synthesize recommendeds = _recommendeds;
@synthesize managedObjectContext = __managedObjectContext;

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
	
	if (self.mode == SearchViewControllerModeSearch) {
		self.searchDisplayController.searchBar.scopeButtonTitles = [NSArray arrayWithObjects:
																	NSLocalizedString(@"Category", nil),
																	NSLocalizedString(@"Subscription", nil),
																	NSLocalizedString(@"Feed", nil), nil];
		self.title = NSLocalizedString(@"Search", nil);
	} else {
		self.title = NSLocalizedString(@"Subscribe", nil);
		self.searchDisplayController.searchBar.placeholder = NSLocalizedString(@"Search term or Enter feed URL", nil);
	}
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (self.mode == SearchViewControllerModeSearch) {
		[self.searchDisplayController.searchBar becomeFirstResponder];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	if (self.mode == SearchViewControllerModeSearch) {
		[self done:nil];
	}
}

- (IBAction)done:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark UITableView data source and delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (self.mode == SearchViewControllerModeSearch) {
		if (tableView == self.searchDisplayController.searchResultsTableView) {
			return [self.searchResults count];
		} else {
			return 0;
		}
	} else {
		if (tableView == self.searchDisplayController.searchResultsTableView) {
			return [self.searchResults count];
		} else {
			return [self.recommendeds count];
		}
	}
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (tableView == self.searchDisplayController.searchResultsTableView) {
		if (self.mode == SearchViewControllerModeSearch) {
			static NSString *kCellID = @"";
			
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellID];
			}
			
			NSInteger scope = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
			if (scope == 0) {
				Category *item = [self.searchResults objectAtIndex:indexPath.row];
				cell.textLabel.text = item.label;
				cell.detailTextLabel.text = nil;
				cell.imageView.image = [UIImage imageNamed:@"rss_folder"];
				cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
			}
			else if (scope == 1) {
				Subscription *item = [self.searchResults objectAtIndex:indexPath.row];
				cell.textLabel.text = item.title;
				cell.detailTextLabel.text = nil;
				cell.imageView.image = [UIImage imageNamed:@"rss_source"];
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
			else if (scope == 2) {
				Feed *item = [self.searchResults objectAtIndex:indexPath.row];
				cell.textLabel.text = item.title;
				cell.detailTextLabel.text = [[ContentOrganizer sharedInstance] summaryForID:[item.keyId lastPathComponent]];
				cell.imageView.image = [UIImage imageNamed:@"rss_source"];
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
			
			return cell;
		}
	}
	
	return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (tableView == self.searchDisplayController.searchResultsTableView) {
		if (self.mode == SearchViewControllerModeSearch) {
			NSInteger scope = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
			if (scope == 0) {
				Category *category = [self.searchResults objectAtIndex:indexPath.row];
				FeedsViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FeedsViewController"];
				viewController.currentSegment = 2;
				viewController.category = category;
				viewController.title = category.label;
				[self.navigationController pushViewController:viewController animated:YES];
			}
			else if (scope == 1) {
				Subscription *subscription = [self.searchResults objectAtIndex:indexPath.row];
				FeedsViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FeedsViewController"];
				viewController.currentSegment = 2;
				viewController.subscription = subscription;
				viewController.title = subscription.title;
				[self.navigationController pushViewController:viewController animated:YES];
			}
			else if (scope == 2) {
				Feed *feed = [self.searchResults objectAtIndex:indexPath.row];
				FeedViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FeedViewController"];
				viewController.feed = feed;
				viewController.feeds = self.searchResults;
				[self.navigationController pushViewController:viewController animated:YES];
			}
		}		
	}
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {	
	Category *category = [self.searchResults objectAtIndex:indexPath.row];
	
	TopViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TopViewController"];
	newTopViewController.category = category;
	newTopViewController.title = category.label;
	newTopViewController.currentSegment = 0;
	
	[self.navigationController pushViewController:newTopViewController animated:YES];
}


#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSInteger)scope
{
	if (self.mode == SearchViewControllerModeSearch) {
		if (scope == 0) {
			NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
			NSEntityDescription *entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
			[fetchRequest setEntity:entity];
			
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"label contains[cd] %@", searchText];
			[fetchRequest setPredicate:predicate];
			
			self.searchResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
		}
		else if (scope == 1) {
			NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
			NSEntityDescription *entity = [NSEntityDescription entityForName:@"Subscription" inManagedObjectContext:self.managedObjectContext];
			[fetchRequest setEntity:entity];
			
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title contains[cd] %@", searchText];
			[fetchRequest setPredicate:predicate];
			
			self.searchResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
		}
		else if (scope == 2) {
			NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
			NSEntityDescription *entity = [NSEntityDescription entityForName:@"Feed" inManagedObjectContext:self.managedObjectContext];
			[fetchRequest setEntity:entity];
			
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title contains[cd] %@", searchText];
			[fetchRequest setPredicate:predicate];
			
			self.searchResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
		}
	}
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:searchOption];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

@end
