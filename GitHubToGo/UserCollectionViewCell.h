//
//  UserCollectionViewCell.h
//  GitHubToGo
//
//  Created by Daniel Fairbanks on 4/24/14.
//  Copyright (c) 2014 Fairbanksdan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *cellLabel;

@end
