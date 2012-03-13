//
//  NewFeedsViewController.h
//  Atomier
//
//  Created by Choi Jaeyoung on 12. 3. 13..
//  Copyright (c) 2012년 Appcid. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewFeedsViewController;

@protocol NewFeedsViewControllerDelegate <NSObject>

- (void)feedsViewControllerWillDismiss:(NewFeedsViewController *)viewController;

@end

@interface NewFeedsViewController : UIViewController < UIScrollViewDelegate >

@property (weak, nonatomic) id <NewFeedsViewControllerDelegate> delegate;

@property (strong, nonatomic) NSArray *feeds;
@property (strong, nonatomic) NSMutableArray *pages;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIImageView *topImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bottomImageView;
@property (weak, nonatomic) IBOutlet UILabel *pageLabel;

- (IBAction)goHome:(id)sender;
- (IBAction)goNext:(id)sender;
- (IBAction)goPrevious:(id)sender;

- (void)refreshPageLabel;

@end
