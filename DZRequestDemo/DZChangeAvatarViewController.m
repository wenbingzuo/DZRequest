//
//  DZChangeAvatarViewController.m
//  DZRequestDemo
//
//  Created by Wenbing Zuo on 5/13/16.
//  Copyright © 2016 DaZuo. All rights reserved.
//

#import "DZChangeAvatarViewController.h"
#import "DZChangeAvatarRequest.h"

@interface DZChangeAvatarViewController ()

@property (nonatomic, strong) DZChangeAvatarRequest *changeAvatarRequest;

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
    [self.changeAvatarRequest startRequestWithSuccessCallback:^(__kindof DZBaseRequest *request) {
        
    } failureCallback:^(__kindof DZBaseRequest *request) {
        
    }];
}

@end
