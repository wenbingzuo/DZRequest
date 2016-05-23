//
//  DZChainRequest.m
//  DZNetworking
//
//  Created by Wenbing Zuo on 5/6/16.
//  Copyright © 2016 DaZuo. All rights reserved.
//

#import "DZChainRequest.h"
#import "DZRequestConst.h"

@interface DZChainRequest ()

@property (nonatomic, strong, readwrite) NSArray *requests;
@property (nonatomic, assign, readwrite) DZRequestState state;
@property (nonatomic, strong, readwrite) NSMutableArray *accessories;

@end

@implementation DZChainRequest

- (instancetype)initWithRequests:(NSArray<DZBaseRequest *> *)requests {
    self = [super init];
    if (self) {
        self.requests = requests;
        self.state = DZRequestStateIdle;
        self.completionQueue = dispatch_get_main_queue();
    }
    return self;
}

- (NSMutableArray *)accessories {
    if (!_accessories) {
        _accessories = [NSMutableArray array];
    }
    return _accessories;
}

- (void)addAccessory:(id<DZRequestAccessory>)accessory {
    [self.accessories addObject:accessory];
}

- (void)setSuccessCallback:(DZChainRequestSuccessCallback)success failureCallback:(DZChainRequestFailureCallback)failure {
    self.successCallback = success;
    self.failureCallback = failure;
}

- (void)start {
    if (self.state == DZRequestStateRunning) return;
    self.state = DZRequestStateRunning;
    [[DZChainRequestManager sharedManager] addChainRequest:self];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block NSError *lastError = nil;
        __block id lastResponseObject = nil;
        __block DZBaseRequest *lastRequest = nil;
        
        [self.requests enumerateObjectsUsingBlock:^(DZBaseRequest * _Nonnull request, NSUInteger idx, BOOL * _Nonnull stop) {
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            
            [request startRequestSuccessCallback:^(__kindof DZBaseRequest *request, id responseObject) {
                lastError = nil;
                lastResponseObject = responseObject;
                lastRequest = request;
                
                if (request.responseFilterCallback) {
                    NSError *blockError = request.responseFilterCallback(request);
                    if (blockError) {
                        lastError = blockError;
                        lastResponseObject = nil;
                        *stop = YES;
                    }
                }
                
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
            if (lastError.code != NSURLErrorCancelled) {
                self.state = DZRequestStateCompleted;
            }
            if (lastError) {
                !self.failureCallback?:self.failureCallback(self, lastRequest, lastError);
            } else {
                !self.successCallback?:self.successCallback(self, lastRequest, lastResponseObject);
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
    if (self.state == DZRequestStateCanceling) return;
    self.state = DZRequestStateCanceling;
    
    [self.requests enumerateObjectsUsingBlock:^(DZBaseRequest * _Nonnull request, NSUInteger idx, BOOL * _Nonnull stop) {
        [request cancel];
    }];
    [[DZChainRequestManager sharedManager] removeChainRequest:self];
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