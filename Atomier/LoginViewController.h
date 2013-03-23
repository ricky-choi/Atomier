//
//  ViewController.h
//  Atomier
//
//  Created by Choi Jaeyoung on 12/16/11.
//  Copyright (c) 2011 Appcid. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoginViewControllerDelegate <NSObject>

- (void)loginViewControllerDidDismiss;

@end

@interface LoginViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) id <LoginViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *alertField;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *submitFormBackgroundImageView;

- (IBAction)login:(id)sender;

@end
