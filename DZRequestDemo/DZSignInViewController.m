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

@property (nonatomic, strong) DZSignInRequest *signInRequest;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation DZSignInViewController

- (DZSignInRequest *)signInRequest {
    if (!_signInRequest) {
        _signInRequest = [DZSignInRequest new];
    }
    return _signInRequest;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(nullable id)sender {
    
    if ([identifier isEqualToString:@"chain"]) return YES;
    if ([identifier isEqualToString:@"batch"]) return YES;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    self.signInRequest.username = self.usernameTextField.text;
    self.signInRequest.password = self.passwordTextField.text;
    
    __block BOOL success = NO;
    [self.signInRequest startRequestSuccessCallback:^(__kindof DZBaseRequest *request, id responseObject) {
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

@end
