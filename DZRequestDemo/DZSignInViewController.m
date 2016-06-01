//
//  DZSignInViewController.m
//  DZRequestDemo
//
//  Created by Wenbing Zuo on 5/12/16.
//  Copyright © 2016 DaZuo. All rights reserved.
//

#import "DZSignInViewController.h"
#import "DZRequestConst.h"
#import "DZSignInRequest.h"

@interface DZSignInViewController ()


@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation DZSignInViewController

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(nullable id)sender {
    
    if ([identifier isEqualToString:@"chain"]) return YES;
    if ([identifier isEqualToString:@"batch"]) return YES;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    DZSignInRequest *signInRequest = [DZSignInRequest new];
    
    signInRequest.username = self.usernameTextField.text;
    signInRequest.password = self.passwordTextField.text;
    
    __block BOOL success = NO;
    [signInRequest startRequestSuccessCallback:^(__kindof DZBaseRequest *request, id responseObject) {
        success = YES;
//        [[NSUserDefaults standardUserDefaults] setObject:responseObject[@"user"][@"access_token"] forKey:@"accessToken"];
        dispatch_semaphore_signal(semaphore);
    } failureCallback:^(__kindof DZBaseRequest *request, NSError *error) {
        success = NO;
        dispatch_semaphore_signal(semaphore);
    }];
//    [self.signInRequest cancelWithCallback:^(__kindof DZBaseRequest *request) {
//        success = NO;
//        dispatch_semaphore_signal(semaphore);
//    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return success;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    // Download Test
    DZBaseRequest *request = [DZBaseRequest new];
    request.responseSerializerType = DZResponseSerializerTypeHTTP;
    request.requestURL = @"https://codeload.github.com/DaZuo/GitTest/zip/master";
    [request setDownloadProgressCallback:^(NSProgress *progress) {
        NSLog(@"%f -- %lld", progress.fractionCompleted, progress.totalUnitCount);
    }];
    [request startRequestSuccessCallback:^(__kindof DZBaseRequest *request, id responseObject) {
        NSData *data = responseObject;
        NSLog(@"length -- %ld", [data length]);
    } failureCallback:^(__kindof DZBaseRequest *request, NSError *error) {
        NSLog(@"error -- %@", error.localizedDescription);
    }];
}

@end
