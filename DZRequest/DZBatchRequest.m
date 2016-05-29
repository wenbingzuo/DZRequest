//
//  DZBatchRequest.m
//  DZNetworking
//
//  Created by Wenbing Zuo on 5/6/16.
//  Copyright © 2016 DaZuo. All rights reserved.
//

#import "DZBatchRequest.h"
#import "DZRequestConst.h"

@interface DZBatchRequest () <DZRequestAccessory>

@property (nonatomic, strong, readwrite) NSArray *requests;
@property (nonatomic, strong, readwrite) NSPointerArray *accessories;

@property (nonatomic, assign, getter=isRunning) BOOL running;
@property (nonatomic, assign, getter=isCanceling) BOOL canceling;
@end

@implementation DZBatchRequest

- (NSPointerArray *)accessories {
    if (!_accessories) {
        _accessories = [NSPointerArray pointerArrayWithOptions:NSPointerFunctionsWeakMemory];
    }
    return _accessories;
}

- (void)addAccessory:(id<DZRequestAccessory>)accessory {
    [self.accessories addPointer:(__bridge void *)accessory];
}

- (instancetype)initWithRequests:(NSArray<DZBaseRequest *> *)requests {
    self = [super init];
    if (self) {
        self.completionQueue = dispatch_get_main_queue();
        self.cancelWhenErrorOccur = YES;
        
        NSMutableArray *array = [NSMutableArray array];
        for (DZBaseRequest *request in requests) {
            if (![array containsObject:request]) {
                [request addAccessory:self];
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
    if (self.isRunning) return;
    self.running = YES;
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
            [request setCancelCallback:^(__kindof DZBaseRequest *request) {
                dispatch_group_leave(group);
            }];
            
            [request startRequestSuccessCallback:^(__kindof DZBaseRequest *request, id responseObject) {
                dispatch_group_leave(group);
            } failureCallback:^(__kindof DZBaseRequest *request, NSError *error) {
                @strongify(self)
                
                lastRequest = request;
                lastError = error;
                
                if (self.cancelWhenErrorOccur && flag) {
                    flag = NO;
                    [self cancel];
                }
                
                dispatch_group_leave(group);
            }];
        });
    }
    
    dispatch_group_notify(group, self.completionQueue?self.completionQueue:dispatch_get_main_queue(), ^{
        
        if (self.canceling) {
            self.running = NO;
            !self.cancelCallback?:self.cancelCallback(self);
            self.canceling = NO;
        } else {
            self.running = NO;
            self.canceling = NO;
            
            [self toggleAccessoriesRequestWillStop];
            if (lastError) {
                !self.failureCallback?:self.failureCallback(self, lastRequest, lastError);
            } else {
                !self.successCallback?:self.successCallback(self);
            }
            [self toggleAccessoriesRequestDidStop];
        }
        
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
    if (self.isCanceling) return;
    self.canceling = YES;
    
    [self _cancelAllSubRequest];
}

- (void)cancelWithCallback:(DZBatchRequestCancelCallback)cancel {
    self.cancelCallback = cancel;
    [self cancel];
}

#pragma mark - DZRequestAccessory

- (void)requestDidStart:(id)request {
    if (self.canceling && [request isKindOfClass:[DZBaseRequest class]]) {
        [self _cancelAllSubRequest];
    }
}

#pragma mark - Private

- (void)_cancelAllSubRequest {
    for (DZBaseRequest *request in self.requests) {
        if (request.canCancel) [request cancel];
    }
}

- (void)toggleAccessoriesRequestWillStart {
    for (id<DZRequestAccessory> obj in self.accessories) {
        if ([obj respondsToSelector:@selector(requestWillStart:)]) {
            [obj requestWillStart:self];
        }
    }
}

- (void)toggleAccessoriesRequestDidStart {
    for (id<DZRequestAccessory> obj in self.accessories) {
        if ([obj respondsToSelector:@selector(requestDidStart:)]) {
            [obj requestDidStart:self];
        }
    }
}

- (void)toggleAccessoriesRequestWillStop {
    for (id<DZRequestAccessory> obj in self.accessories) {
        if ([obj respondsToSelector:@selector(requestWillStop:)]) {
            [obj requestWillStop:self];
        }
    }
}

- (void)toggleAccessoriesRequestDidStop {
    for (id<DZRequestAccessory> obj in self.accessories) {
        if ([obj respondsToSelector:@selector(requestDidStop:)]) {
            [obj requestDidStop:self];
        }
    }
}

- (void)dealloc {
    NSLog(@"%@ dealloc", [self class]);
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