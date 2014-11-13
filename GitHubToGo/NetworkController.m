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
@property (strong, nonatomic) UIWebView *webView;

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

-(void)requestOAuthAccess:(id)sender withCompletion:(void(^)())completionOfOAuthAccess
{
    NSString *urlString = [NSString stringWithFormat:GITHUB_OAUTH_URL,GITHUB_CLIENT_ID,GITHUB_CALLBACK_URI,@"user,repos"];
    self.completionOfOAuthAccess = completionOfOAuthAccess;
    
    UIViewController *presentingVC = (UIViewController *)sender;
    
    self.webView = [[UIWebView alloc] initWithFrame:presentingVC.view.frame];
    self.webView.backgroundColor = [UIColor darkGrayColor];

    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, presentingVC.view.frame.size.height-44.0, 320, 44)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelWebView)];
    [toolBar setItems:@[cancelButton]];
    [self.webView addSubview:toolBar];
    
    self.webView.transform = CGAffineTransformTranslate(self.webView.transform, 0.0, presentingVC.view.frame.size.height);
    [presentingVC.view addSubview:self.webView];
    NSURLRequest *authRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [self.webView loadRequest:authRequest];

    [UIView animateWithDuration:0.4 animations:^{
        self.webView.transform = CGAffineTransformTranslate(self.webView.transform, 0.0, -presentingVC.view.frame.size.height);
    }];
}

- (void)cancelWebView {
    [UIView animateWithDuration:0.4 animations:^{
        self.webView.transform = CGAffineTransformTranslate(self.webView.transform, 0, self.webView.frame.size.height);
    } completion:^(BOOL finished) {
        [self.webView removeFromSuperview];
    }];
}

-(void)handleOAuthCallbackWithURL:(NSURL *)url
{
    NSLog(@" %@",url);
    NSString *code = [self getCodeFromCallbackURL:url];
    NSString *postString = [NSString stringWithFormat:@"client_id=%@&client_secret=%@&code=%@",GITHUB_CLIENT_ID,GITHUB_CLIENT_SECRET,code];
    NSData *postData = [postString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
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

    NSMutableURLRequest *request = [NSMutableURLRequest new];
    [request setURL:userRepoURL];
    [request setHTTPMethod:@"GET"];
    [request setValue:[NSString stringWithFormat:@"token %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"token"]] forHTTPHeaderField:@"Authorization"];
    
    NSURLSessionDataTask *repoDataTask = [_urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"%@", response.description);
        
        NSMutableArray *repos = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"%@",repos);
        
        NSMutableArray *tempArray = [NSMutableArray new];
        
        [repos enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Repo *tempRepo = [Repo new];
            tempRepo.name = [obj objectForKey:@"name"];
            tempRepo.html_url = [obj objectForKey:@"html_url"];
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
