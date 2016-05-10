//
//  AppDemoViewController.m
//  DZNetworking
//
//  Created by Wenbing Zuo on 5/9/16.
//  Copyright © 2016 DaZuo. All rights reserved.
//

#import "AppDemoViewController.h"
#import "AppDemoDataController.h"
#import "AppLoginRequest.h"

@interface AppDemoViewController ()

@property (nonatomic, strong) AppDemoDataController *dataController;
@property (nonatomic, strong) AppLoginRequest *loginRequest;

@end

@implementation AppDemoViewController

- (AppDemoDataController *)dataController {
    if (!_dataController) {
        _dataController = [AppDemoDataController new];
    }
    return _dataController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loginRequest = [[AppLoginRequest alloc] initWithUsername:@"88888888888" password:@"123"];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.loginRequest start];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.loginRequest cancel];
}

@end
