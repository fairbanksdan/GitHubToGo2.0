//
//  NetworkController.h
//  GitHubToGo
//
//  Created by Daniel Fairbanks on 4/22/14.
//  Copyright (c) 2014 Fairbanksdan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkController : NSObject

-(void)handleOAuthCallbackWithURL:(NSURL *)url;

-(void)retrieveReposForCurrentUser:(void(^)(NSMutableArray *repos))completionBlock;

-(void)requestOAuthAccess:(void(^)())completionOfOAuthAccess;

-(BOOL)checkForToken;

@end
