//
//  SearchDetailViewController.m
//  GitHubToGo
//
//  Created by Daniel Fairbanks on 4/21/14.
//  Copyright (c) 2014 Fairbanksdan. All rights reserved.
//

#import "SearchDetailViewController.h"
#import "SearchViewController.h"

@interface SearchDetailViewController ()

@end

@implementation SearchDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:self.searchResultURL] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:604800];
    [self.webView loadRequest:urlRequest];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

@end
