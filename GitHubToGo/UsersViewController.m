//
//  UsersViewController.m
//  GitHubToGo
//
//  Created by Daniel Fairbanks on 4/21/14.
//  Copyright (c) 2014 Fairbanksdan. All rights reserved.
//

#import "UsersViewController.h"
#import "AppDelegate.h"
#import "Repo.h"
#import "SearchDetailViewController.h"

@interface UsersViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (strong, nonatomic) NSMutableArray *userArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) AppDelegate *appDelegate;

@end

@implementation UsersViewController

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
    
    _userArray = [NSMutableArray new];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)burgerPressed:(id)sender {
    [self.burgerDelegate handleBurgerPressed];
}

- (void)usersForSearchString:(NSString *)searchString
{
    
    searchString = [searchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *jsonURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/search/users?q=%@", searchString]];
    
    NSData *jsonData = [NSData dataWithContentsOfURL:jsonURL];
    
    NSMutableDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                    options:NSJSONReadingMutableContainers
                                                                      error:nil];
    
    NSArray *tempArray = [jsonDict objectForKey:@"items"];
    
    [self.userArray removeAllObjects];
    
    for (NSDictionary *repDict in tempArray) {
        Repo *tempRepo = [Repo new];
        
        tempRepo.name = [repDict objectForKey:@"login"];
        tempRepo.html_url = [repDict objectForKey:@"html_url"];
        
        
        [self.userArray addObject:tempRepo];
    }
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self usersForSearchString:searchBar.text];
    NSLog(@"%@", searchBar.text);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.userArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
    
    cell.textLabel.text = [self.userArray[indexPath.row] name];
    
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showUserDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Repo *repo = [self.userArray objectAtIndex:indexPath.row];
        SearchDetailViewController *sdvc = (SearchDetailViewController *)segue.destinationViewController;
        sdvc.searchResultURL = repo.html_url;
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
