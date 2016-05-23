//
//  DZBatchRequest.m
//  DZNetworking
//
//  Created by Wenbing Zuo on 5/6/16.
//  Copyright © 2016 DaZuo. All rights reserved.
//

#import "DZBatchRequest.h"
#import "DZRequestConst.h"

@interface DZBatchRequest ()

@property (nonatomic, strong, readwrite) NSArray *requests;
@property (nonatomic, assign, readwrite) DZRequestState state;
@property (nonatomic, strong, readwrite) NSMutableArray *accessories;

@end

@implementation DZBatchRequest

- (NSMutableArray *)accessories {
    if (!_accessories) {
        _accessories = [NSMutableArray array];
    }
    return _accessories;
}

- (void)addAccessory:(id<DZRequestAccessory>)accessory {
    [self.accessories addObject:accessory];
}

- (instancetype)initWithRequests:(NSArray<DZBaseRequest *> *)requests {
    self = [super init];
    if (self) {
        self.completionQueue = dispatch_get_main_queue();
        self.state = DZRequestStateIdle;
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
    if (self.state == DZRequestStateRunning) return;
    self.state = DZRequestStateRunning;
    [self toggleAccessoriesRequestWillStart];
    [[DZBatchRequestManager sharedManager] addBatchRequest:self];
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    __block DZBaseRequest *lastRequest = nil;
    __block NSError *lastError = nil;
    __block BOOL flag = YES;
    [self toggleAccessoriesRequestDidStart];
    for (DZBaseRequest *request in self.requests) {
        dispatch_group_enter(group);
        dispatch_group_async(group, queue, ^{
            @weakify(self)
            [request startRequestSuccessCallback:^(__kindof DZBaseRequest *request, id responseObject) {
                @strongify(self)
                
                if (self.cancelWhenErrorOccur && flag) {
                    if (!request.responseFilterCallback) {
                        dispatch_group_leave(group);
                        return;
                    }
                    
                    NSError *error = request.responseFilterCallback(request);
                    if (!error) return;
                    
                    lastRequest = request;
                    lastError = error;
                    flag = NO;
                    for (DZBaseRequest *request in self.requests) {
                        [request cancel];
                    }
                    dispatch_group_leave(group);
                } else {
                    dispatch_group_leave(group);
                }
            } failureCallback:^(__kindof DZBaseRequest *request, NSError *error) {
                @strongify(self)
                
                if (error.code != NSURLErrorCancelled || self.state == DZRequestStateCanceling) {
                    lastRequest = request;
                    lastError = error;
                }
                
                if (self.cancelWhenErrorOccur && flag) {
                    flag = NO;
                    for (DZBaseRequest *request in self.requests) {
                        [request cancel];
                    }
                }
                
                dispatch_group_leave(group);
            }];
        });
    }
    
    dispatch_group_notify(group, self.completionQueue?self.completionQueue:dispatch_get_main_queue(), ^{
        if (lastError.code != NSURLErrorCancelled) {
            self.state = DZRequestStateCompleted;
        }
        
        [self toggleAccessoriesRequestWillStop];
        if (lastError) {
            !self.failureCallback?:self.failureCallback(self, lastRequest, lastError);
        } else {
            !self.successCallback?:self.successCallback(self);
        }
        [self toggleAccessoriesRequestDidStop];
        lastError = nil;
        lastRequest = nil;
        
        [[DZBatchRequestManager sharedManager] removeBatchRequest:self];
    });
}

- (void)startBatchReqeustSuccessCallback:(DZBatchRequestSuccessCallback)success failureCallback:(DZBatchRequestFailureCallback)failure {
    self.successCallback = success;
    self.failureCallback = failure;
    [self start];
}

- (void)setSuccesssCallback:(DZBatchRequestSuccessCallback)success failureCallback:(DZBatchRequestFailureCallback)failure {
    self.successCallback = success;
    self.failureCallback = failure;
}

- (void)cancel {
    if (self.state == DZRequestStateCanceling) return;
    self.state = DZRequestStateCanceling;
    
    for (DZBaseRequest *request in self.requests) {
        [request cancel];
    }
    [[DZBatchRequestManager sharedManager] removeBatchRequest:self];
}

#pragma mark - Private

- (void)toggleAccessoriesRequestWillStart {
    [self.accessories enumerateObjectsUsingBlock:^(id<DZRequestAccessory> obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(requestWillStart:)]) {
            [obj requestWillStart:self];
        }
    }];
}

- (void)toggleAccessoriesRequestDidStart {
    [self.accessories enumerateObjectsUsingBlock:^(id<DZRequestAccessory> obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(requestDidStart:)]) {
            [obj requestDidStart:self];
        }
    }];
}

- (void)toggleAccessoriesRequestWillStop {
    [self.accessories enumerateObjectsUsingBlock:^(id<DZRequestAccessory> obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(requestWillStop:)]) {
            [obj requestWillStop:self];
        }
    }];
}

- (void)toggleAccessoriesRequestDidStop {
    [self.accessories enumerateObjectsUsingBlock:^(id<DZRequestAccessory> obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(requestDidStop:)]) {
            [obj requestDidStop:self];
        }
    }];
}

@end



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