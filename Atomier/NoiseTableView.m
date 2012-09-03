//
//  NoiseTableView.m
//  Atomier
//
//  Created by Choi Jaeyoung on 12. 3. 4..
//  Copyright (c) 2012년 Appcid. All rights reserved.
//

#import "NoiseTableView.h"

@implementation NoiseTableView

- (void)awakeFromNib {
	self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"whitenoise"]]; 
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
