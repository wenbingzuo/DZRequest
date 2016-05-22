//
//  DZBatchRequestViewController.m
//  DZRequestDemo
//
//  Created by Wenbing Zuo on 5/16/16.
//  Copyright © 2016 DaZuo. All rights reserved.
//

#import "DZBatchRequestViewController.h"
#import "DZSignInRequest.h"
#import "DZChangeAvatarRequest.h"
#import "DZRequestConst.h"
#import "DZRequest.h"

@interface DZBatchRequestViewController ()

@property (weak, nonatomic) IBOutlet UILabel *hintLabel;

@end

@implementation DZBatchRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"BatchRequest";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)sendBatchRequest:(id)sender {
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
    
    DZBatchRequest *batchRequest = [[DZBatchRequest alloc] initWithRequests:@[signInRequest, changeAvatarRequest]];
    [batchRequest startBatchReqeustSuccessCallback:^(DZBatchRequest *batchRequest) {
        DZLog(@"success %@ --> %@ --> %@", batchRequest.requests);
        
    } failureCallback:^(DZBatchRequest *batchRequest, __kindof DZBaseRequest *request, NSError *error) {
        DZLog(@"failure %@ --> %@ --> %@", batchRequest.requests, request, error.localizedDescription);
        
    }];
}

@end
