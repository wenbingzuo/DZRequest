//
//  AppNormalViewController.m
//  DZRequestDemo
//
//  Created by Wenbing Zuo on 5/11/16.
//  Copyright © 2016 DaZuo. All rights reserved.
//

#import "AppNormalViewController.h"
#import "DZRequest.h"
#import "NSMutableDictionary+DZRequest.h"

@interface AppNormalViewController ()


@end

@implementation AppNormalViewController

- (IBAction)sendGetRequest:(id)sender {
    DZBaseRequest *request = [DZBaseRequest new];
    request.requestMethod = DZRequestMethodGET;
    request.requestURL = @"https://api-test.menke.joinmind.cn/v1/feed/circle?default=filter&_after=&count=10";
    
    [request startRequestWithSuccessCallback:^(__kindof DZBaseRequest *request) {
        NSLog(@"%@--%@", request.responseObject, [NSThread currentThread]);
    } failureCallback:^(__kindof DZBaseRequest *request) {
        NSLog(@"%@--%@", request.error.localizedDescription, [NSThread currentThread]);
    }];
}

- (IBAction)sendPostRequest:(id)sender {
    DZBaseRequest *request = [DZBaseRequest new];
    request.requestMethod = DZRequestMethodPOST;
    request.requestBaseURL = @"https://api-test.menke.joinmind.cn";
    request.requestURL = @"/v1/user/login";
    request.requestParameters = @{@"phone":@"17710280827", @"password":@"123456"};
    [request startRequestWithSuccessCallback:^(__kindof DZBaseRequest *request) {
        NSLog(@"%@--%@", request.responseObject, [NSThread currentThread]);
    } failureCallback:^(__kindof DZBaseRequest *request) {
        NSLog(@"%@--%@", request.error.localizedDescription, [NSThread currentThread]);
    }];
}

- (IBAction)sendUploadRequest:(id)sender {
    DZBaseRequest *request = [DZBaseRequest new];
    request.requestMethod = DZRequestMethodPOST;
    request.requestURL= @"";
    request.requestConstructionCallback = ^(id<AFMultipartFormData> formData){
        
    };
    [request startRequestWithSuccessCallback:^(__kindof DZBaseRequest *request) {
        
    } failureCallback:^(__kindof DZBaseRequest *request) {
        
    }];
}

@end
