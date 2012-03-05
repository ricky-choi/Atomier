//
//  SearchViewController.h
//  Atomier
//
//  Created by Choi Jaeyoung on 12. 3. 5..
//  Copyright (c) 2012년 Appcid. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	SearchViewControllerModeSearch,
	SearchViewControllerModeSubscription
} SearchViewControllerMode;

@interface SearchViewController : UIViewController

@property (assign, nonatomic) SearchViewControllerMode mode;

@property (strong, nonatomic) NSArray *searchResults;
@property (strong, nonatomic) NSArray *recommendeds;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)done:(id)sender;

@end
