//
//  DZChangeAvatarViewController.m
//  DZRequestDemo
//
//  Created by Wenbing Zuo on 5/13/16.
//  Copyright © 2016 DaZuo. All rights reserved.
//

#import "DZChangeAvatarViewController.h"
#import "DZChangeAvatarRequest.h"
#import "DZRequestConst.h"

@interface DZChangeAvatarViewController ()

@property (nonatomic, strong) DZChangeAvatarRequest *changeAvatarRequest;

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@end

@implementation DZChangeAvatarViewController

- (DZChangeAvatarRequest *)changeAvatarRequest {
    if (!_changeAvatarRequest) {
        _changeAvatarRequest = [DZChangeAvatarRequest new];
    }
    return _changeAvatarRequest;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"ChangeAvatar";
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.changeAvatarRequest.avatar = [UIImage imageNamed:@"avatar.jpg"];
//    @weakify(self)
    [self.changeAvatarRequest setUploadProgressCallback:^(NSProgress *progress) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            @strongify(self)
//            self.progressView.progress = progress.fractionCompleted;
//        });
        DZLog(@"%f---%@", progress.fractionCompleted, [NSThread currentThread]);
    }];
    [self.changeAvatarRequest startRequestWithSuccessCallback:^(__kindof DZBaseRequest *request) {
        DZLog(@"%@", request.responseObject);
    } failureCallback:^(__kindof DZBaseRequest *request) {
        DZLog(@"%@", request.error.localizedDescription);
    }];
}

@end
