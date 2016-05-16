//
//  DZChainRequest.h
//  DZNetworking
//
//  Created by Wenbing Zuo on 5/6/16.
//  Copyright © 2016 DaZuo. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DZChainRequest, DZBaseRequest;

typedef NS_ENUM(NSUInteger, DZChainRequestState) {
    DZChainRequestStateIdle,
    DZChainRequestStateRunning,
    DZChainRequestStateCompleted,
    DZChainRequestStateCanceling,
};

typedef void(^DZChainRequestSuccessCallback)(DZChainRequest *chainRequest, __kindof DZBaseRequest *request, id responseObject);
typedef void(^DZChainRequestFailureCallback)(DZChainRequest *chainRequest, __kindof DZBaseRequest *request, NSError *error);

@interface DZChainRequest : NSObject

@property (nonatomic, strong, readonly) NSArray *requests;
@property (nonatomic, assign, readonly) DZChainRequestState state;
@property (nonatomic, strong) dispatch_queue_t completionQueue;

@property (nonatomic, copy) DZChainRequestSuccessCallback successCallback;
@property (nonatomic, copy) DZChainRequestFailureCallback failureCallback;
- (void)setSuccessCallback:(DZChainRequestSuccessCallback)success failureCallback:(DZChainRequestFailureCallback)failure;


- (instancetype)initWithRequests:(NSArray<DZBaseRequest *>*) requests;

- (void)start;
- (void)startChainRequestSuccessCallback:(DZChainRequestSuccessCallback)success failureCallback:(DZChainRequestFailureCallback)failure;
- (void)cancel;

@end



@interface DZChainRequestManager : NSObject

+ (instancetype)sharedManager;

- (void)addChainRequest:(DZChainRequest *)chainRequest;

- (void)removeChainRequest:(DZChainRequest *)chainRequest;

@end

