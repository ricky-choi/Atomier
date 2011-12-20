//
//  FeedsViewCell.h
//  Atomier
//
//  Created by Choi Jaeyoung on 12/19/11.
//  Copyright (c) 2011 Appcid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedsViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *iconImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet UILabel *subtitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;

@end
