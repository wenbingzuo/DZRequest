//
//  DZBatchRequest.h
//  DZNetworking
//
//  Created by Wenbing Zuo on 5/6/16.
//  Copyright © 2016 DaZuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DZBaseRequest.h"
@class DZBatchRequest;

typedef void(^DZBatchRequestSuccessCallback)(DZBatchRequest *batchRequest);
typedef void(^DZBatchRequestFailureCallback)(DZBatchRequest *batchRequest, __kindof DZBaseRequest *request, NSError *error);
typedef void(^DZBatchRequestCancelCallback)(DZBatchRequest *batchRequest);

@interface DZBatchRequest : NSObject

@property (nonatomic, strong, readonly) NSArray *requests;

/**
 A flag to indicate whether cancel the rest request or not when error occurs.
 Default is YES.
 */
@property (nonatomic, assign) BOOL cancelWhenErrorOccur;

@property (nonatomic, strong) dispatch_queue_t completionQueue;

- (void)addAccessory:(id<DZRequestAccessory>)accessory;

@property (nonatomic, copy) DZBatchRequestSuccessCallback successCallback;
@property (nonatomic, copy) DZBatchRequestFailureCallback failureCallback;
- (void)setSuccesssCallback:(DZBatchRequestSuccessCallback)success failureCallback:(DZBatchRequestFailureCallback)failure;

- (void)start;
- (void)startBatchReqeustSuccessCallback:(DZBatchRequestSuccessCallback)success failureCallback:(DZBatchRequestFailureCallback)failure;

@property (nonatomic, copy) DZBatchRequestCancelCallback cancelCallback;
- (void)cancel;
- (void)cancelWithCallback:(DZBatchRequestCancelCallback)cancel;

///---------------------
/// @name Initialization
///---------------------

- (instancetype)initWithRequests:(NSArray<DZBaseRequest *>*) requests;

@end



@interface DZBatchRequestManager : NSObject

+ (instancetype)sharedManager;

- (void)addBatchRequest:(DZBatchRequest *)batchRequest;

- (void)removeBatchRequest:(DZBatchRequest *)batchRequest;

@end

