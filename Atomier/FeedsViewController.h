//
//  FeedsViewController.h
//  Atomier
//
//  Created by Choi Jaeyoung on 12/19/11.
//  Copyright (c) 2011 Appcid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "FeedViewController.h"
#import "NewFeedsViewController.h"

@class Category;
@class Subscription;

@interface FeedsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UIActionSheetDelegate, FeedViewControllerDelegate, NewFeedsViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (assign, nonatomic) NSInteger currentSegment;
@property (strong, nonatomic) Category *category;
@property (strong, nonatomic) Subscription *subscription;

@property (assign, nonatomic) BOOL sortDateAscending;

@property (strong, nonatomic) UIActionSheet *actionSheet;

@property (strong, nonatomic) NSArray *toolbarItemsPortrait;
@property (strong, nonatomic) NSArray *toolbarItemsLandscape;

- (void)unsubscribe;

@end
