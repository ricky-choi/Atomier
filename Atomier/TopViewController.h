//
//  TopViewController.h
//  Atomier
//
//  Created by Choi Jaeyoung on 12/16/11.
//  Copyright (c) 2011 Appcid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "PreviewFeed.h"
#import "SettingsViewController.h"

@class Category;
@class NASegmentedControl;

@interface TopViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, PreviewFeedDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsControllerForCategory;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsControllerForSubscription;
@property (assign, nonatomic) NSInteger currentSegment;
@property (strong, nonatomic) PreviewFeed *previewFeed;
@property (strong, nonatomic) PreviewFeed *tempPreviewFeed;

@property (strong, nonatomic) Category *category;

@property (strong, nonatomic) NASegmentedControl *segmentControlPortrait;
@property (strong, nonatomic) NASegmentedControl *segmentControlLandscape;
@property (strong, nonatomic) NSArray *toolbarItemsPortrait;
@property (strong, nonatomic) NSArray *toolbarItemsLandscape;

- (IBAction)refresh:(id)sender;
- (IBAction)changeMode:(id)sender;

+ (NSString *)modeNameForSegment:(NSUInteger)segment;

@end
