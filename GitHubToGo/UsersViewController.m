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
#import "User.h"
#import "UserCollectionViewCell.h"

@class MyCustomCell;

@interface UsersViewController () <UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) NSMutableArray *userArray;
@property (weak, nonatomic) AppDelegate *appDelegate;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSOperationQueue *imageQueue;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

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
    self.imageQueue = [NSOperationQueue new];
    
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
        User *user = [[User alloc] initWithJson:repDict];
        
        [self.userArray addObject:user];
    }
    [self.collectionView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self usersForSearchString:searchBar.text];
    NSLog(@"%@", searchBar.text);
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.userArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UserCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UserCell" forIndexPath:indexPath];
  
        User *user = self.userArray[indexPath.row];
        if (user.avatarImage)
        {
            
            cell.imageView.image = user.avatarImage;
        } else {
            cell.imageView.image = [UIImage imageNamed:@"GitHub-Mark"];
            [user downloadAvatarOnQueue:_imageQueue withCompletionBlock:^{
                [collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }];
        }
    
    cell.cellLabel.text = [self.userArray[indexPath.row] name];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"showUserDetail"]) {
        NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] lastObject];
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
