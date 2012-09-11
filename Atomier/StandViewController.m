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
#import "NASegmentedControl.h"
#import "SearchViewController.h"

#define IPHONE_STORYBOARD [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil]

#define TAG_ACTIONSHEET_CHANGEMODE 101
#define TAG_ACTUINSHEET_UNSUBSCRIBE 100

@interface StandViewController ()

- (void)insertObject:(NSManagedObject *)managedObject atIndex:(NSUInteger)index;
- (void)deleteObject:(NSManagedObject *)managedObject atIndex:(NSUInteger)index;

- (void)invalidateItemsForOrientation:(UIInterfaceOrientation)interfaceOrientation changeMode:(BOOL)changeMode;
- (void)invalidateItemsForOrientation:(UIInterfaceOrientation)interfaceOrientation;

- (NSString *)currentModeName;

- (void)navbarImageChangeForOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (void)customizeInnerNavigationBar:(UINavigationBar *)navigationBar;

- (void)showUpdateStatus;

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
@synthesize actionSheet = _actionSheet;
@synthesize segmentControl = _segmentControl;
@synthesize segmentView = _segmentView;
@synthesize popover = _popover;
@synthesize updateLabel = _updateLabel;
@synthesize messageLabel = _messageLabel;
@synthesize statusLabel = _statusLabel;

- (NASegmentedControl *)segmentControl {
	if (_segmentControl == nil) {
		UIImage *normalImage = [UIImage imageNamed:@"transparent"];
		UIImage *selectedImage = [UIImage imageNamed:@"SegButton~ipad"];
		
		CGFloat shadowOffset = 1.0f / selectedImage.scale;
		
		UIButton *segButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
		[segButton1 setFrame:CGRectMake(0, 0, selectedImage.size.width, selectedImage.size.height)];
		[segButton1 setBackgroundImage:normalImage forState:UIControlStateNormal];
		[segButton1 setBackgroundImage:selectedImage forState:UIControlStateHighlighted]; 
		[segButton1 setTitle:[TopViewController modeNameForSegment:0] forState:UIControlStateNormal];
		[segButton1 setTitleColor:[UIColor colorWithRed:63.0f/255.0f green:23.0f/255.0f blue:0 alpha:1] forState:UIControlStateNormal];
		[segButton1 setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
		segButton1.titleLabel.font = [UIFont boldSystemFontOfSize:14];
		segButton1.titleLabel.shadowOffset = CGSizeMake(0, shadowOffset);
		//segButton1.titleEdgeInsets = UIEdgeInsetsMake(7, 0, 0, 0);
		
		UIButton *segButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
		[segButton2 setFrame:CGRectMake(0, 0, selectedImage.size.width, selectedImage.size.height)];
		[segButton2 setBackgroundImage:normalImage forState:UIControlStateNormal];
		[segButton2 setBackgroundImage:selectedImage forState:UIControlStateHighlighted];
		[segButton2 setTitle:[TopViewController modeNameForSegment:1] forState:UIControlStateNormal];
		[segButton2 setTitleColor:[UIColor colorWithRed:63.0f/255.0f green:23.0f/255.0f blue:0 alpha:1] forState:UIControlStateNormal];
		[segButton2 setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
		segButton2.titleLabel.font = [UIFont boldSystemFontOfSize:14];
		segButton2.titleLabel.shadowOffset = CGSizeMake(0, shadowOffset);
		//segButton2.titleEdgeInsets = UIEdgeInsetsMake(7, 0, 0, 0);
		
		UIButton *segButton3 = [UIButton buttonWithType:UIButtonTypeCustom];
		[segButton3 setFrame:CGRectMake(0, 0, selectedImage.size.width, selectedImage.size.height)];
		[segButton3 setBackgroundImage:normalImage forState:UIControlStateNormal];
		[segButton3 setBackgroundImage:selectedImage forState:UIControlStateHighlighted];
		[segButton3 setTitle:[TopViewController modeNameForSegment:2] forState:UIControlStateNormal];
		[segButton3 setTitleColor:[UIColor colorWithRed:63.0f/255.0f green:23.0f/255.0f blue:0 alpha:1] forState:UIControlStateNormal];
		[segButton3 setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
		segButton3.titleLabel.font = [UIFont boldSystemFontOfSize:14];
		segButton3.titleLabel.shadowOffset = CGSizeMake(0, shadowOffset);
		//segButton3.titleEdgeInsets = UIEdgeInsetsMake(7, 0, 0, 0);
		
		_segmentControl = [[NASegmentedControl alloc] initWithButtons:
								   [NSArray arrayWithObjects:
									segButton1, segButton2, segButton3, nil]];
		
		_segmentControl.selectedSegmentIndex = _currentSegment;
		
		[_segmentControl addTarget:self action:@selector(changeMode:) forControlEvents:UIControlEventValueChanged];
	}
	
	return _segmentControl;
}

#pragma mark -

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

- (NSString *)currentModeName {
	return [TopViewController modeNameForSegment:self.currentSegment];
}

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
	layer.shadowOffset = CGSizeMake(0, 2);
	layer.shadowOpacity = 0.7;
	layer.shadowPath = [UIBezierPath bezierPathWithShadowForRect:layer.bounds].CGPath;
}

- (void)customizeInnerNavigationBar:(UINavigationBar *)navigationBar {
	[navigationBar setBackgroundImage:[UIImage imageNamed:@"syndi_nav_portrait"] forBarMetrics:UIBarMetricsDefault];
	[navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
										   [UIColor whiteColor], UITextAttributeTextColor, nil]];
}

#define SHOW_ALL 0

- (void)invalidateItemsForOrientation:(UIInterfaceOrientation)interfaceOrientation changeMode:(BOOL)changeMode {
	CGFloat scrollViewWidth = 0.0;
	if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {			
		scrollViewWidth = 768.0f;
	} else {
		scrollViewWidth = 1024.0f;
	}
	
	NSArray *subscriptions = [self.fetchedResultsControllerForSubscription fetchedObjects];
	NSArray *cateogries = [self.fetchedResultsControllerForCategory fetchedObjects];
	
	NSUInteger chipCount = [subscriptions count] + [cateogries count];
#if SHOW_ALL
	if (chipCount > 0) {
		chipCount++;
	}
#endif
	
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
#if SHOW_ALL
	if (chipCount > 0) {
		// all
		UINavigationController *exist = [self.childs objectForKey:@"ALL"];
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
			
			[self customizeInnerNavigationBar:navigationController.navigationBar];
			
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
#endif
	int tag = 3;
	for (Subscription *subscription in subscriptions) {
		UINavigationController *exist = [self.childs objectForKey:subscription.keyId];
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
			navigationController.view.tag = ++tag;
			
			[self customizeInnerNavigationBar:navigationController.navigationBar];
			
			//[self.childs setValue:navigationController forKey:subscription.keyId];
			
			[self addChildViewController:navigationController];
			[self.scrollView addSubview:navigationController.view];
		}			
		
		
		
		[self.childs removeObjectForKey:subscription.keyId];
		[newChilds setValue:navigationController forKey:subscription.keyId];
		
		navigationController.view.frame = CGRectMake(nextOrigin.x, nextOrigin.y, viewControllerSize.width, viewControllerSize.height);
		
		if ([navigationController.view superview] == nil) {
			[self.scrollView addSubview:navigationController.view];
		}
		
		[self addShadow:navigationController.view.layer];
		
		nextOrigin = [self nextOrigin:nextOrigin padding:(CGFloat)paddingInt scrollViewWidth:scrollViewWidth];
	}
	
	for (Category *category in cateogries) {
		UINavigationController *exist = [self.childs objectForKey:category.keyId];
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
			
			[self customizeInnerNavigationBar:navigationController.navigationBar];
			
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
			UINavigationController *exist = [self.childs objectForKey:key];
			if (exist) {
				[exist removeFromParentViewController];
				[exist.view removeFromSuperview];
			}
		}
	}
	
	self.childs = newChilds;
	
	if (chipCount > 0) {
		self.messageLabel.text = @"";
	}
	else {
		if (self.currentSegment == 1) {
			self.messageLabel.text = NSLocalizedString(@"No starred items", nil);
		}
		else {
			self.messageLabel.text = NSLocalizedString(@"No unread items", nil);
		}
	}
	
	[self refreshUnreadCount];
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
		
		UINavigationController *exist = [self.childs objectForKey:key];
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
	
	self.navigationController.navigationBar.clipsToBounds = NO;
	[self addShadowRightAngle:self.navigationController.navigationBar.layer];
	
	[self navbarImageChangeForOrientation:self.interfaceOrientation];
	
	[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"wood"]]];

	[self.segmentView addSubview:self.segmentControl];
	
	CGSize shadowOffset = CGSizeMake(0, 1.0f/[[UIScreen mainScreen] scale]);
	
	UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
	nextButton.frame = CGRectMake(0, 0, 60, 30);
	[nextButton setImage:[UIImage imageNamed:@"feedsNext_Portrait"] forState:UIControlStateNormal];
	nextButton.showsTouchWhenHighlighted = YES;
	[nextButton addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *nextItem = [[UIBarButtonItem alloc] initWithCustomView:nextButton];
	
	self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 40)];
	self.statusLabel.textColor = [UIColor colorWithRed:63.0f/255.0f green:23.0f/255.0f blue:0 alpha:1];
	self.statusLabel.shadowColor = [UIColor whiteColor];
	self.statusLabel.shadowOffset = shadowOffset;
	self.statusLabel.font = [UIFont boldSystemFontOfSize:16.0];
	self.statusLabel.backgroundColor = [UIColor clearColor];
	UIBarButtonItem *newDescItem = [[UIBarButtonItem alloc] initWithCustomView:self.statusLabel];
	
	//self.navigationItem.leftBarButtonItem = nextItem;
	self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:nextItem, newDescItem, nil];
	
	self.updateLabel.shadowOffset = shadowOffset;
	self.messageLabel.shadowOffset = shadowOffset;
	
	[self showUpdateStatus];
	[self refreshUnreadCount];

	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	[self.navigationItem.rightBarButtonItem setTintColor:[UIColor colorWithRed:63.0f/255.0f green:23.0f/255.0f blue:0 alpha:1]];
	[self invalidateEditButton];
	
	CGRect contentFrame = self.view.bounds;
	contentFrame.size.height -= 50.0f;
	self.scrollView = [[UIScrollView alloc] initWithFrame:contentFrame];
	self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:self.scrollView];
}

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
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Feed" inManagedObjectContext:self.managedObjectContext];
		[fetchRequest setEntity:entity];
		
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"unread = 1"];
		[fetchRequest setPredicate:predicate];
		
		BOOL ascending = [[NSUserDefaults standardUserDefaults] boolForKey:DEFAULT_KEY_SORT_DATE];
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"updatedDate" ascending:ascending];
		NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
		[fetchRequest setSortDescriptors:sortDescriptors];
		
		NSArray *feeds = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
		
		if ([feeds count] > 0) {
			NewFeedsViewController *feedsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NewFeedsViewController"];
			feedsViewController.feeds = feeds;
			//feedsViewController.delegate = self;
			feedsViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
			[self presentViewController:feedsViewController animated:YES completion:nil];
		}
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

- (void)changeModeByAlternativeWay:(UIBarButtonItem *)barButtonItem {
	if ([self.actionSheet isVisible]) {
		[self.actionSheet dismissWithClickedButtonIndex:self.actionSheet.cancelButtonIndex animated:YES];
	} else {
		self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
										 destructiveButtonTitle:nil 
											  otherButtonTitles:[TopViewController modeNameForSegment:0], [TopViewController modeNameForSegment:1], [TopViewController modeNameForSegment:2], nil];
		self.actionSheet.tag = TAG_ACTIONSHEET_CHANGEMODE;
		[self.actionSheet showFromBarButtonItem:barButtonItem animated:YES];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self navbarImageChangeForOrientation:self.interfaceOrientation];
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
			//self.selectedFeedsViewController = (FeedsViewController *)nestedViewController;
			
			UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
			button.tag = navigationController.view.tag + CLOSE_BUTTON_TAG;
			button.contentMode = UIViewContentModeTopLeft;
			[button setImage:[UIImage imageNamed:@"closebox"] forState:UIControlStateNormal];
			[button setImage:[UIImage imageNamed:@"closebox_pressed"] forState:UIControlStateHighlighted];
			button.frame = CGRectMake(0, 0, 44, 44);
			//button.center = viewController.view.bounds.origin;
			[button addTarget:self action:@selector(unsubscribe:) forControlEvents:UIControlEventTouchUpInside];
			[viewController.view addSubview:button];
		}
		
	}
	
}

- (void)unsubscribe:(id)sender {
	if ([self.actionSheet isVisible]) {
		[self.actionSheet dismissWithClickedButtonIndex:self.actionSheet.cancelButtonIndex animated:YES];
	}
	else {
		for (UIViewController *viewController in self.childViewControllers) {			
			if (viewController.view.tag == [sender tag] - CLOSE_BUTTON_TAG) {
				UINavigationController *navigationController = (UINavigationController *)viewController;
				UIViewController *nestedViewController = navigationController.visibleViewController;
				self.selectedFeedsViewController = (FeedsViewController *)nestedViewController;
				break;
			}
		}
		
		self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Unsubscribe", nil) otherButtonTitles:nil];
		self.actionSheet.tag = TAG_ACTUINSHEET_UNSUBSCRIBE;
		[self.actionSheet showFromRect:[sender bounds] inView:sender animated:YES];
	}
	
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.cancelButtonIndex) {
		return;
	}
	
	if (actionSheet.tag == TAG_ACTUINSHEET_UNSUBSCRIBE) {
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
	else if (actionSheet.tag == TAG_ACTIONSHEET_CHANGEMODE) {
		self.currentSegment = buttonIndex - actionSheet.firstOtherButtonIndex;
		
		[self.navigationItem.rightBarButtonItem setTitle:[self currentModeName]];
	}
	
}

- (void)removeCloseButton:(UIViewController *)viewController {
	UIView *buttonView = [viewController.view viewWithTag:viewController.view.tag + CLOSE_BUTTON_TAG];
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
				//[viewController.view startWiggling];
				[self addCloseButton:viewController];
			} else {
				//[viewController.view stopWiggling];
				[self removeCloseButton:viewController];
			}
			
		}
	}
}

- (void)viewDidUnload
{
	[self setSegmentView:nil];
	[self setUpdateLabel:nil];
    [self setMessageLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)navbarImageChangeForOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
		[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"SyndiNav-Portrait~ipad"] forBarMetrics:UIBarMetricsDefault];
	} else {
		[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"SyndiNav-Landscape~ipad"] forBarMetrics:UIBarMetricsDefault];
	}
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	
	[UIView animateWithDuration:duration 
					 animations:^{
						 [self invalidateItemsForOrientation:toInterfaceOrientation];
						 
						 [self navbarImageChangeForOrientation:toInterfaceOrientation];
					 }
					 completion:^(BOOL finished){
						 [self addShadowRightAngle:self.navigationController.navigationBar.layer];
					 }];
}

- (IBAction)changeMode:(id)sender {
	self.editing = NO;
	
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
	NSInteger segment = [segmentedControl selectedSegmentIndex];
	self.currentSegment = segment;
}

- (IBAction)subscribe:(id)sender {
	SearchViewController *viewController = [IPHONE_STORYBOARD instantiateViewControllerWithIdentifier:@"SearchViewController"];
	viewController.mode = SearchViewControllerModeSubscription;
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
	UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
	self.popover = popoverController;
	[popoverController presentPopoverFromRect:[sender bounds] inView:sender permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}

- (IBAction)search:(id)sender {
	SearchViewController *viewController = [IPHONE_STORYBOARD instantiateViewControllerWithIdentifier:@"SearchViewController"];
	viewController.mode = SearchViewControllerModeSearch;
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
	UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
	self.popover = popoverController;
	[popoverController presentPopoverFromRect:[sender bounds] inView:sender permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}

- (IBAction)setting:(id)sender {
	SettingsViewController *viewController = [IPHONE_STORYBOARD instantiateViewControllerWithIdentifier:@"SettingsViewController"];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentViewController:navigationController animated:YES completion:nil];
	
}

- (void)setCurrentSegment:(NSInteger)segment {
	if (_currentSegment != segment) {
		_currentSegment = segment;
		
		self.fetchedResultsControllerForCategory = nil;
		self.fetchedResultsControllerForSubscription = nil;
		
		// Reload Interface	
		[self invalidateItemsForOrientation:self.interfaceOrientation changeMode:YES];
		
		[self invalidateEditButton];
	}
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

#pragma mark - 

- (void)notifyUpdating {
	self.updateLabel.text = NSLocalizedString(@"Updating...", nil);
//	[self.spinner startAnimating];
}

- (void)notifyUpdateDone {
	[self showUpdateStatus];
	[self refreshUnreadCount];
//	[self.spinner stopAnimating];
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
