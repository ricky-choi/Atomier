//
//  SettingsViewController.m
//  Atomier
//
//  Created by Choi Jaeyoung on 1/5/12.
//  Copyright (c) 2012 Appcid. All rights reserved.
//

#import "SettingsViewController.h"
#import "AppDelegate.h"

@implementation SettingsViewController
@synthesize badgeSwitch;

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

	int rule = [self currentRule];
	NSIndexPath *ruleIndexPath = [NSIndexPath indexPathForRow:rule inSection:1];
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:ruleIndexPath];
	cell.accessoryType = UITableViewCellAccessoryCheckmark;
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

@end
