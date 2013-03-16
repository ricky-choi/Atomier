//
//  TopViewController.m
//  Atomier
//
//  Created by Choi Jaeyoung on 12/16/11.
//  Copyright (c) 2011 Appcid. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TopViewController.h"
#import "AppDelegate.h"
#import "TopViewCell.h"
#import "Category.h"
#import "Subscription.h"
#import "Feed.h"
#import "ContentOrganizer.h"
#import "FeedsViewController.h"
#import "NASegmentedControl.h"

#define TAG_ACTIONSHEET_CHANGEMODE 101
#define TAG_ACTUINSHEET_SETTINGS 100

@interface TopViewController ()

@property (nonatomic, retain) UIView *sectionView;

- (void)configureCell:(TopViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)addPreviewFeed:(PreviewFeed *)previewFeed;
- (BOOL)loadPreviewFeed:(NSFetchedResultsController *)controller;

- (void)setting:(UIBarButtonItem *)sender;
- (NSString *)currentModeName;

@end

@implementation TopViewController

@synthesize tableView = _tableView;
@synthesize sectionView = _sectionView;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize fetchedResultsControllerForCategory = __fetchedResultsControllerForCategory;
@synthesize fetchedResultsControllerForSubscription = __fetchedResultsControllerForSubscription;
@synthesize currentSegment = _currentSegment;
@synthesize previewFeed = _previewFeed;
@synthesize tempPreviewFeed = _tempPreviewFeed;
@synthesize category = _category;

@synthesize segmentControlPortrait = _segmentControlPortrait;
@synthesize segmentControlLandscape = _segmentControlLandscape;
@synthesize toolbarItemsPortrait = _toolbarItemsPortrait;
@synthesize toolbarItemsLandscape = _toolbarItemsLandscape;

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
		
		_segmentControlPortrait.selectedSegmentIndex = _currentSegment;
		
		[_segmentControlPortrait addTarget:self action:@selector(changeMode:) forControlEvents:UIControlEventValueChanged];
	}
	
	return _segmentControlPortrait;
}

- (NASegmentedControl *)segmentControlLandscape {
	if (_segmentControlLandscape == nil) {
		UIButton *segButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
		UIImage *segNormalImage1 = [UIImage imageNamed:@"segment_1_normal_landscape"];
		
		CGFloat shadowOffset = 1.0f / segNormalImage1.scale;
		
		UIImage *segSelectedImage1 = [UIImage imageNamed:@"segment_1_selected_landscape"];
		[segButton1 setFrame:CGRectMake(0, 0, segNormalImage1.size.width, segNormalImage1.size.height)];
		[segButton1 setBackgroundImage:segNormalImage1 forState:UIControlStateNormal];
		[segButton1 setBackgroundImage:segSelectedImage1 forState:UIControlStateHighlighted]; 
		[segButton1 setTitle:[TopViewController modeNameForSegment:0] forState:UIControlStateNormal];
		[segButton1 setTitleColor:[UIColor colorWithRed:63.0f/255.0f green:23.0f/255.0f blue:0 alpha:1] forState:UIControlStateNormal];
		[segButton1 setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
		segButton1.titleLabel.font = [UIFont boldSystemFontOfSize:14];
		segButton1.titleLabel.shadowOffset = CGSizeMake(0, shadowOffset);
		segButton1.titleEdgeInsets = UIEdgeInsetsMake(4, 0, 0, 0);
		
		UIButton *segButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
		UIImage *segNormalImage2 = [UIImage imageNamed:@"segment_2_normal_landscape"];
		UIImage *segSelectedImage2 = [UIImage imageNamed:@"segment_2_selected_landscape"];
		[segButton2 setFrame:CGRectMake(0, 0, segNormalImage2.size.width, segNormalImage2.size.height)];
		[segButton2 setBackgroundImage:segNormalImage2 forState:UIControlStateNormal];
		[segButton2 setBackgroundImage:segSelectedImage2 forState:UIControlStateHighlighted];
		[segButton2 setTitle:[TopViewController modeNameForSegment:1] forState:UIControlStateNormal];
		[segButton2 setTitleColor:[UIColor colorWithRed:63.0f/255.0f green:23.0f/255.0f blue:0 alpha:1] forState:UIControlStateNormal];
		[segButton2 setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
		segButton2.titleLabel.font = [UIFont boldSystemFontOfSize:14];
		segButton2.titleLabel.shadowOffset = CGSizeMake(0, shadowOffset);
		segButton2.titleEdgeInsets = UIEdgeInsetsMake(4, 0, 0, 0);
		
		UIButton *segButton3 = [UIButton buttonWithType:UIButtonTypeCustom];
		UIImage *segNormalImage3 = [UIImage imageNamed:@"segment_3_normal_landscape"];
		UIImage *segSelectedImage3 = [UIImage imageNamed:@"segment_3_selected_landscape"];
		[segButton3 setFrame:CGRectMake(0, 0, segNormalImage3.size.width, segNormalImage3.size.height)];
		[segButton3 setBackgroundImage:segNormalImage3 forState:UIControlStateNormal];
		[segButton3 setBackgroundImage:segSelectedImage3 forState:UIControlStateHighlighted];
		[segButton3 setTitle:[TopViewController modeNameForSegment:2] forState:UIControlStateNormal];
		[segButton3 setTitleColor:[UIColor colorWithRed:63.0f/255.0f green:23.0f/255.0f blue:0 alpha:1] forState:UIControlStateNormal];
		[segButton3 setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
		segButton3.titleLabel.font = [UIFont boldSystemFontOfSize:14];
		segButton3.titleLabel.shadowOffset = CGSizeMake(0, shadowOffset);
		segButton3.titleEdgeInsets = UIEdgeInsetsMake(4, 0, 0, 0);
		
		_segmentControlLandscape = [[NASegmentedControl alloc] initWithButtons:
								   [NSArray arrayWithObjects:
									segButton1, segButton2, segButton3, nil]];
		
		_segmentControlLandscape.selectedSegmentIndex = _currentSegment;
		
		[_segmentControlLandscape addTarget:self action:@selector(changeMode:) forControlEvents:UIControlEventValueChanged];
	}
	
	return _segmentControlLandscape;
}

- (NSArray *)toolbarItemsPortrait {
	if (_toolbarItemsPortrait == nil) {
		UIBarButtonItem *segmentItem = [[UIBarButtonItem alloc] initWithCustomView:self.segmentControlPortrait];
		UIBarButtonItem *flexibleSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		
		_toolbarItemsPortrait = [NSArray arrayWithObjects:flexibleSpaceItem, segmentItem, flexibleSpaceItem, nil];
	}
	
	return _toolbarItemsPortrait;
}

- (NSArray *)toolbarItemsLandscape {
	if (_toolbarItemsLandscape == nil) {
		UIBarButtonItem *segmentItem = [[UIBarButtonItem alloc] initWithCustomView:self.segmentControlLandscape];
		UIBarButtonItem *flexibleSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		
		_toolbarItemsLandscape = [NSArray arrayWithObjects:flexibleSpaceItem, segmentItem, flexibleSpaceItem, nil];
	}
	
	return _toolbarItemsLandscape;
}

#pragma mark -

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

- (NSManagedObjectContext *)managedObjectContext {
	if (__managedObjectContext == nil) {
		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		__managedObjectContext = appDelegate.managedObjectContext;
	}
	
	return __managedObjectContext;
}

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
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    [self.navigationItem.rightBarButtonItem setEnabled:([self.fetchedResultsControllerForSubscription.fetchedObjects count] > 0)];
	}	
}

+ (NSString *)modeNameForSegment:(NSUInteger)segment {
	if (segment == 0) {
		return NSLocalizedString(@"Unread", nil);
	}
	else if (segment == 1) {
		return NSLocalizedString(@"Starred", nil);
	}
	else if (segment == 2) {
		return NSLocalizedString(@"All Items", nil);
	}
	
	return nil;
}

- (NSString *)currentModeName {
	return [TopViewController modeNameForSegment:self.currentSegment];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
	[backItem setTintColor:[UIColor colorWithRed:63.0f/255.0f green:23.0f/255.0f blue:0 alpha:1]];
	self.navigationItem.backBarButtonItem = backItem;
	
	if (self.category) {
		self.title = self.category.label;
	}
	else {
		[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"syndi_nav_portrait"] 
													  forBarMetrics:UIBarMetricsDefault];
		[self.navigationController.toolbar setBackgroundImage:[UIImage imageNamed:@"syndi_toolbar_portrait"]
										   forToolbarPosition:UIToolbarPositionBottom
												   barMetrics:UIBarMetricsDefault];
		[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"syndi_nav_landscape"] 
													  forBarMetrics:UIBarMetricsLandscapePhone];
		[self.navigationController.toolbar setBackgroundImage:[UIImage imageNamed:@"syndi_toolbar_landscape"]
										   forToolbarPosition:UIToolbarPositionBottom
												   barMetrics:UIBarMetricsLandscapePhone];
		
		UIBarButtonItem *goHomeItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"newback_portrait"]
														 landscapeImagePhone:[UIImage imageNamed:@"newback_landscape"]
																	   style:UIBarButtonItemStylePlain
																	  target:self
																	  action:@selector(toHome:)];
		[goHomeItem setBackgroundImage:[UIImage imageNamed:@"transparent"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
		self.navigationItem.leftBarButtonItem = goHomeItem;
		
		UIImageView *titleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"syndi_title"]];
		self.navigationItem.titleView = titleImageView;
	}
	
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		self.navigationItem.rightBarButtonItem = self.editButtonItem;
		[self.navigationItem.rightBarButtonItem setTintColor:[UIColor colorWithRed:63.0f/255.0f green:23.0f/255.0f blue:0 alpha:1]];
		[self invalidateEditButton];
		
	} 	
	
	self.toolbarItems = self.toolbarItemsPortrait;

	
}

- (void)toHome:(UIBarButtonItem *)item {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)changeModeByAlternativeWay:(UIBarButtonItem *)barButtonItem {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
															 delegate:self 
													cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
											   destructiveButtonTitle:nil 
													otherButtonTitles:[TopViewController modeNameForSegment:0], [TopViewController modeNameForSegment:1], [TopViewController modeNameForSegment:2], nil];
	actionSheet.tag = TAG_ACTIONSHEET_CHANGEMODE;
	[actionSheet showFromBarButtonItem:barButtonItem animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.cancelButtonIndex) {
		return;
	}
	
	if (actionSheet.tag == TAG_ACTUINSHEET_SETTINGS) {
		if (buttonIndex == actionSheet.firstOtherButtonIndex) {
			// refresh
			[self refresh:nil];
		}
		else if (buttonIndex == actionSheet.firstOtherButtonIndex + 1) {
			// setting
			[self setting:nil];
		}
	} else if (actionSheet.tag == TAG_ACTIONSHEET_CHANGEMODE) {
		self.currentSegment = buttonIndex - actionSheet.firstOtherButtonIndex;

		[self.navigationItem.rightBarButtonItem setTitle:[self currentModeName]];
	}
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
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
	    [self.navigationController setToolbarHidden:YES animated:animated];
	}
	else {
		if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
			self.toolbarItems = self.toolbarItemsPortrait;
			self.segmentControlPortrait.selectedSegmentIndex = _currentSegment;
		} else {
			self.toolbarItems = self.toolbarItemsLandscape;
			self.segmentControlLandscape.selectedSegmentIndex = _currentSegment;
		}
	}
}

- (void)viewDidUnload
{
	[self setTableView:nil];
	
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
	    
	} else {
	    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
			self.toolbarItems = self.toolbarItemsPortrait;
			self.segmentControlPortrait.selectedSegmentIndex = _currentSegment;
		} else {
			self.toolbarItems = self.toolbarItemsLandscape;
			self.segmentControlLandscape.selectedSegmentIndex = _currentSegment;
		}
	}	
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
		allCell.textLabel.text = [self currentModeName];
		if (self.currentSegment == 0) {
			allCell.imageView.image = [UIImage imageNamed:@"unread"];
		}
		else if (self.currentSegment == 1) {
			allCell.imageView.image = [UIImage imageNamed:@"star"];
		}
		else if (self.currentSegment == 2) {
			allCell.imageView.image = [UIImage imageNamed:@"list"];
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
	
	if (indexPath.section == 1) {
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
		cell.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
		NSURL *sourceURL = [NSURL URLWithString:subscription.htmlUrl];
		UIImage *icon = [[ContentOrganizer sharedInstance] iconForSubscription:[sourceURL host]];
		if (icon) {
			cell.iconImageView.image = icon;
		} else {
			cell.iconImageView.image = [UIImage imageNamed:@"rss_source"];
		}	
		
		// accessory
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else {
		NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
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
		cell.iconImageView.contentMode = UIViewContentModeTopLeft;
		cell.iconImageView.image = [UIImage imageNamed:@"rss_folder"];
		
		// accessory
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	}

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return nil;
		//return NSLocalizedString(@"All", nil);
	}
	else if (section == 1) {
		id <NSFetchedResultsSectionInfo> subscriptionSectionInfo = [[self.fetchedResultsControllerForSubscription sections] objectAtIndex:0];
		if ([subscriptionSectionInfo numberOfObjects] > 0) {
			return NSLocalizedString(@"Subscriptions", nil);
		}		
	}
	else if (section == 2) {
		id <NSFetchedResultsSectionInfo> categorySectionInfo = [[self.fetchedResultsControllerForCategory sections] objectAtIndex:0];
		if ([categorySectionInfo numberOfObjects] > 0) {
			return NSLocalizedString(@"Folders", nil);
		}
	}
	
	return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
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
	
	if (section == 1) {
		return [subscriptionSectionInfo numberOfObjects];
	} else {
		return [categorySectionInfo numberOfObjects];
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.section == 1) {
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

	if (self.editing) {
		return;
	}
	
	NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
	Category *category = [self.fetchedResultsControllerForCategory objectAtIndexPath:newIndexPath];
	
	TopViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TopViewController"];
	newTopViewController.category = category;
	newTopViewController.title = category.label;
	newTopViewController.currentSegment = self.currentSegment;
	
	[self.navigationController pushViewController:newTopViewController animated:YES];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//	if (section == 1) {
//		return 10.0f;
//	}
//	
//	return 0;
//}

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
	if ([segue.identifier isEqualToString:@"FeedList"]) {
		FeedsViewController *viewController = (FeedsViewController *)segue.destinationViewController;
		viewController.currentSegment = self.currentSegment;
		viewController.category = self.category;
		viewController.title = [self currentModeName];
	}
	else if ([segue.identifier isEqualToString:@"FeedListFromFolder"]) {
		FeedsViewController *viewController = (FeedsViewController *)segue.destinationViewController;
		viewController.currentSegment = self.currentSegment;
		
		TopViewCell *cell = (TopViewCell *)sender;
		NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
		
		if (indexPath.section == 1) {
			NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
			Subscription *subscription = [self.fetchedResultsControllerForSubscription objectAtIndexPath:newIndexPath];
			viewController.subscription = subscription;
			viewController.title = subscription.title;
		} else {
			NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
			Category *category = [self.fetchedResultsControllerForCategory objectAtIndexPath:newIndexPath];
			viewController.category = category;
			viewController.title = category.label;
		}
	}
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
	
	NSPredicate *existUnreadPredicate = nil;
	if (self.currentSegment == 0) {
		existUnreadPredicate = [NSPredicate predicateWithFormat:@"unreadCount > 0"];
	}
	else if (self.currentSegment == 1) {
		existUnreadPredicate = [NSPredicate predicateWithFormat:@"starredCount > 0"];
	}
	else if (self.currentSegment == 2) {

	}
	
	if (existUnreadPredicate) {
		[fetchRequest setPredicate:existUnreadPredicate];
	}	
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
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
	
	NSPredicate *noCategoryPredicate = nil;
	if (self.currentSegment == 0) {
		if (self.category) {
			noCategoryPredicate = [NSPredicate predicateWithFormat:@"(ANY categories.keyId == %@) AND (unreadCount > 0)", self.category.keyId];
		} else {
			noCategoryPredicate = [NSPredicate predicateWithFormat:@"categories.@count == 0 AND unreadCount > 0"];
		}
		
	}
	else if (self.currentSegment == 1) {
		if (self.category) {
			noCategoryPredicate = [NSPredicate predicateWithFormat:@"(ANY categories.keyId == %@) AND (starredCount > 0)", self.category.keyId];
		} else {
			noCategoryPredicate = [NSPredicate predicateWithFormat:@"categories.@count == 0 AND starredCount > 0"];
		}
		
	}
	else if (self.currentSegment == 2) {
		if (self.category) {
			noCategoryPredicate = [NSPredicate predicateWithFormat:@"ANY categories.keyId == %@", self.category.keyId];
		} else {
			noCategoryPredicate = [NSPredicate predicateWithFormat:@"categories.@count == 0"];
		}
		
	}

	if (noCategoryPredicate) {
		[fetchRequest setPredicate:noCategoryPredicate];
	}
	    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
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

- (void)setting:(UIBarButtonItem *)sender {
	SettingsViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)settingWithOption:(UIBarButtonItem *)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Refresh All", nil), NSLocalizedString(@"Settings", nil), nil];
	actionSheet.tag = TAG_ACTUINSHEET_SETTINGS;
	[actionSheet showFromBarButtonItem:sender animated:YES];
//	[actionSheet showFromToolbar:self.navigationController.toolbar];
}

- (IBAction)refresh:(id)sender {
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate refresh];
}

- (IBAction)changeMode:(id)sender {
	self.editing = NO;
	
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
	NSInteger segment = [segmentedControl selectedSegmentIndex];
	
	self.currentSegment = segment;
}

- (void)setCurrentSegment:(NSInteger)segment {
	if (_currentSegment != segment) {
		_currentSegment = segment;
		
		self.fetchedResultsControllerForCategory = nil;
		self.fetchedResultsControllerForSubscription = nil;
		
#if 0
		[self.tableView reloadData];
#else
		[self.tableView beginUpdates];
		
		[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
		
		[self.tableView endUpdates];
#endif
		
		[self invalidateEditButton];
	}
	
}

@end
