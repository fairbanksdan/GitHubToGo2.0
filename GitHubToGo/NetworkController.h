//
//  NetworkController.h
//  GitHubToGo
//
//  Created by Daniel Fairbanks on 4/22/14.
//  Copyright (c) 2014 Fairbanksdan. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NetworkControllerDelegate <NSObject>

-(void)reposDoneDownloading:(NSMutableArray *)currentUsersRepoArray;

@end

@interface NetworkController : NSObject

-(void)requestOAuthAccess;

-(void)handleOAuthCallbackWithURL:(NSURL *)url;

-(void)retrieveReposForCurrentUser:(void(^)(NSMutableArray *repos))completionBlock;

@property (nonatomic,unsafe_unretained) id <NetworkControllerDelegate> delegate;

@end
