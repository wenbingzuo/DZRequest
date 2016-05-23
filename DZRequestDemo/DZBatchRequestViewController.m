//
//  DZBatchRequestViewController.m
//  DZRequestDemo
//
//  Created by Wenbing Zuo on 5/16/16.
//  Copyright © 2016 DaZuo. All rights reserved.
//

#import "DZBatchRequestViewController.h"
#import "DZRequest.h"
#import "DZGetTeamFeedsRequest.h"
#import "DZGetUserFeedsRequest.h"

@interface DZBatchRequestViewController ()

@property (weak, nonatomic) IBOutlet UILabel *hintLabel;

@end

@implementation DZBatchRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"BatchRequest";
}

- (IBAction)sendBatchRequest:(id)sender {
    DZGetTeamFeedsRequest *teamFeedsRequest = [DZGetTeamFeedsRequest new];
    DZGetUserFeedsRequest *userFeedsRequest = [DZGetUserFeedsRequest new];
    
    DZBatchRequest *batchRequest = [[DZBatchRequest alloc] initWithRequests:@[teamFeedsRequest, userFeedsRequest]];
    [batchRequest startBatchReqeustSuccessCallback:^(DZBatchRequest *batchRequest) {
        NSLog(@"success %@", batchRequest.requests);
        
    } failureCallback:^(DZBatchRequest *batchRequest, __kindof DZBaseRequest *request, NSError *error) {
        NSLog(@"failure %@ --> %@ --> %@", batchRequest.requests, request, error.localizedDescription);
        
    }];
}

@end
