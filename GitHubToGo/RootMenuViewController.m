//
//  RootMenuViewController.m
//  GitHubToGo
//
//  Created by Daniel Fairbanks on 4/21/14.
//  Copyright (c) 2014 Fairbanksdan. All rights reserved.
//

#import "RootMenuViewController.h"
#import "ReposViewController.h"
#import "UsersViewController.h"
#import "SearchViewController.h"

@interface RootMenuViewController () <UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate, BurgerProtocol>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *arrayOfViewControllers;
@property (strong, nonatomic) UIViewController *topViewController;
@property (strong, nonatomic) UITapGestureRecognizer *tapToClose;
@property ( nonatomic) BOOL menuIsOpen;

@end

@implementation RootMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.userInteractionEnabled = NO;
    
    [self setupDragRecognizer];
    [self setupChildrenViewControllers];
    
    self.tapToClose = [UITapGestureRecognizer new];
    
    
}

-(void)setupChildrenViewControllers
{
    ReposViewController *repoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"repos"];
    repoViewController.title = @"My Repos";
    repoViewController.burgerDelegate = self;
    UINavigationController *repoNav = [[UINavigationController alloc] initWithRootViewController:repoViewController];
    repoNav.navigationBarHidden = YES;
    
    UsersViewController *usersViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"users"];
    usersViewController.title = @"Following";
    usersViewController.burgerDelegate = self;
    UINavigationController *userNav = [[UINavigationController alloc] initWithRootViewController:usersViewController];
    userNav.navigationBarHidden = YES;
    
    SearchViewController *searchViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"search"];
    searchViewController.title = @"Search";
    searchViewController.burgerDelegate = self;
    UINavigationController *searchNav = [[UINavigationController alloc] initWithRootViewController:searchViewController];
    searchNav.navigationBarHidden = YES;
    
    self.arrayOfViewControllers = @[repoNav,userNav,searchNav];
    
    self.topViewController = self.arrayOfViewControllers[0];
    
    [self addChildViewController:self.topViewController];
    //self.topViewController.view.frame = self.view.frame;
    [self.view addSubview:self.topViewController.view];
    [self.topViewController didMoveToParentViewController:self];
    
}

-(void)setupDragRecognizer
{
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(movePanel:)];
    
    panRecognizer.minimumNumberOfTouches = 1;
    panRecognizer.maximumNumberOfTouches = 1;
    
    panRecognizer.delegate = self;
    
    [self.view addGestureRecognizer:panRecognizer];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)movePanel:(id)sender
{
    UIPanGestureRecognizer *pan = (UIPanGestureRecognizer*)sender;
    
    //[[[pan view] layer] removeAllAnimations];
    
    CGPoint translatedPoint = [pan translationInView:self.view];
    //CGPoint velocity = [pan velocityInView:self.view];
    
    //NSLog(@" translation: %@", NSStringFromCGPoint(translatedPoint));
   // NSLog(@" translation: %@", NSStringFromCGPoint(velocity));
    
    if (pan.state == UIGestureRecognizerStateBegan)
    {
        //self.topViewController.view.center = CGpointMake
    }
    
    if (pan.state == UIGestureRecognizerStateChanged)
    {
        if (translatedPoint.x > 0){
        self.topViewController.view.center = CGPointMake(self.topViewController.view.center.x + translatedPoint.x, self.topViewController.view.center.y);
        
        [pan setTranslation:CGPointZero inView:self.view];
        }
    }
    
    if (pan.state == UIGestureRecognizerStateEnded)
    {
        if (self.topViewController.view.frame.origin.x > self.view.frame.size.width / 3)
        {
            [UIView animateWithDuration:.4 animations:^{
                self.topViewController.view.frame = CGRectMake(self.view.frame.size.width * .75, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
            }
             completion:^(BOOL finished) {
                 if (finished) {
                     self.tapToClose = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeMenu:)];
                     
                 [self.topViewController.view addGestureRecognizer:self.tapToClose];
                 self.menuIsOpen = YES;
                 }
             }];
        }
        
        else {
            [UIView animateWithDuration:.4 animations:^{
                self.topViewController.view.frame = CGRectMake(0, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
            } completion:^(BOOL finished) {
                if (finished) {
                    //self.tapToClose = [UITapGestureRecognizer alloc] initWithTarget:self action:
                        
                    }
            }];
        }
    
    }

}

-(void)switchToViewControllerAtIndexPath:(NSIndexPath *)indexPath
{
    [UIView animateWithDuration:.2 animations:^{
        self.topViewController.view.frame = CGRectMake(self.view.frame.size.width, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    }completion:^(BOOL finished) {
        
        CGRect offScreen = self.topViewController.view.frame;
        
        [self.topViewController.view removeFromSuperview];
        
        [self.topViewController removeFromParentViewController];
        
        self.topViewController = self.arrayOfViewControllers[indexPath.row];
        
        [self addChildViewController:self.topViewController];
        
        self.topViewController.view.frame = offScreen;
        
        [self.view addSubview:self.topViewController.view];
        
        [self.topViewController didMoveToParentViewController:self];
        
        [self closeMenu:nil];
    }];
}

-(void)closeMenu:(id)sender
{
    [UIView animateWithDuration:.5 animations:^{
        self.topViewController.view.frame = self.view.frame;
    } completion:^(BOOL finished) {
        [self.topViewController.view removeGestureRecognizer:self.tapToClose];
        self.menuIsOpen = NO;
    }];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self switchToViewControllerAtIndexPath:(indexPath)];
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrayOfViewControllers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = [self.arrayOfViewControllers[indexPath.row] title];
    
    return cell;
}

-(void)openMenu
{
    [UIView animateWithDuration:.4 animations:^{
        self.topViewController.view.frame = CGRectMake(self.view.frame.size.width * .75, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
        
    } completion:^(BOOL finished) {
        
        if (finished)
        {
            [self.tapToClose addTarget:self action:@selector(closeMenu:)];
            [self.topViewController.view addGestureRecognizer:self.tapToClose];
            self.menuIsOpen = YES;
            self.tableView.userInteractionEnabled = YES;
        }
        
    }];
    
}

-(void)handleBurgerPressed
{
    if (self.menuIsOpen)
    {
        [self closeMenu:nil];
    }
    else
    {
        [self openMenu];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
