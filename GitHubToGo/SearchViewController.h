//
//  SearchViewController.h
//  GitHubToGo
//
//  Created by Daniel Fairbanks on 4/21/14.
//  Copyright (c) 2014 Fairbanksdan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BurgerProtocol.h"

@interface SearchViewController : UIViewController

@property (nonatomic,unsafe_unretained) id <BurgerProtocol> burgerDelegate;

@end
