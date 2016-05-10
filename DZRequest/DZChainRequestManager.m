//
//  DZChainRequestManager.m
//  DZNetworking
//
//  Created by Wenbing Zuo on 5/7/16.
//  Copyright © 2016 DaZuo. All rights reserved.
//

#import "DZChainRequestManager.h"

@interface DZChainRequestManager ()

@property (nonatomic, strong) NSMutableArray *chainRequests;

@end

@implementation DZChainRequestManager

+ (instancetype)sharedManager {
    static DZChainRequestManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [DZChainRequestManager new];
        instance.chainRequests = [NSMutableArray array];
    });
    return instance;
}

- (void)addChainRequest:(DZChainRequest *)chainRequest {
    @synchronized (self) {
        [self.chainRequests addObject:chainRequest];
    }
}

- (void)removeChainRequest:(DZChainRequest *)chainRequest {
    @synchronized (self) {
        [self.chainRequests removeObject:chainRequest];
    }
}

@end
