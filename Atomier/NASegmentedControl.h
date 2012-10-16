//
//  NASegmentedControl.h
//  SpeedText
//
//  Created by Jaeyoung Choi on 10. 7. 18..
//  Copyright 2010 NeoApps, Felaur. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NASegmentedControl : UIControl {
	int m_nSelectedSegmentIndex;
	NSMutableArray *m_pSelectedImages;
	NSMutableArray *m_pSelectedBackgroundImage;
}

@property (nonatomic, assign) int selectedSegmentIndex;

- (id)initWithButtons:(NSArray *)buttons;
- (id)initWithButtons:(NSArray *)buttons seperatorImage:(UIImage *)seperatorImage;
- (void)refreshStateImage;

@end
