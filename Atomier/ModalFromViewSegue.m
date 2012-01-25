//
//  ModalFromViewSegue.m
//  Atomier
//
//  Created by Choi Jaeyoung on 1/6/12.
//  Copyright (c) 2012 Appcid. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ModalFromViewSegue.h"

@implementation ModalFromViewSegue

- (void)perform
{
#if 1
	[self.sourceViewController presentViewController:self.destinationViewController animated:YES completion:nil]; 
#else
	UIViewController *source = self.sourceViewController; 
	UIViewController *destination = self.destinationViewController;
	
	UIApplication *app = [UIApplication sharedApplication];
	if (UIInterfaceOrientationIsLandscape(app.statusBarOrientation)) {
		destination.view.bounds = CGRectMake(0, 0, destination.view.bounds.size.height, destination.view.bounds.size.width);
	}
	
	// Create a UIImage with the contents of the destination
	UIGraphicsBeginImageContext(destination.view.bounds.size); 
	
	[destination.view.layer renderInContext:UIGraphicsGetCurrentContext()]; 
	UIImage *destinationImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	UIWindow *window = source.view.window;
	UIView *rootView = window.rootViewController.view;
	
	// Add this image as a subview to the tab bar controller
	UIImageView *destinationImageView = [[UIImageView alloc] initWithImage:destinationImage];
	[rootView addSubview: destinationImageView];
	
	CGRect oldRect = [source.view convertRect:source.view.frame toView:rootView]; //source.view.frame;
	CGRect newRect = destinationImageView.frame;
	
	destinationImageView.frame = oldRect;
	
	// Scale the image down and rotate it 180 degrees (upside down)
//	CGAffineTransform scaleTransform = CGAffineTransformMakeScale(0.1, 0.1);
//	CGAffineTransform rotateTransform = CGAffineTransformMakeRotation(M_PI);
//	destinationImageView.transform = CGAffineTransformConcat(scaleTransform, rotateTransform);
//	// Move the image outside the visible area
//	CGPoint oldCenter = destinationImageView.center; 
//	CGPoint newCenter = CGPointMake(oldCenter.x - destinationImageView.bounds.size.width, oldCenter.y); 
//	destinationImageView.center = newCenter;
	
	// Start the animation
	[UIView animateWithDuration:0.25
						  delay:0 
						options:UIViewAnimationOptionCurveEaseOut
					 animations:^(void){
						 destinationImageView.frame = newRect;
					 }
					 completion:^(BOOL done){
						 [destinationImageView removeFromSuperview];
						 // Properly present the new screen
						 [source presentViewController:destination animated:NO completion:nil];
					 }];
#endif
}

@end
