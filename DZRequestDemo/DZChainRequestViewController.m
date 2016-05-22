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

@end

@implementation DZChainRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"ChainRequest";
}

- (IBAction)sendChainRequest:(id)sender {
    DZSignInRequest *signInRequest = [DZSignInRequest new];
    @weakify(self)
    signInRequest.responseFilterCallback = ^NSError *(DZBaseRequest *request) {
        if ([request.responseObject[@"success"] boolValue]) {
            [[NSUserDefaults standardUserDefaults] setObject:request.responseObject[@"user"][@"access_token"] forKey:@"accessToken"];
            return nil;
        } else {
            @strongify(self)
            self.hintLabel.text = @"error in sign in request!";
            NSError *error = [NSError errorWithDomain:@"io.dazuo.github.request.response.error" code:1000 userInfo:nil];
            return error;
        }
    };
    
    DZChangeAvatarRequest *changeAvatarRequest = [DZChangeAvatarRequest new];
    changeAvatarRequest.avatar = [UIImage imageNamed:@"avatar.jpg"];
    changeAvatarRequest.uploadProgressCallback = ^(NSProgress *progress) {
        @strongify(self)
        self.hintLabel.text = [NSString stringWithFormat:@"uploading %.2f", progress.fractionCompleted];
    };
    changeAvatarRequest.responseFilterCallback = ^NSError *(DZBaseRequest *request) {
        @strongify(self)
        if ([request.responseObject[@"success"] boolValue]) {
            self.hintLabel.text = @"error in uploading request!";
            return nil;
        } else {
            NSError *error = [NSError errorWithDomain:@"io.dazuo.github.request.response.error" code:1000 userInfo:@{NSLocalizedDescriptionKey:@"failed haha"}];
            return error;
        }
    };
    
    DZChainRequest *chainRequest = [[DZChainRequest alloc] initWithRequests:@[signInRequest, changeAvatarRequest]];
    [chainRequest startChainRequestSuccessCallback:^(DZChainRequest *chainRequest, __kindof DZBaseRequest *request, id responseObject) {
        DZLog(@"success %@\n%@\n%@", chainRequest.requests, request, responseObject);
    } failureCallback:^(DZChainRequest *chainRequest, __kindof DZBaseRequest *request, NSError *error) {
        DZLog(@"failure %@\n%@\n%@", chainRequest.requests, request, error.localizedDescription);
    }];
}

@end
