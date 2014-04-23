//
//  SearchDetailViewController.h
//  GitHubToGo
//
//  Created by Daniel Fairbanks on 4/21/14.
//  Copyright (c) 2014 Fairbanksdan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchDetailViewController : UIViewController

@property (strong, nonatomic)IBOutlet UIWebView *webView;
@property (strong, nonatomic)NSString *searchResultURL;

@end
