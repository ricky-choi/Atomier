//
//  CoverViewController.h
//  Atomier
//
//  Created by Choi Jaeyoung on 12. 3. 1..
//  Copyright (c) 2012년 Appcid. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NASegmentedControl;

@interface CoverViewController : UIViewController

@property (strong, nonatomic) NASegmentedControl *segmentControlPortrait;

@property (weak, nonatomic) IBOutlet UILabel *updateLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

- (IBAction)next:(id)sender;
- (IBAction)refresh:(id)sender;

- (void)notifyUpdating;
- (void)notifyUpdateDone;
- (void)refreshUnreadCount;

@end
