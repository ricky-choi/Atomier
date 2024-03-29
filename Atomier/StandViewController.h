//
//  StandViewController.h
//  Atomier
//
//  Created by Choi Jaeyoung on 12/28/11.
//  Copyright (c) 2011 Appcid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "SettingsViewController.h"

@class Category;
@class FeedsViewController;
@class NASegmentedControl;

@interface StandViewController : UIViewController <NSFetchedResultsControllerDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsControllerForCategory;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsControllerForSubscription;
@property (assign, nonatomic) NSInteger currentSegment;

@property (strong, nonatomic) Category *category;

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) NSMutableDictionary *childs;
@property (assign, nonatomic) CGSize chipSize;

@property (strong, nonatomic) FeedsViewController *selectedFeedsViewController;

@property (strong, nonatomic) UIActionSheet *actionSheet;

@property (strong, nonatomic) NASegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UIView *segmentView;

@property (strong, nonatomic) UIPopoverController *popover;
@property (weak, nonatomic) IBOutlet UILabel *updateLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (strong, nonatomic) UILabel *statusLabel;

- (IBAction)refresh:(id)sender;
- (IBAction)changeMode:(id)sender;
- (IBAction)subscribe:(id)sender;
- (IBAction)search:(id)sender;
- (IBAction)setting:(id)sender;
- (IBAction)next:(id)sender;

- (void)notifyUpdating;
- (void)notifyUpdateDone;
- (void)refreshUnreadCount;

@end
