//
//  SettingsViewController.h
//  Atomier
//
//  Created by Choi Jaeyoung on 1/5/12.
//  Copyright (c) 2012 Appcid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UISwitch *badgeSwitch;

- (IBAction)signout:(id)sender;
- (IBAction)toggleSwitch:(id)sender;

@end
