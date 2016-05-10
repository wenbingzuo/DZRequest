//
//  AppDemoViewController.m
//  DZNetworking
//
//  Created by Wenbing Zuo on 5/9/16.
//  Copyright © 2016 DaZuo. All rights reserved.
//

#import "AppDemoViewController.h"
#import "AppDemoDataController.h"

@interface AppDemoViewController ()

@property (nonatomic, strong) AppDemoDataController *dataController;

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
    // Do any additional setup after loading the view.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    AppAuthorizeRequest *request = [AppAuthorizeRequest new];
//    [request startWithRequestSuccessCallback:^(__kindof DZBaseRequest *request) {
//        NSString *string = [[NSString alloc] initWithData:request.responseObject encoding:NSUTF8StringEncoding];
//        NSLog(@"%@", string);
//    } failureCallback:^(__kindof DZBaseRequest *request) {
//        
//    }];
    [self.dataController sendLoginRequest:@"17710280827" password:@"123456" callback:^(NSError *error) {
        
    }];
}

@end
