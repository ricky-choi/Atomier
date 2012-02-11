//
//  SettingsViewController.m
//  Atomier
//
//  Created by Choi Jaeyoung on 1/5/12.
//  Copyright (c) 2012 Appcid. All rights reserved.
//

#import "SettingsViewController.h"
#import "AppDelegate.h"

#define kMyFeatureIdentifier @"SyndiFree.AdFree"

@interface SettingsViewController ()

- (BOOL)showAD;
- (void)freeAd;
- (void)requestProductData;

@end

@implementation SettingsViewController

@synthesize delegate = _delegate;

@synthesize badgeSwitch = _badgeSwitch;

@synthesize readyPurchase = _readyPurchase;
@synthesize productsToSell = _productsToSell;
@synthesize productPrice = _productPrice;

- (NSString *)productPrice {
	if (_productPrice == nil && [self.productsToSell count] > 0) {
		SKProduct *product = [self.productsToSell objectAtIndex:0];
		
		NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
		[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
		[numberFormatter setLocale:product.priceLocale];
		NSString *formattedString = [numberFormatter stringFromNumber:product.price];
		
		return formattedString;
	}
	
	return _productPrice;
}

- (UISwitch *)badgeSwitch {
	if (_badgeSwitch) {
		return _badgeSwitch;
	}
	
	_badgeSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
	[_badgeSwitch addTarget:self action:@selector(toggleSwitch:) forControlEvents:UIControlEventValueChanged];
	
	return _badgeSwitch;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)dealloc {
	[[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	self.title = NSLocalizedString(@"Settings", nil);
	
	UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
	self.navigationItem.leftBarButtonItem = doneItem;
	
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	self.badgeSwitch.on = [appDelegate isBadge];

	_readyPurchase = NO;
	if ([self showAD] && [SKPaymentQueue canMakePayments] && self.productsToSell == nil) {
		[self requestProductData];
	}
}

- (void)done:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidUnload
{
	
	[self setBadgeSwitch:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (int)currentRule {
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	return [appDelegate syncRule];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

//	int rule = [self currentRule];
//	NSIndexPath *ruleIndexPath = [NSIndexPath indexPathForRow:rule inSection:1];
//	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:ruleIndexPath];
//	cell.accessoryType = UITableViewCellAccessoryCheckmark;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	}
	return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#ifdef FREE_FOR_PROMOTION
    return 4;
#endif
	return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	if (section == 0) {
		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		return [NSString stringWithFormat:NSLocalizedString(@"Account: %@", nil), [appDelegate savedGoogleID]];
	}
	else if (section == 1) {
		return NSLocalizedString(@"Sync", nil);
	}
	else if (section == 2) {
		return NSLocalizedString(@"Home Screen", nil);
	}
	else if (section == 3) {
		return NSLocalizedString(@"Upgrade", nil);
	}
	
	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if (section == 1) {
		return 3;
	}
	else if (section == 3) {
		if ([self showAD] && [SKPaymentQueue canMakePayments]) {
			return 2;
		} else {
			return 1;
		}
	}
	
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	
	cell.textLabel.textColor = [UIColor darkTextColor];
	cell.textLabel.textAlignment = UITextAlignmentLeft;
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	cell.accessoryView = nil;
	cell.imageView.image = nil;
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.detailTextLabel.text = @"";
	
	if (section == 0) {
		cell.textLabel.text = NSLocalizedString(@"Sign out", nil);
		cell.textLabel.textAlignment = UITextAlignmentCenter;
	}
	else if (section == 1) {
		if (row == 0) {
			cell.textLabel.text = NSLocalizedString(@"Automatic", nil);
		}
		else if (row == 1) {
			cell.textLabel.text = NSLocalizedString(@"Automatic if Wi-Fi", nil);
		}
		else if (row == 2) {
			cell.textLabel.text = NSLocalizedString(@"Manual", nil);
		}
		
		if (row == [self currentRule]) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		}
	}
	else if (section == 2) {
		cell.textLabel.text = NSLocalizedString(@"Show Unread Badge", nil);
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryView = self.badgeSwitch;
	}
	else if (section == 3) {
		if (row == 0) {
			cell.textLabel.text = NSLocalizedString(@"Buy Full Version", nil);
			cell.imageView.image = [UIImage imageNamed:@"promote-Icon-Small"];
		} else {
			cell.textLabel.text = NSLocalizedString(@"Remove Ad", nil);
			if (self.readyPurchase) {
				cell.textLabel.textColor = [UIColor darkTextColor];
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				cell.detailTextLabel.text = [self productPrice];
			} else {
				cell.textLabel.textColor = [UIColor lightGrayColor];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
			}
		}
	}
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.section == 0) {
		[self signout:nil];
	}
	else if (indexPath.section == 1) {
		int newRule = indexPath.row;
		if (newRule != [self currentRule]) {
			UITableViewCell *oldRuleCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self currentRule] inSection:1]];
			UITableViewCell *newRuleCell = [tableView cellForRowAtIndexPath:indexPath];
			
			oldRuleCell.accessoryType = UITableViewCellAccessoryNone;
			newRuleCell.accessoryType = UITableViewCellAccessoryCheckmark;
			
			AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
			[appDelegate setSyncRule:newRule];
		}
	}
	else if (indexPath.section == 3) {
		if (indexPath.row == 0) {
			// go appstore
			UIApplication *app = [UIApplication sharedApplication];
			NSURL *syndiAppStoreURL = [NSURL URLWithString:@"http://itunes.apple.com/us/app/syndi-rss-reader/id498935649?ls=1&mt=8"];
			if ([app canOpenURL:syndiAppStoreURL]) {
				[app openURL:syndiAppStoreURL];
			}
		}
		else if (indexPath.row == 1) {
			// remove ad : in app purchase
			if (self.readyPurchase) {
				NSLog(@"remove ad");
				[self freeAd];
			}
		}
	}
}

- (IBAction)signout:(id)sender {
	[self dismissViewControllerAnimated:YES completion:^{
		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		[appDelegate signout];
	}];
	
}

- (IBAction)toggleSwitch:(id)sender {
	UISwitch *aSwitch = (UISwitch *)sender;
	
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate setBadge:aSwitch.on];
}

#pragma mark - Remove Ad

- (void)freeAd {
	// 광고창을 영원히 보여주지 않는다.
	// 결제 모듈로 연결
	
	if ([[[SKPaymentQueue defaultQueue] transactions] count] > 0) {
		return;
	}
	
	if ([self.productsToSell count] > 0) {
		SKProduct *freeAdProduct = [self.productsToSell objectAtIndex:0];
		SKPayment *payment = [SKPayment paymentWithProduct:freeAdProduct];
		[[SKPaymentQueue defaultQueue] addPayment:payment];
	}
	
}

- (BOOL)showAD {
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	return [appDelegate showAD];
}

- (void) requestProductData
{
	NSLog(@"request products");
	
	SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers: [NSSet setWithObject: kMyFeatureIdentifier]];
	request.delegate = self;
	[request start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	NSArray *items = response.products;	// SKProduct list
    NSLog(@"purchase items: %@", items);
	if ([items count] > 0) {
		self.readyPurchase = YES;
		
		self.productsToSell = items;
		[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
		
		[self.tableView beginUpdates];
		[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:3]] withRowAnimation:UITableViewRowAnimationNone];
		[self.tableView endUpdates];		
	}
}

- (void)recordTransaction:(SKPaymentTransaction *)transaction {
	// 구매했음을 기록
	[[NSUserDefaults standardUserDefaults] setBool:NO forKey:DEFAULT_KEY_AD];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[[NSUbiquitousKeyValueStore defaultStore] setBool:NO forKey:DEFAULT_KEY_AD];
	[[NSUbiquitousKeyValueStore defaultStore] synchronize];
}

- (void)provideContent:(NSString *)identifier {
	// 구매 cell 을 삭제
	[self.tableView beginUpdates];
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationRight];
	[self.tableView endUpdates];
	
	if (_delegate && [_delegate respondsToSelector:@selector(purchaseAdFreeDone)]) {
		[_delegate purchaseAdFreeDone];
	}
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
	NSLog(@"completeTransaction");
	// Your application should implement these two methods.
    [self recordTransaction: transaction];
    [self provideContent: transaction.payment.productIdentifier];
	// Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
	NSLog(@"restoreTransaction");
    [self recordTransaction: transaction];
    [self provideContent: transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
	NSLog(@"failedTransaction");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // Optionally, display an error here.
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
			case SKPaymentTransactionStatePurchasing:
				self.navigationItem.leftBarButtonItem.enabled = NO;
				break;
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
				self.navigationItem.leftBarButtonItem.enabled = YES;
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
				self.navigationItem.leftBarButtonItem.enabled = YES;
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
				self.navigationItem.leftBarButtonItem.enabled = YES;
				break;
            default:
				self.navigationItem.leftBarButtonItem.enabled = YES;
                break;
        }
    }
}


@end
