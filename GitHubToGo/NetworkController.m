//
//  NetworkController.m
//  GitHubToGo
//
//  Created by Daniel Fairbanks on 4/22/14.
//  Copyright (c) 2014 Fairbanksdan. All rights reserved.
//

#import "NetworkController.h"
#import "Repo.h"

#define GITHUB_CLIENT_ID @"03c0174a23414c68192f"
#define GITHUB_CLIENT_SECRET @"fc7bcf6b9911f84dfa8951aa306674fdac8c8e6b"
#define GITHUB_CALLBACK_URI @"gitauth://git_callback"
#define GITHUB_OAUTH_URL @"https://github.com/login/oauth/authorize?client_id=%@&redirect_uri=%@&scope=%@"
#define GITHUB_API_URL @"https://api.github.com/"


@interface NetworkController ()

@property (strong, nonatomic) NSMutableArray *repoArray;
@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) NSURLSession *urlSession;
@property (nonatomic, copy) void (^completionOfOAuthAccess)();

@end

@implementation NetworkController

-(id)init
{
    self = [super init];
    
    if(self) {
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _urlSession = [NSURLSession sessionWithConfiguration:configuration];
        
        self.token = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
        configuration.allowsCellularAccess = YES;
    }
    
    return self;
}

-(void)requestOAuthAccess:(void(^)())completionOfOAuthAccess
{
    NSString *urlString = [NSString stringWithFormat:GITHUB_OAUTH_URL,GITHUB_CLIENT_ID,GITHUB_CALLBACK_URI,@"user,repos"];
    self.completionOfOAuthAccess = completionOfOAuthAccess;
    
    [[UIApplication sharedApplication] performSelector:@selector(openURL:) withObject:[NSURL URLWithString:urlString] afterDelay:.1];
    
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
   
}


-(void)handleOAuthCallbackWithURL:(NSURL *)url
{
    NSLog(@" %@",url);
    NSString *code = [self getCodeFromCallbackURL:url];
    NSString *postString = [NSString stringWithFormat:@"client_id=%@&client_secret=%@&code=%@",GITHUB_CLIENT_ID,GITHUB_CLIENT_SECRET,code];
    NSData *postData = [postString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    //sessionConfiguration.HTTPAdditionalHeaders = @"(Authorization:": @"")
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    [request setURL:[NSURL URLWithString:@"https://github.com/login/oauth/access_token"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error)
        {
            NSLog(@"error: %@", error.description);
        }
        
        NSLog(@"%@", response.description);
        
        self.token = [self convertResponseDataIntoToken:data];
        [[NSUserDefaults standardUserDefaults] setObject:self.token forKey:@"token"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.completionOfOAuthAccess();
        });
        
    }];
    
    [postDataTask resume];
    
}

-(NSString *)convertResponseDataIntoToken:(NSData*)responseData
{
    NSString *tokenResponse = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
    NSArray *tokenComponents = [tokenResponse componentsSeparatedByString:@"&"];
    NSString *accessTokenWithCode = tokenComponents[0];
    NSArray *access_token_array = [accessTokenWithCode componentsSeparatedByString:@"="];
    
    NSLog(@"%@",access_token_array[1]);
    
    return access_token_array[1];
}

-(NSString *)getCodeFromCallbackURL:(NSURL *)callbackURL
{
    NSString *query = [callbackURL query];
    NSLog(@" %@",query);
    NSArray *components = [query componentsSeparatedByString:@"code="];
    
    
    return [components lastObject];
}

-(void)retrieveReposForCurrentUser:(void(^)(NSMutableArray *repos))completionBlock
{
    NSURL *userRepoURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@user/repos",GITHUB_API_URL]];
    
//    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    [request setURL:userRepoURL];
    [request setHTTPMethod:@"GET"];
    [request setValue:[NSString stringWithFormat:@"token %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"token"]] forHTTPHeaderField:@"Authorization"];
    
    NSURLSessionDataTask *repoDataTask = [_urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"%@", response.description);
        
        NSMutableArray *repos = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"%@",repos);
        
        NSMutableArray *tempArray = [NSMutableArray new];
        
//        for (NSDictionary *repoDictionary in repos) {
//            Repo *tempRepo = [Repo new];
//            
//            tempRepo.name = [repoDictionary objectForKey:@"name"];
//            tempRepo.html_url = [repoDictionary objectForKey:@"url"];
//            
//            [tempArray addObject:tempRepo];
//        }
        
        [repos enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Repo *tempRepo = [Repo new];
            tempRepo.name = [obj objectForKey:@"name"];
            tempRepo.html_url = [obj objectForKey:@"url"];
            [tempArray addObject:tempRepo];
        }];
        completionBlock(tempArray);
    }];
    
    
    [repoDataTask resume];
}

-(BOOL)checkForToken
{
    if (_token) {
        return YES;
    } else {
        NSLog(@"You need to get a token first");
        return NO;
    }
}

@end
