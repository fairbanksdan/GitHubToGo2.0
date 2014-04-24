//
//  User.h
//  GitHubToGo
//
//  Created by Daniel Fairbanks on 4/24/14.
//  Copyright (c) 2014 Fairbanksdan. All rights reserved.
//

#import "Repo.h"

@interface User : Repo

@property (nonatomic, strong) NSString *avatarPath;
@property (nonatomic, strong) UIImage *avatarImage;
@property (nonatomic, strong) NSBlockOperation *imageDownloadOp;

- (instancetype)initWithJson:(NSDictionary *)dictionary;
- (void)downloadAvatarWithCompletionBlock:(void(^)())completion;
- (void)downloadAvatarOnQueue:(NSOperationQueue *)queue withCompletionBlock:(void(^)())completion;

@end
