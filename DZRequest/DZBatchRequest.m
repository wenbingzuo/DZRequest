//
//  DZBatchRequest.m
//  DZNetworking
//
//  Created by Wenbing Zuo on 5/6/16.
//  Copyright © 2016 DaZuo. All rights reserved.
//

#import "DZBatchRequest.h"
#import "DZBaseRequest.h"
#import "DZBatchRequestManager.h"
#import "DZRequestConst.h"

@interface DZBatchRequest ()

@property (nonatomic, strong, readwrite) NSArray *requests;
@property (nonatomic, strong, readwrite) NSError *error;
@property (nonatomic, assign, readwrite) DZBatchRequestState state;

@end

@implementation DZBatchRequest

- (instancetype)initWithRequests:(NSArray<DZBaseRequest *> *)requests {
    self = [super init];
    if (self) {
        self.completionQueue = dispatch_get_main_queue();
        self.state = DZBatchRequestStateIdle;
        self.cancelWhenErrorOccur = YES;
        
        NSMutableArray *array = [NSMutableArray array];
        for (DZBaseRequest *request in requests) {
            if (![array containsObject:request]) {
                [array addObject:request];
            } else {
                DZLog(@"Warning, same requests (%@) in batch requests, later removed", [request class]);
            }
        }
        self.requests = array;
    }
    return self;
}

- (void)start {
    
    if (self.state == DZBatchRequestStateRunning) return;
    
    self.state = DZBatchRequestStateRunning;
    [[DZBatchRequestManager sharedManager] addBatchRequest:self];
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    __block NSError *error = nil;
    __block BOOL flag = YES;
    for (DZBaseRequest *request in self.requests) {
        dispatch_group_enter(group);
        dispatch_group_async(group, queue, ^{
            @weakify(self)
            [request startRequestWithSuccessCallback:^(__kindof DZBaseRequest *request) {
                dispatch_group_leave(group);
                
                @strongify(self)
                if (self.cancelWhenErrorOccur && flag) {
                    if (!request.responseFilterCallback) return;
                    
                    NSError *blockError = request.responseFilterCallback(request);
                    if (!blockError) return;
                    
                    error = blockError;
                    flag = NO;
                    for (DZBaseRequest *request in self.requests) {
                        [request cancel];
                    }
                }
            } failureCallback:^(__kindof DZBaseRequest *request) {
                error = request.error;
                dispatch_group_leave(group);
                
                @strongify(self)
                if (self.cancelWhenErrorOccur && flag) {
                    flag = NO;
                    for (DZBaseRequest *request in self.requests) {
                        [request cancel];
                    }
                }
                
            }];
        });
    }
    
    dispatch_group_notify(group, self.completionQueue?self.completionQueue:dispatch_get_main_queue(), ^{
        self.state = DZBatchRequestStateCompleted;
        
        self.error = error;
        if (self.error) {
            !self.batchRequestFailureCallback?:self.batchRequestFailureCallback(self);
        } else {
            !self.batchRequestSuccessCallback?:self.batchRequestSuccessCallback(self);
        }
        
        [[DZBatchRequestManager sharedManager] removeBatchRequest:self];
    });
}

- (void)startBatchRequestWithSuccessCallback:(DZBatchRequestCompletionCallback)success failureCallback:(DZBatchRequestCompletionCallback)failure {
    self.batchRequestSuccessCallback = success;
    self.batchRequestFailureCallback = failure;
    [self start];
}

- (void)cancel {
    self.state = DZBatchRequestStateCanceling;
    
    for (DZBaseRequest *request in self.requests) {
        [request cancel];
    }
    [[DZBatchRequestManager sharedManager] removeBatchRequest:self];
}

@end
