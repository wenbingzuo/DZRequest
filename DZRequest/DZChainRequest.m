//
//  DZChainRequest.m
//  DZNetworking
//
//  Created by Wenbing Zuo on 5/6/16.
//  Copyright © 2016 DaZuo. All rights reserved.
//

#import "DZChainRequest.h"
#import "DZRequestConst.h"

@interface DZChainRequest () <DZRequestAccessory>

@property (nonatomic, strong, readwrite) NSArray *requests;
@property (nonatomic, strong, readwrite) NSPointerArray *accessories;

@property (nonatomic, assign, getter=isRunning) BOOL running;
@property (nonatomic, assign, getter=isCanceling) BOOL canceling;
@end

@implementation DZChainRequest

- (instancetype)initWithRequests:(NSArray<DZBaseRequest *> *)requests {
    self = [super init];
    if (self) {
        self.completionQueue = dispatch_get_main_queue();
        self.requests = requests;
        for (DZBaseRequest *request in self.requests) {
            [request addAccessory:self];
        }
    }
    return self;
}

- (NSPointerArray *)accessories {
    if (!_accessories) {
        _accessories = [NSPointerArray pointerArrayWithOptions:NSPointerFunctionsWeakMemory];
    }
    return _accessories;
}

- (void)addAccessory:(id<DZRequestAccessory>)accessory {
    [self.accessories addPointer:(__bridge void *)accessory];
}

- (void)setSuccessCallback:(DZChainRequestSuccessCallback)success failureCallback:(DZChainRequestFailureCallback)failure {
    self.successCallback = success;
    self.failureCallback = failure;
}

- (void)start {
    if (self.isRunning) return;
    self.running = YES;
    [[DZChainRequestManager sharedManager] addChainRequest:self];
    [self toggleAccessoriesRequestWillStart];
    [self toggleAccessoriesRequestDidStart];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block NSError *lastError = nil;
        __block id lastResponseObject = nil;
        __block DZBaseRequest *lastRequest = nil;
        
        [self.requests enumerateObjectsUsingBlock:^(DZBaseRequest * _Nonnull request, NSUInteger idx, BOOL * _Nonnull stop) {
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            
            [request setCancelCallback:^(__kindof DZBaseRequest *request) {
                *stop = YES;
                dispatch_semaphore_signal(semaphore);
            }];
            [request startRequestSuccessCallback:^(__kindof DZBaseRequest *request, id responseObject) {
                lastError = nil;
                lastResponseObject = responseObject;
                lastRequest = request;
                
                dispatch_semaphore_signal(semaphore);
            } failureCallback:^(__kindof DZBaseRequest *request, NSError *error) {
                lastError = error;
                lastResponseObject = nil;
                lastRequest = request;
                *stop = YES;
                
                dispatch_semaphore_signal(semaphore);
            }];
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }];
        
        dispatch_async(self.completionQueue?self.completionQueue:dispatch_get_main_queue(), ^{
            
            if (self.isCanceling) {
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
                    !self.successCallback?:self.successCallback(self, lastRequest, lastResponseObject);
                }
                [self toggleAccessoriesRequestDidStop];
            }
            
            lastRequest = nil;
            lastError = nil;
            lastResponseObject = nil;
            [[DZChainRequestManager sharedManager] removeChainRequest:self];
        });
    });
}

- (void)startChainRequestSuccessCallback:(DZChainRequestSuccessCallback)success failureCallback:(DZChainRequestFailureCallback)failure {
    self.successCallback = success;
    self.failureCallback = failure;
    [self start];
}

- (void)cancel {
    if (self.isCanceling) return;
    self.canceling = YES;
    
    [self _cancelAllSubRequest];
}

- (void)cancelWithCallback:(DZChainRequestCancelCallback)cancel {
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