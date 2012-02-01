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

#import <iAd/ADBannerView.h>
#import "GADBannerView.h"

@class Category;
@class Subscription;

@interface FeedsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UIActionSheetDelegate, FeedViewControllerDelegate, ADBannerViewDelegate, GADBannerViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (assign, nonatomic) NSInteger currentSegment;
@property (strong, nonatomic) Category *category;
@property (strong, nonatomic) Subscription *subscription;

@property (assign, nonatomic) BOOL sortDateAscending;

@property (strong, nonatomic) UIActionSheet *actionSheet;

- (void)unsubscribe;

// for ad
@property (strong, nonatomic) ADBannerView *adView;
@property (strong, nonatomic) GADBannerView *gadView;
@property (assign, nonatomic) BOOL gadBannerLoaded;

@end
