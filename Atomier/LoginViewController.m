//
//  ViewController.m
//  Atomier
//
//  Created by Choi Jaeyoung on 12/16/11.
//  Copyright (c) 2011 Appcid. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "SSKeychain.h"

#define NOTIFICATION_KEYBOARD_DID_IMPLEMENTATION 0

@implementation LoginViewController

@synthesize delegate = _delegate;

@synthesize emailField;
@synthesize passwordField;
@synthesize spinner;
@synthesize alertField;
@synthesize descriptionLabel;
@synthesize backgroundImageView;
@synthesize signInButton;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	self.alertField.text = NSLocalizedString(@"Invalid Login Info", nil);
	
	NSString *savedID = [SSKeychain passwordForService:kKEYCHAIN_SERVICE account:kKEYCHAIN_ACCOUNT_ID];
	if (savedID) {
		self.emailField.text = savedID;
	}
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		self.backgroundImageView.image = [UIImage imageNamed:@"syndi-login~ipad"];
	} else {
		self.backgroundImageView.image = [UIImage imageNamed:@"syndi_login"];
	}
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
	    self.emailField.frame =			CGRectMake(110, 357, 320, 31);
		self.passwordField.frame =		CGRectMake(110, 405, 320, 31);
		self.descriptionLabel.frame =	CGRectMake(110, 300, 320, 30);
		self.alertField.frame =			CGRectMake(110, 255, 320, 40);
		self.spinner.center =			CGPointMake(270, 240);
		self.signInButton.frame =		CGRectMake(100, 465, 340, 44);
	}
	
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	
	[notificationCenter addObserver:self
						   selector:@selector(keyboardWillShow:)
							   name:UIKeyboardWillShowNotification
							 object:nil];
	
	[notificationCenter addObserver:self
						   selector:@selector(keyboardWillHide:)
							   name:UIKeyboardWillHideNotification
							 object:nil];
	
	
	
#if NOTIFICATION_KEYBOARD_DID_IMPLEMENTATION
	[notificationCenter addObserver:self
						   selector:@selector(keyboardDidShow:)
							   name:UIKeyboardDidShowNotification
							 object:nil];
	
	[notificationCenter addObserver:self
						   selector:@selector(keyboardDidHide:)
							   name:UIKeyboardDidHideNotification
							 object:nil];
#endif
	
	[notificationCenter addObserver:self
						   selector:@selector(loginSuccess:)
							   name:kNOTIFICATION_LOGIN_SUCCESS
							 object:nil];
	
	[notificationCenter addObserver:self
						   selector:@selector(loginFailed:)
							   name:kNOTIFICATION_LOGIN_FAILED
							 object:nil];
}

- (void)viewDidUnload
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self setEmailField:nil];
	[self setPasswordField:nil];
	[self setSpinner:nil];
	[self setAlertField:nil];
	[self setDescriptionLabel:nil];
	[self setBackgroundImageView:nil];
	[self setSignInButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
	    
	} else {
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
	    
	} else {
		[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
	}
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}
	return YES;
}

#pragma mark - Login

- (NSString *)email {
	return [self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString *)password {
	return [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (IBAction)login:(id)sender {
	
	NSUInteger emailLength = [[self email] length];
	NSUInteger passwordLength = [[self password] length];
	if (emailLength > 0 && passwordLength > 0) {
		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		if ([appDelegate isConnectedToNetwork]) {
			[appDelegate requestSessionWithEmail:[self email] password:[self password]];
			
			[self.spinner startAnimating];
		} else {
			[appDelegate showNoInternet];
		}
	}
}

- (void)loginSuccess:(NSNotification *)notification {
	[SSKeychain setPassword:[self email] forService:kKEYCHAIN_SERVICE account:kKEYCHAIN_ACCOUNT_ID];
	[SSKeychain setPassword:[self password] forService:kKEYCHAIN_SERVICE account:kKEYCHAIN_ACCOUNT_PASSWORD];
	
	[self.spinner stopAnimating];
	
	if (_delegate && [_delegate respondsToSelector:@selector(loginViewControllerDidDismiss)]) {
		[_delegate loginViewControllerDidDismiss];
	}
}

- (void)loginFailed:(NSNotification *)notification {
	NSLog(@"loginView - failed : %@", notification.userInfo);
	
	[self.spinner stopAnimating];
	
	NSString *message = NSLocalizedString(@"SignInFailedGeneral", nil);
    
    if ([notification.userInfo isKindOfClass:[NSDictionary class]]) {
        
        NSString *staticMessage = [notification.userInfo objectForKey:@"StaticMessage"];
        if (staticMessage) {
            if (![staticMessage isEqualToString:@"Unknown"]) {
                message = staticMessage;
            }            
        } else {
            NSString *errorCode = [notification.userInfo objectForKey:@"Error"];
            if ([errorCode isEqualToString:@"BadAuthentication"]) {
                NSString *errorInfo = [notification.userInfo objectForKey:@"Info"];
                if ([errorInfo isEqualToString:@"InvalidSecondFactor"]) {
                    // 2-step error
                    message = NSLocalizedString(@"SignInFailed2Step", nil);
                }
                else {
                    // typical error
                    message = NSLocalizedString(@"BadAuthentication", nil);
                }
            }
            else if ([errorCode isEqualToString:@"NotVerified"]) {
                message = NSLocalizedString(@"NotVerified", nil);
            }
            else if ([errorCode isEqualToString:@"TermsNotAgreed"]) {
                message = NSLocalizedString(@"TermsNotAgreed", nil);
            }
            else if ([errorCode isEqualToString:@"CaptchaRequired"]) {
                message = NSLocalizedString(@"CaptchaRequired", nil);
            }
            else if ([errorCode isEqualToString:@"Unknown"]) {
                message = NSLocalizedString(@"Unknown", nil);
            }
            else if ([errorCode isEqualToString:@"AccountDeleted"]) {
                message = NSLocalizedString(@"AccountDeleted", nil);
            }
            else if ([errorCode isEqualToString:@"AccountDisabled"]) {
                message = NSLocalizedString(@"AccountDisabled", nil);
            }
            else if ([errorCode isEqualToString:@"ServiceDisabled"]) {
                message = NSLocalizedString(@"ServiceDisabled", nil);
            }
            else if ([errorCode isEqualToString:@"ServiceUnavailable"]) {
                message = NSLocalizedString(@"ServiceUnavailable", nil);
            }
        }
    }
	
	self.alertField.text = message;
	[self.alertField setHidden:NO];
	
	//self.emailField.text = @"";
	self.passwordField.text = @"";
	
	[self.passwordField becomeFirstResponder];
}

#pragma mark - UITextField Delegate

// return NO to disallow editing.
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	return YES;
}

// became first responder
- (void)textFieldDidBeginEditing:(UITextField *)textField {
	
}

// return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	return YES;
}

// may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
- (void)textFieldDidEndEditing:(UITextField *)textField {
	
}

// return NO to not change text
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	return YES;
}

// called when clear button pressed. return NO to ignore (no notifications)
- (BOOL)textFieldShouldClear:(UITextField *)textField {
	return YES;
}

// called when 'return' key pressed. return NO to ignore.
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == self.emailField) {
		// password field 로 이동
		[self.passwordField becomeFirstResponder];
	}
	else if (textField == self.passwordField) {
		// 로그인 시도
		if ([[self email] length] == 0) {
			[self.emailField becomeFirstResponder];
			return NO;
		}
		
		if ([[self password] length] == 0) {
			return NO;
		}
		
		[self login:nil];
	}
	
	return YES;
}

#pragma mark - Keyboard behavior

- (void)keyboardWillShow:(NSNotification *)notification {
	//NSLog(@"keyboardWillShow: %@", [notification userInfo]);
	
	NSDictionary* info = [notification userInfo];
	CGRect endFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
	    endFrame = [self.view.window convertRect:endFrame toView:self.view];
		//NSLog(@"my end frame: %@", NSStringFromCGRect(endFrame));
	}
	
	CGRect newViewFrame = [self.view frame];
	CGFloat keyboardAfterTop = endFrame.origin.y;
	CGFloat passwordFieldBottom = self.passwordField.frame.origin.y + self.passwordField.frame.size.height + 20.0f;
	if (keyboardAfterTop < passwordFieldBottom) {
		newViewFrame.origin.y = keyboardAfterTop - passwordFieldBottom;
		
		UIView *mainView = self.view;
		[UIView animateWithDuration:duration animations:^{
			mainView.frame = newViewFrame;
		}];
	}
	
	
}

- (void)keyboardWillHide:(NSNotification *)notification {
	//NSLog(@"keyboardWillHide: %@", [notification userInfo]);
	
	NSDictionary* info = [notification userInfo];
	CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
	
	CGRect newViewFrame = [self.view bounds];
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
	    newViewFrame.origin.y = 0;
	} else {
	    newViewFrame.origin.y = 20;
	}
	
	
	UIView *mainView = self.view;
	[UIView animateWithDuration:duration animations:^{
		mainView.frame = newViewFrame;
	}];
}

#if NOTIFICATION_KEYBOARD_DID_IMPLEMENTATION

- (void)keyboardDidShow:(NSNotification *)notification {
	NSLog(@"keyboardDidShow: %@", [notification userInfo]);
}

- (void)keyboardDidHide:(NSNotification *)notification {
	NSLog(@"keyboardDidHide: %@", [notification userInfo]);
}

#endif

#pragma mark - Touch

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if ([self.emailField isFirstResponder]) {
		[self.emailField resignFirstResponder];
	}
	else if ([self.passwordField isFirstResponder]) {
		[self.passwordField resignFirstResponder];
	}
}

@end
