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

@interface TopViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, PreviewFeedDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsControllerForCategory;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsControllerForSubscription;
@property (assign, nonatomic) NSInteger currentSegment;
@property (strong, nonatomic) NSString *currentCacheNameForCategory;
@property (strong, nonatomic) NSString *currentCacheNameForSubscription;
@property (strong, nonatomic) PreviewFeed *previewFeed;
@property (strong, nonatomic) PreviewFeed *tempPreviewFeed;

- (IBAction)refresh:(id)sender;
- (IBAction)changeMode:(id)sender;

@end
