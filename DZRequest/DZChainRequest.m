//
//  DZChainRequest.m
//  DZNetworking
//
//  Created by Wenbing Zuo on 5/6/16.
//  Copyright © 2016 DaZuo. All rights reserved.
//

#import "DZChainRequest.h"
#import "DZBaseRequest.h"
#import "DZRequestConst.h"
#import "DZChainRequestManager.h"

@interface DZChainRequest ()

@property (nonatomic, strong, readwrite) NSArray *requests;
@property (nonatomic, assign, readwrite) DZChainRequestState state;

@end

@implementation DZChainRequest

- (instancetype)initWithRequests:(NSArray<DZBaseRequest *> *)requests {
    self = [super init];
    if (self) {
        self.requests = requests;
        self.state = DZChainRequestStateIdle;
        self.completionQueue = dispatch_get_main_queue();
    }
    return self;
}

- (void)start {
    if (self.state == DZChainRequestStateRunning) return;
    self.state = DZChainRequestStateRunning;
    [[DZChainRequestManager sharedManager] addChainRequest:self];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        __block DZBaseRequest *lastRequest = nil;
        [self.requests enumerateObjectsUsingBlock:^(DZBaseRequest * _Nonnull request, NSUInteger idx, BOOL * _Nonnull stop) {
            @weakify(self)
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            [request startRequestWithSuccessCallback:^(__kindof DZBaseRequest *request) {
                @strongify(self)
                BOOL goOn = !request.responseFilterCallback?YES:request.responseFilterCallback( request);
                if (!goOn) {
                    lastRequest = request;
                    *stop = YES;
                }
                if (idx == self.requests.count-1) {
                    lastRequest = request;
                }
                dispatch_semaphore_signal(semaphore);
            } failureCallback:^(__kindof DZBaseRequest *request) {
                @strongify(self)
                self.error = request.error;
                lastRequest = request;
                *stop = YES;
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }];
        
        dispatch_async(self.completionQueue?self.completionQueue:dispatch_get_main_queue(), ^{
            self.state = DZChainRequestStateCompleted;
            !self.completionCallback?:self.completionCallback(self, lastRequest);
            [[DZChainRequestManager sharedManager] removeChainRequest:self];
        });
    });
}

- (void)startChainRequestWithCompletionCallback:(DZChainRequestCompletionCallback)callback {
    self.completionCallback = callback;
    [self start];
}

- (void)cancel {
    self.state = DZChainRequestStateCanceling;
    [self.requests enumerateObjectsUsingBlock:^(DZBaseRequest * _Nonnull request, NSUInteger idx, BOOL * _Nonnull stop) {
        [request cancel];
    }];
    [[DZChainRequestManager sharedManager] removeChainRequest:self];
}

@end
