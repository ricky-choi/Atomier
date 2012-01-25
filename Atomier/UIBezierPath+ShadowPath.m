//
//  UIBezierPath+ShadowPath.m
//  ShadowBoxing
//
//  Created by Joe Ricioppo on 4/6/10.
//  BDS licence booyaa
//

#import "UIBezierPath+ShadowPath.h"

static const CGFloat yoffset = 10.0;
static const CGFloat xoffset = 2.0;
static const CGFloat curve = 5.0;

@implementation UIBezierPath (ShadowPath)

+ (UIBezierPath*)bezierPathWithCurvedShadowForRect:(CGRect)rect {

	UIBezierPath *path = [UIBezierPath bezierPath];	
	
	CGPoint topLeft		 = rect.origin;
	CGPoint bottomLeft	 = CGPointMake(-xoffset, CGRectGetHeight(rect)+yoffset);
	CGPoint bottomMiddle = CGPointMake(CGRectGetWidth(rect)/2, CGRectGetHeight(rect)-curve);	
	CGPoint bottomRight	 = CGPointMake(CGRectGetWidth(rect)+xoffset, CGRectGetHeight(rect)+yoffset);
	CGPoint topRight	 = CGPointMake(CGRectGetWidth(rect)+xoffset, 0.0);
	
	[path moveToPoint:topLeft];	
	[path addLineToPoint:bottomLeft];
	[path addQuadCurveToPoint:bottomRight
				 controlPoint:bottomMiddle];
	[path addLineToPoint:topRight];
	[path addLineToPoint:topLeft];
	[path closePath];
	
	return path;
}

@end
