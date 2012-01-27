//
//  StandViewController.m
//  Atomier
//
//  Created by Choi Jaeyoung on 12/28/11.
//  Copyright (c) 2011 Appcid. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "StandViewController.h"
#import "AppDelegate.h"
#import "Category.h"
#import "Subscription.h"
#import "TopViewController.h"
#import "FeedsViewController.h"
#import "UIBezierPath+ShadowPath.h"
#import "UIView+Wiggle.h"
#import "SettingsViewController.h"

#define IPHONE_STORYBOARD [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil]

@interface StandViewController ()

- (void)insertObject:(NSManagedObject *)managedObject atIndex:(NSUInteger)index;
- (void)deleteObject:(NSManagedObject *)managedObject atIndex:(NSUInteger)index;

@end

@implementation StandViewController

@synthesize managedObjectContext = __managedObjectContext;
@synthesize fetchedResultsControllerForCategory = __fetchedResultsControllerForCategory;
@synthesize fetchedResultsControllerForSubscription = __fetchedResultsControllerForSubscription;
@synthesize currentSegment = _currentSegment;
@synthesize category = _category;
@synthesize scrollView = _scrollView;
@synthesize childs = _childs;
@synthesize chipSize = _chipSize;
@synthesize selectedFeedsViewController = _selectedFeedsViewController;

- (NSMutableDictionary *)childs {
	if (_childs == nil) {
		_childs = [NSMutableDictionary dictionaryWithCapacity:10];
	}
	
	return _childs;
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

- (NSManagedObjectContext *)managedObjectContext {
	if (__managedObjectContext == nil) {
		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		__managedObjectContext = appDelegate.managedObjectContext;
	}
	
	return __managedObjectContext;
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

- (void)invalidateEditButton {
	[self.navigationItem.rightBarButtonItem setEnabled:([self.fetchedResultsControllerForSubscription.fetchedObjects count] + [self.fetchedResultsControllerForCategory.fetchedObjects count] > 0)];
}

- (CGSize)chipSize {
	if (CGSizeEqualToSize(_chipSize, CGSizeZero)) {
		return CGSizeMake(320, 320);
	}
	
	return _chipSize;
}

- (CGPoint)nextOrigin:(CGPoint)before padding:(CGFloat)padding scrollViewWidth:(CGFloat)scrollViewWidth {
	CGSize viewControllerSize = self.chipSize;
	
	if (before.x + viewControllerSize.width + padding + viewControllerSize.width < scrollViewWidth) {
		return CGPointMake(before.x + viewControllerSize.width + padding, before.y);
	} else {
		return CGPointMake(padding, before.y + viewControllerSize.height + padding);
	}
}

- (void)addShadow:(CALayer *)layer {
	layer.shadowOffset = CGSizeMake(0, 3);
	layer.shadowOpacity = 0.7;
	layer.shadowPath = [UIBezierPath bezierPathWithCurvedShadowForRect:layer.bounds].CGPath;
}

- (void)addShadowRightAngle:(CALayer *)layer {
	layer.shadowOffset = CGSizeMake(0, 3);
	layer.shadowOpacity = 0.7;
	layer.shadowPath = [UIBezierPath bezierPathWithShadowForRect:layer.bounds].CGPath;
}

- (void)invalidateItemsForOrientation:(UIInterfaceOrientation)interfaceOrientation changeMode:(BOOL)changeMode {
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
	    NSLog(@"subscription: %@", self.fetchedResultsControllerForSubscription);
		NSLog(@"category: %@", self.fetchedResultsControllerForCategory);
		
		//		for (UIViewController *childViewController in self.childViewControllers) {
		//			[childViewController removeFromParentViewController];
		//			[childViewController.view removeFromSuperview];
		//		}
		
		CGFloat scrollViewWidth = 0.0;
		if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
			scrollViewWidth = 768.0f;
		} else {
			scrollViewWidth = 1024.0f;
		}
		
		NSArray *subscriptions = [self.fetchedResultsControllerForSubscription fetchedObjects];
		NSArray *cateogries = [self.fetchedResultsControllerForCategory fetchedObjects];
		
		NSUInteger chipCount = [subscriptions count] + [cateogries count];
		if (chipCount > 0) {
			chipCount++;
		}
		
		if (chipCount <= 1) {
			if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
				self.chipSize = CGSizeMake(680, 820);
			} else {
				self.chipSize = CGSizeMake(940, 580);
			}
			
		}
		else if (chipCount == 2) {
			if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
				self.chipSize = CGSizeMake(680, 400);
			} else {
				self.chipSize = CGSizeMake(460, 600);
			}
		}
		else if (chipCount == 3 || chipCount == 4) {
			if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
				self.chipSize = CGSizeMake(320, 400);
			} else {
				self.chipSize = CGSizeMake(460, 300);
			}
			
		}
		else {
			if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
				self.chipSize = CGSizeMake(320, 320);
			} else {
				self.chipSize = CGSizeMake(300, 300);
			}
		}
		
		CGSize viewControllerSize = self.chipSize;
		int numberOfViewControllerPerRow = scrollViewWidth / viewControllerSize.width;
		CGFloat padding = (float)(scrollViewWidth - viewControllerSize.width * numberOfViewControllerPerRow) / (float)(numberOfViewControllerPerRow + 1);
		int paddingInt = (int)padding;
		CGPoint nextOrigin = CGPointMake(paddingInt, paddingInt);
		
		NSMutableDictionary *newChilds = [NSMutableDictionary dictionaryWithCapacity:chipCount];
		
		if (chipCount > 0) {
			// all
			UINavigationController *exist = [self.childs valueForKey:@"ALL"];
			UINavigationController *navigationController;
			FeedsViewController *feedsViewController;
			if (exist) {
				navigationController = exist;
				feedsViewController = (FeedsViewController *)[navigationController topViewController];
				feedsViewController.currentSegment = self.currentSegment;
			}
			else {
				feedsViewController = [IPHONE_STORYBOARD instantiateViewControllerWithIdentifier:@"FeedsViewController"];
				feedsViewController.currentSegment = self.currentSegment;
				
				navigationController = [[UINavigationController alloc] initWithRootViewController:feedsViewController];
				navigationController.view.autoresizingMask = UIViewAutoresizingNone;
				
				[self addChildViewController:navigationController];
				[self.scrollView addSubview:navigationController.view];
			}
			
			[self.childs removeObjectForKey:@"ALL"];
			[newChilds setValue:navigationController forKey:@"ALL"];
			
			navigationController.view.frame = CGRectMake(nextOrigin.x, nextOrigin.y, viewControllerSize.width, viewControllerSize.height);
			
			if ([navigationController.view superview] == nil) {
				[self.scrollView addSubview:navigationController.view];
			}
			
			[self addShadow:navigationController.view.layer];
			
			nextOrigin = [self nextOrigin:nextOrigin padding:(CGFloat)paddingInt scrollViewWidth:scrollViewWidth];
		}
		
		int tag = 3;
		for (Subscription *subscription in subscriptions) {
			UINavigationController *exist = [self.childs valueForKey:subscription.keyId];
			UINavigationController *navigationController;
			FeedsViewController *feedsViewController;
			if (exist) {
				navigationController = exist;
				if (changeMode) {
					[navigationController popToRootViewControllerAnimated:YES];
				}
				feedsViewController = (FeedsViewController *)[navigationController topViewController];
				feedsViewController.currentSegment = self.currentSegment;
			} else {
				feedsViewController = [IPHONE_STORYBOARD instantiateViewControllerWithIdentifier:@"FeedsViewController"];
				feedsViewController.subscription = subscription;
				feedsViewController.currentSegment = self.currentSegment;
				
				navigationController = [[UINavigationController alloc] initWithRootViewController:feedsViewController];
				navigationController.view.autoresizingMask = UIViewAutoresizingNone;
				
				//[self.childs setValue:navigationController forKey:subscription.keyId];
				
				[self addChildViewController:navigationController];
				[self.scrollView addSubview:navigationController.view];
			}			
			
			
			
			[self.childs removeObjectForKey:subscription.keyId];
			[newChilds setValue:navigationController forKey:subscription.keyId];
			
			navigationController.view.frame = CGRectMake(nextOrigin.x, nextOrigin.y, viewControllerSize.width, viewControllerSize.height);
			navigationController.view.tag = ++tag;
			
			if ([navigationController.view superview] == nil) {
				[self.scrollView addSubview:navigationController.view];
			}
			
			[self addShadow:navigationController.view.layer];
			
			nextOrigin = [self nextOrigin:nextOrigin padding:(CGFloat)paddingInt scrollViewWidth:scrollViewWidth];
		}
		
		for (Category *category in cateogries) {
			UINavigationController *exist = [self.childs valueForKey:category.keyId];
			UINavigationController *navigationController;
			TopViewController *topViewController;
			if (exist) {
				navigationController = exist;
				if (changeMode) {
					[navigationController popToRootViewControllerAnimated:YES];
				}
				topViewController = (TopViewController *)[navigationController topViewController];
				topViewController.currentSegment = self.currentSegment;
			} else {
				TopViewController *topViewController = [IPHONE_STORYBOARD instantiateViewControllerWithIdentifier:@"TopViewController"];
				topViewController.category = category;
				topViewController.currentSegment = self.currentSegment;
				
				navigationController = [[UINavigationController alloc] initWithRootViewController:topViewController];
				navigationController.view.autoresizingMask = UIViewAutoresizingNone;
				
				[self addChildViewController:navigationController];
				[self.scrollView addSubview:navigationController.view];
			}
			
			
			
			[self.childs removeObjectForKey:category.keyId];
			[newChilds setValue:navigationController forKey:category.keyId];
			
			navigationController.view.frame = CGRectMake(nextOrigin.x, nextOrigin.y, viewControllerSize.width, viewControllerSize.height);
			
			if ([navigationController.view superview] == nil) {
				[self.scrollView addSubview:navigationController.view];
			}
			
			[self addShadow:navigationController.view.layer];
			
			nextOrigin = [self nextOrigin:nextOrigin padding:(CGFloat)paddingInt scrollViewWidth:scrollViewWidth];
		}
		
		if (nextOrigin.x == paddingInt) {
			self.scrollView.contentSize = CGSizeMake(scrollViewWidth, nextOrigin.y);
		} else {
			self.scrollView.contentSize = CGSizeMake(scrollViewWidth, nextOrigin.y + viewControllerSize.height + paddingInt);
		}
		
		if ([self.childs count] > 0) {
			for (NSString *key in self.childs) {
				UINavigationController *exist = [self.childs valueForKey:key];
				if (exist) {
					[exist removeFromParentViewController];
					[exist.view removeFromSuperview];
				}
			}
		}
		
		self.childs = newChilds;
	}	
}

- (void)invalidateItemsForOrientation:(UIInterfaceOrientation)interfaceOrientation {
	[self invalidateItemsForOrientation:interfaceOrientation changeMode:NO];
}

- (void)insertObject:(NSManagedObject *)managedObject atIndex:(NSUInteger)index {
	
	dispatch_sync(dispatch_get_main_queue(), ^{
		[self invalidateItemsForOrientation:self.interfaceOrientation];
		[self invalidateEditButton];
	});
}

- (void)deleteObject:(NSManagedObject *)managedObject atIndex:(NSUInteger)index {
	
	dispatch_sync(dispatch_get_main_queue(), ^{
		NSString *key = nil;
		if ([managedObject isKindOfClass:[Category class]]) {
			key = [(Category *)managedObject keyId];
		}
		else if ([managedObject isKindOfClass:[Subscription class]]) {
			key = [(Subscription *)managedObject keyId];
		}
		
		UINavigationController *exist = [self.childs valueForKey:key];
		if (exist) {
			[exist removeFromParentViewController];
			[exist.view removeFromSuperview];
		}
		
		[self invalidateItemsForOrientation:self.interfaceOrientation];
		[self invalidateEditButton];
	});
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	//self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
	//self.navigationController.toolbar.barStyle = self.navigationController.navigationBar.barStyle;
	//self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"wood"]];
	
	self.navigationController.navigationBar.clipsToBounds = NO;
	[self addShadowRightAngle:self.navigationController.navigationBar.layer];
	
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	[self invalidateEditButton];
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad || self.category == nil) {
		UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
		UIBarButtonItem *settingItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Settings"] style:UIBarButtonItemStylePlain target:self action:@selector(setting:)];
		self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:refreshItem, settingItem, nil];
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
	
	self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
	self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	//self.scrollView.contentInset = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height, 0, self.navigationController.toolbar.frame.size.height, 0);
	//self.scrollView.scrollIndicatorInsets = self.scrollView.contentInset;
	[self.view addSubview:self.scrollView];
}

- (void)setting:(UIBarButtonItem *)sender {
	SettingsViewController *viewController = [IPHONE_STORYBOARD instantiateViewControllerWithIdentifier:@"SettingsViewController"];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentViewController:navigationController animated:YES completion:nil];

}


- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[self invalidateItemsForOrientation:self.interfaceOrientation];
}

#define CLOSE_BUTTON_TAG 999

- (void)addCloseButton:(UIViewController *)viewController {
	if ([viewController isKindOfClass:[UINavigationController class]]) {
		UINavigationController *navigationController = (UINavigationController *)viewController;
		UIViewController *nestedViewController = navigationController.visibleViewController;
		if ([nestedViewController isKindOfClass:[FeedsViewController class]]) {
			self.selectedFeedsViewController = (FeedsViewController *)nestedViewController;
			
			UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
			button.tag = CLOSE_BUTTON_TAG;
			[button setImage:[UIImage imageNamed:@"closebox"] forState:UIControlStateNormal];
			[button setImage:[UIImage imageNamed:@"closebox_pressed"] forState:UIControlStateHighlighted];
			button.frame = CGRectMake(0, 0, 32, 33);
			button.center = viewController.view.bounds.origin;
			[button addTarget:self action:@selector(unsubscribe:) forControlEvents:UIControlEventTouchUpInside];
			[viewController.view addSubview:button];
		}
		
	}
	
}

- (void)unsubscribe:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Unsubscribe", nil) otherButtonTitles:nil];
	[actionSheet showFromRect:[sender bounds] inView:sender animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.destructiveButtonIndex) {
		[UIView animateWithDuration:0.5
						 animations:^{
							 self.selectedFeedsViewController.navigationController.view.alpha = 0.0;
							 self.selectedFeedsViewController.navigationController.view.transform = CGAffineTransformMakeScale(0.1, 0.1);
						 }
						 completion:^(BOOL finished){
							 [self.selectedFeedsViewController unsubscribe];
						 }];
	}
}

- (void)removeCloseButton:(UIViewController *)viewController {
	UIView *buttonView = [viewController.view viewWithTag:CLOSE_BUTTON_TAG];
	if (buttonView) {
		[buttonView removeFromSuperview];
	}
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	
	for (UIViewController *viewController in self.childViewControllers) {
		[viewController setEditing:editing animated:animated];
		
		if (viewController.view.tag > 0) {
			if (editing) {
				[viewController.view startWiggling];
				[self addCloseButton:viewController];
			} else {
				[viewController.view stopWiggling];
				[self removeCloseButton:viewController];
			}
			
		}
	}
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
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[UIView animateWithDuration:duration 
					 animations:^{
						 [self invalidateItemsForOrientation:toInterfaceOrientation]; 
					 }
					 completion:^(BOOL finished){
						 [self addShadowRightAngle:self.navigationController.navigationBar.layer];
					 }];
}

- (IBAction)refresh:(id)sender {
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate refresh];
}

- (IBAction)changeMode:(id)sender {
	self.editing = NO;
	
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
	NSInteger segment = [segmentedControl selectedSegmentIndex];
	_currentSegment = segment;
	
	self.fetchedResultsControllerForCategory = nil;
	self.fetchedResultsControllerForSubscription = nil;
	
	// Reload Interface	
	[self invalidateItemsForOrientation:self.interfaceOrientation changeMode:YES];
	
	[self invalidateEditButton];
}

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

#if 0

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{    
    switch(type) {
        case NSFetchedResultsChangeInsert:
			[self insertObject:[controller objectAtIndexPath:indexPath] atIndex:indexPath.row];
            break;
            
        case NSFetchedResultsChangeDelete:
			[self deleteObject:[controller objectAtIndexPath:indexPath] atIndex:indexPath.row];
            break;
            
        case NSFetchedResultsChangeMove:
			[self deleteObject:[controller objectAtIndexPath:indexPath] atIndex:indexPath.row];
			//[self insertObject:[controller objectAtIndexPath:newIndexPath] atIndex:newIndexPath.row];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    
}

#else

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	// In the simplest, most efficient, case, reload the table view.
	NSLog(@"controllerDidChangeContent: %@", controller);

	[self invalidateItemsForOrientation:self.interfaceOrientation];
	[self invalidateEditButton];
}

#endif

@end
