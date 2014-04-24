//
//  User.m
//  GitHubToGo
//
//  Created by Daniel Fairbanks on 4/24/14.
//  Copyright (c) 2014 Fairbanksdan. All rights reserved.
//

#import "User.h"

@interface User()

@property (nonatomic, strong) NSURL *avatarURL;

@end

@implementation User

- (instancetype)initWithJson:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        self.name = [dictionary objectForKey:@"login"];
        self.html_url = [dictionary objectForKey:@"html_url"];
        self.avatarPath = [dictionary objectForKey:@"avatar_url"];
        
    }
    return self;
}

- (void)downloadAvatarWithCompletionBlock:(void (^)())completion
{
    [self downloadAvatarOnQueue:[NSOperationQueue new] withCompletionBlock:completion];
}

- (void)downloadAvatarOnQueue:(NSOperationQueue *)queue withCompletionBlock:(void(^)())completion
{
    self.imageDownloadOp = [NSBlockOperation blockOperationWithBlock:^{
        NSData *imageData = [NSData dataWithContentsOfURL:self.avatarURL];
        _avatarImage = [UIImage imageWithData:imageData];
        [[NSOperationQueue mainQueue] addOperationWithBlock:completion];
        
    }];
    [queue addOperation:self.imageDownloadOp];
}

- (NSURL *)avatarURL
{
    return [NSURL URLWithString:_avatarPath];
}

@end
