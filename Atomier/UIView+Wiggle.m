//
//  UIView+Wiggle.m
//  Atomier
//
//  Created by Choi Jaeyoung on 12/31/11.
//  Copyright (c) 2011 Appcid. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIView+Wiggle.h"

@implementation UIView (Wiggle)

- (void)startWiggling {
	
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    anim.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:-0.02],//0.05
				   [NSNumber numberWithFloat:0.02],
				   nil];
    anim.duration = 0.09f + ((self.tag % 10) * 0.01f);
    anim.autoreverses = YES;
    anim.repeatCount = HUGE_VALF;
    [self.layer addAnimation:anim forKey:@"wiggleRotation"];
    
    anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
    anim.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:-1],
                   [NSNumber numberWithFloat:1],
                   nil];
    anim.duration = 0.07f + ((self.tag % 10) * 0.01f);
    anim.autoreverses = YES;
    anim.repeatCount = HUGE_VALF;
    anim.additive = YES;
    [self.layer addAnimation:anim forKey:@"wiggleTranslationY"];
}


- (void)stopWiggling {
    [self.layer removeAnimationForKey:@"wiggleRotation"];
    [self.layer removeAnimationForKey:@"wiggleTranslationY"];
}

@end
