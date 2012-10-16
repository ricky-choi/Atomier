//
//  NASegmentedControl.m
//  SpeedText
//
//  Created by Jaeyoung Choi on 10. 7. 18..
//  Copyright 2010 NeoApps, Felaur. All rights reserved.
//

#import "NASegmentedControl.h"


@implementation NASegmentedControl

@synthesize selectedSegmentIndex = m_nSelectedSegmentIndex;

- (id)initWithButtons:(NSArray *)buttons seperatorImage:(UIImage *)seperatorImage {
	if ((self = [super init])) {
		
		m_nSelectedSegmentIndex = -1;
		
		m_pSelectedImages = [[NSMutableArray alloc] initWithCapacity:[buttons count]];
		m_pSelectedBackgroundImage = [[NSMutableArray alloc] initWithCapacity:[buttons count]];
		
		CGPoint buttonLocation = CGPointZero;
		CGFloat maxHeight = 0.0;
		
		for (int tagIndex = 0; tagIndex < [buttons count]; tagIndex++) {
			UIButton *aButton = [buttons objectAtIndex:tagIndex];
			aButton.frame = CGRectMake(buttonLocation.x, 
									   buttonLocation.y, 
									   aButton.frame.size.width, 
									   aButton.frame.size.height);
			if (aButton.frame.size.height > maxHeight) {
				maxHeight = aButton.frame.size.height;
			}
			aButton.tag = tagIndex;
			[aButton addTarget:self action:@selector(selectButton:) forControlEvents:UIControlEventTouchDown];
			[self addSubview:aButton];
			
			// 디폴트 이미지를 저장해둔다.
			UIImage *buttonImage = [aButton imageForState:UIControlStateNormal];
			UIImage *buttonBackgroundImage = [aButton backgroundImageForState:UIControlStateNormal];
			[m_pSelectedImages addObject:buttonImage ? buttonImage : [NSNull null]];
			[m_pSelectedBackgroundImage addObject:buttonBackgroundImage ? buttonBackgroundImage : [NSNull null]];
			
			buttonLocation.x = buttonLocation.x + aButton.frame.size.width;
			
			if (seperatorImage && tagIndex < [buttons count] - 1) {
				UIImageView *seperatorImageView = [[UIImageView alloc] initWithImage:seperatorImage];
				seperatorImageView.tag = 100;
				seperatorImageView.frame = CGRectMake(buttonLocation.x, 0, seperatorImageView.frame.size.width, seperatorImageView.frame.size.height);
				[self addSubview:seperatorImageView];
				[seperatorImageView release];
				
				buttonLocation.x = buttonLocation.x + seperatorImageView.frame.size.width;
			}			
		}
		
		self.frame = CGRectMake(0, 0, buttonLocation.x, maxHeight);
		
		[self refreshStateImage];
		
	}
	
	return self;
}

- (id)initWithButtons:(NSArray *)buttons {
	return [self initWithButtons:buttons seperatorImage:nil];
}

- (void)setSelectedSegmentIndex:(int)newValue {
	if (m_nSelectedSegmentIndex != newValue) {
		m_nSelectedSegmentIndex = newValue;
		[self refreshStateImage];
	}
}

- (void)selectButton:(UIButton *)selectedButton {
	if (m_nSelectedSegmentIndex != selectedButton.tag) {
		m_nSelectedSegmentIndex = selectedButton.tag;
		[self sendActionsForControlEvents:UIControlEventValueChanged];
		[self refreshStateImage];
	}
}

- (void)refreshStateImage {
	for (UIView *aButton in [self subviews]) {
		if (aButton.tag < 100) {
			if (aButton.tag == self.selectedSegmentIndex) {
				[(UIButton *)aButton setImage:[(UIButton *)aButton imageForState:UIControlStateHighlighted] forState:UIControlStateNormal];
				[(UIButton *)aButton setBackgroundImage:[(UIButton *)aButton backgroundImageForState:UIControlStateHighlighted] forState:UIControlStateNormal];
			}
			else {
				id selectedImage = [m_pSelectedImages objectAtIndex:aButton.tag];
				if (![selectedImage isKindOfClass:[UIImage class]]) {
					selectedImage = nil;
				}
				[(UIButton *)aButton setImage:selectedImage forState:UIControlStateNormal];
				
				id selectedBackgroundImage = [m_pSelectedBackgroundImage objectAtIndex:aButton.tag];
				if (![selectedBackgroundImage isKindOfClass:[UIImage class]]) {
					selectedBackgroundImage = nil;
				}
				[(UIButton *)aButton setBackgroundImage:selectedBackgroundImage forState:UIControlStateNormal];
			}
		}
	}
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (void)dealloc {
	[m_pSelectedImages release];
	[m_pSelectedBackgroundImage release];
    [super dealloc];
}

@end
