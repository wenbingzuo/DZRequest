//
//  DZBatchRequestManager.m
//  DZNetworking
//
//  Created by Wenbing Zuo on 5/6/16.
//  Copyright © 2016 DaZuo. All rights reserved.
//

#import "DZBatchRequestManager.h"

@interface DZBatchRequestManager ()

@property (nonatomic, strong) NSMutableArray *batchRequests;

@end

@implementation DZBatchRequestManager

+ (instancetype)sharedManager {
    static DZBatchRequestManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [DZBatchRequestManager new];
        instance.batchRequests = [NSMutableArray array];
    });
    return instance;
}

- (void)addBatchRequest:(DZBatchRequest *)batchRequest {
    @synchronized (self) {
        [self.batchRequests addObject:batchRequest];
    }
}

- (void)removeBatchRequest:(DZBatchRequest *)batchRequest {
    @synchronized (self) {
        [self.batchRequests removeObject:batchRequest];
    }
}

@end
