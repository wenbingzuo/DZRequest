//
//  DZChainRequestViewController.m
//  DZRequestDemo
//
//  Created by Wenbing Zuo on 5/13/16.
//  Copyright © 2016 DaZuo. All rights reserved.
//

#import "DZChainRequestViewController.h"
#import "DZSignInRequest.h"
#import "DZChangeAvatarRequest.h"
#import "DZRequest.h"
#import "DZRequestConst.h"

@interface DZChainRequestViewController ()

@property (weak, nonatomic) IBOutlet UILabel *hintLabel;

@property (nonatomic, strong) DZChainRequest *chainRequest;

@end

@implementation DZChainRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"ChainRequest";
}

- (IBAction)sendChainRequest:(id)sender {
    DZSignInRequest *signInRequest = [DZSignInRequest new];
    signInRequest.username = @"username";
    signInRequest.password = @"password";
    
    DZChangeAvatarRequest *changeAvatarRequest = [DZChangeAvatarRequest new];
    changeAvatarRequest.avatar = [UIImage imageNamed:@"avatar.jpg"];
    
    self.chainRequest = [[DZChainRequest alloc] initWithRequests:@[signInRequest, changeAvatarRequest]];
    [self.chainRequest startChainRequestSuccessCallback:^(DZChainRequest *chainRequest, __kindof DZBaseRequest *request, id responseObject) {
        DZLog(@"success %@\n%@\n%@", chainRequest.requests, request, responseObject);
    } failureCallback:^(DZChainRequest *chainRequest, __kindof DZBaseRequest *request, NSError *error) {
        DZLog(@"failure %@\n%@\n%@", chainRequest.requests, request, error.localizedDescription);
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.chainRequest cancel];
}

@end
