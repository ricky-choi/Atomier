//
//  SettingsViewController.h
//  Atomier
//
//  Created by Choi Jaeyoung on 1/5/12.
//  Copyright (c) 2012 Appcid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@protocol SettingsViewControllerDelegate <NSObject>

- (void)purchaseAdFreeDone;

@end

@interface SettingsViewController : UITableViewController <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (weak, nonatomic) id <SettingsViewControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UISwitch *badgeSwitch;
@property (assign, nonatomic) BOOL sortDateAscending;
@property (assign, nonatomic) BOOL readyPurchase;
@property (strong, nonatomic) NSArray *productsToSell;
@property (strong, nonatomic) NSString *productPrice;

- (IBAction)signout:(id)sender;
- (IBAction)toggleSwitch:(id)sender;

@end
