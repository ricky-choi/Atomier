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

#import <iAd/ADBannerView.h>
#import "GADBannerView.h"

@class Category;

@interface TopViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, PreviewFeedDelegate, UIActionSheetDelegate, ADBannerViewDelegate, GADBannerViewDelegate, SettingsViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsControllerForCategory;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsControllerForSubscription;
@property (assign, nonatomic) NSInteger currentSegment;
@property (strong, nonatomic) PreviewFeed *previewFeed;
@property (strong, nonatomic) PreviewFeed *tempPreviewFeed;

@property (strong, nonatomic) Category *category;

- (IBAction)refresh:(id)sender;
- (IBAction)changeMode:(id)sender;

+ (NSString *)modeNameForSegment:(NSUInteger)segment;

// for ad
@property (strong, nonatomic) ADBannerView *adView;
@property (strong, nonatomic) GADBannerView *gadView;
@property (assign, nonatomic) BOOL gadBannerLoaded;

@end
