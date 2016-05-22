//
//  DZBatchRequest.h
//  DZNetworking
//
//  Created by Wenbing Zuo on 5/6/16.
//  Copyright © 2016 DaZuo. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DZBaseRequest, DZBatchRequest;

typedef NS_ENUM(NSUInteger, DZBatchRequestState) {
    DZBatchRequestStateIdle, ///< The default state when create batch request.
    DZBatchRequestStateRunning, ///< The batch request is currently running.
    DZBatchRequestStateCompleted, ///< The batch request has completed the task.
    DZBatchRequestStateCanceling, ///< The batch request has been told to cancel.
};

typedef void(^DZBatchRequestSuccessCallback)(DZBatchRequest *batchRequest);
typedef void(^DZBatchRequestFailureCallback)(DZBatchRequest *batchRequest, __kindof DZBaseRequest *request, NSError *error);

@interface DZBatchRequest : NSObject

/// The requests ran in the receiver.
@property (nonatomic, strong, readonly) NSArray *requests;

/**
 *  When receiver has been told to cancel, the error will be `NSURLErrorCancelled` for the `code`.
 */

/// The current state of the receiver.
@property (nonatomic, assign, readonly) DZBatchRequestState state;

@property (nonatomic, assign) BOOL cancelWhenErrorOccur;

@property (nonatomic, copy) DZBatchRequestSuccessCallback successCallback;
@property (nonatomic, copy) DZBatchRequestFailureCallback failureCallback;
- (void)setSuccesssCallback:(DZBatchRequestSuccessCallback)success failureCallback:(DZBatchRequestFailureCallback)failure;


@property (nonatomic, strong) dispatch_queue_t completionQueue;

- (void)start;

- (void)startBatchReqeustSuccessCallback:(DZBatchRequestSuccessCallback)success failureCallback:(DZBatchRequestFailureCallback)failure;

- (void)cancel;

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

