//
//  SignInViewController.m
//  GitHubToGo
//
//  Created by Daniel Fairbanks on 4/23/14.
//  Copyright (c) 2014 Fairbanksdan. All rights reserved.
//

#import "SignInViewController.h"
#import "AppDelegate.h"
#import "NetworkController.h"

@interface SignInViewController ()

@property (weak, nonatomic) AppDelegate *appdelegate;
@property (weak, nonatomic) NetworkController *networkController;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *GitHubLogoVerticalContraint;

@end

@implementation SignInViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.appdelegate = [UIApplication sharedApplication].delegate;
    self.networkController = self.appdelegate.networkController;
    
    if ([self.networkController checkForToken]) {
        [self performSegueWithIdentifier:@"GoToRoot" sender:self];
    }
    
    if (self.view.frame.size.height == 480.0) {
        NSLog(@"iPhone 4");
        self.GitHubLogoVerticalContraint.constant = -130.0;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (IBAction)signInButtonPressed:(UIButton *)sender
{
    [self.networkController requestOAuthAccess:self withCompletion:^{
        [self performSegueWithIdentifier:@"GoToRoot" sender:self];
    }];
}

@end
