//
//  ReposViewController.m
//  GitHubToGo
//
//  Created by Daniel Fairbanks on 4/21/14.
//  Copyright (c) 2014 Fairbanksdan. All rights reserved.
//

#import "ReposViewController.h"
#import "AppDelegate.h"
#import "Repo.h"
#import "SearchDetailViewController.h"

@interface ReposViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, NetworkControllerDelegate>

@property (strong, nonatomic) NSMutableArray *myRepoArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) AppDelegate *appDelegate;
@property (weak, nonatomic) NetworkController *networkController;

@end

@implementation ReposViewController

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
    self.appDelegate = [UIApplication sharedApplication].delegate;
    self.networkController = self.appDelegate.networkController;
    self.networkController.delegate = self;
    
    [self.networkController retrieveReposForCurrentUser:^(NSMutableArray *repos) {
        [self reposDoneDownloading:repos];
    }];
    
    _myRepoArray = [NSMutableArray new];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)burgerPressed:(id)sender {
    [self.burgerDelegate handleBurgerPressed];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.myRepoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *repoCell = [tableView dequeueReusableCellWithIdentifier:@"RepoCell" forIndexPath:indexPath];
    
    Repo *repo = self.myRepoArray[indexPath.row];
    
    repoCell.textLabel.text = repo.name;
    
    return repoCell;
}

-(void)reposDoneDownloading:(NSMutableArray *)currentUsersRepoArray
{
    self.myRepoArray = currentUsersRepoArray;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.tableView reloadData];
    }];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showRepoDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Repo *repo = [self.myRepoArray objectAtIndex:indexPath.row];
        SearchDetailViewController *sdvc = (SearchDetailViewController *)segue.destinationViewController;
        sdvc.searchResultURL = repo.html_url;
    }
}

@end
