//
//  SearchViewController.h
//  Atomier
//
//  Created by Choi Jaeyoung on 12. 3. 5..
//  Copyright (c) 2012년 Appcid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogleReader.h"

typedef enum {
	SearchViewControllerModeSearch,
	SearchViewControllerModeSubscription
} SearchViewControllerMode;

@class ATMHud;

@interface SearchViewController : UIViewController <GoogleReaderSubscribeDelegate>

@property (assign, nonatomic) SearchViewControllerMode mode;

@property (strong, nonatomic) NSArray *searchResults;
@property (strong, nonatomic) NSArray *recommendeds;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (assign, nonatomic) int hasnextpage;
@property (assign, nonatomic) int nextpagestart;
@property (strong, nonatomic) NSMutableArray *keywordSearchResults;

@property (strong, nonatomic) ATMHud *hud;

- (IBAction)done:(id)sender;

@end
