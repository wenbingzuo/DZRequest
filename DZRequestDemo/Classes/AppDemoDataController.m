//
//  AppDemoDataController.m
//  DZNetworking
//
//  Created by Wenbing Zuo on 5/9/16.
//  Copyright © 2016 DaZuo. All rights reserved.
//

#import "AppDemoDataController.h"
#import "AppLoginRequest.h"
#import "AppGetUserinfoRequest.h"
#import "DZBatchRequest.h"
#import "DZChainRequest.h"

@interface AppDemoDataController ()

@property (nonatomic, strong) AppLoginRequest *loginRequest;
@property (nonatomic, strong) AppGetUserinfoRequest *getUserinfoRequest;

@end

@implementation AppDemoDataController

- (AppLoginRequest *)loginRequest {
    if (!_loginRequest) {
        _loginRequest = [AppLoginRequest new];
    }
    return _loginRequest;
}

- (AppGetUserinfoRequest *)getUserinfoRequest {
    if (!_getUserinfoRequest) {
        _getUserinfoRequest = [AppGetUserinfoRequest new];
    }
    return _getUserinfoRequest;
}

- (void)sendLoginRequest:(NSString *)name password:(NSString *)password callback:(AppDemoDataCompletionCallback)callback {
    self.loginRequest.username = name;
    self.loginRequest.password = password;
    self.loginRequest.responseFilterCallback = ^BOOL(DZBaseRequest *request) {
        if ([request.responseObject[@"data"][@"activated"] boolValue]) {
            return YES;
        } else {
            return NO;
        }
    };
    
    DZChainRequest *chainRequest = [[DZChainRequest alloc] initWithRequests:@[self.loginRequest, self.getUserinfoRequest]];
    [chainRequest startChainRequestWithCompletionCallback:^(DZChainRequest *chainRequest, DZBaseRequest *request) {
        
    }];
    
//    AppLoginRequest *login = [AppLoginRequest new];
//    login.username = name;
//    login.password = password;
//    
//    AppGetUserinfoRequest *info = [AppGetUserinfoRequest new];
    
    
//    NSSet *set = [NSSet setWithObjects:self.loginRequest, self.getUserinfoRequest, self.loginRequest, self.getUserinfoRequest, nil];
    
//    DZBatchRequest *batchRequest = [[DZBatchRequest alloc] initWithRequests:@[self.loginRequest, self.getUserinfoRequest, self.loginRequest, self.getUserinfoRequest]];
//    [batchRequest startWithRequestsSuccessCallback:^(DZBatchRequest *batchRequest) {
//        
//    } failureCallback:^(DZBatchRequest *batchRequest) {
//        
//    }];
    
//    [self.loginRequest startRequestWithSuccessCallback:^(__kindof DZBaseRequest *request) {
//       
//    } failureCallback:^(__kindof DZBaseRequest *request) {
//        
//    }];
}

@end
