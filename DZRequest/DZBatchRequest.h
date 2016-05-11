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
    DZBatchRequestStateIdle, ///< The default state when create receiver.
    DZBatchRequestStateRunning, ///< The receiver is currently running.
    DZBatchRequestStateCompleted, ///< The receiver has completed the task.
    DZBatchRequestStateCanceling, ///< The receiver has been told to cancel.
};

typedef void(^DZBatchRequestCompletionCallback)(DZBatchRequest *batchRequest);

@interface DZBatchRequest : NSObject

/// The requests ran in the receiver.
@property (nonatomic, strong, readonly) NSArray *requests;

/**
 *  When receiver has been told to cancel, the error will be `NSURLErrorCancelled` for the `code`.
 */
@property (nonatomic, strong, readonly) NSError *error;

/// The current state of the receiver.
@property (nonatomic, assign, readonly) DZBatchRequestState state;

@property (nonatomic, assign) BOOL cancelWhenErrorOccur;

@property (nonatomic, copy) DZBatchRequestCompletionCallback batchRequestSuccessCallback;
@property (nonatomic, copy) DZBatchRequestCompletionCallback batchRequestFailureCallback;

@property (nonatomic, strong) dispatch_queue_t completionQueue;

- (void)start;

/**
 *  开始请求，会覆盖前面设置的回调.
 *
 *  @param success 成功回调.
 *  @param failure 失败回调.
 */
- (void)startBatchRequestWithSuccessCallback:(DZBatchRequestCompletionCallback)success failureCallback:(DZBatchRequestCompletionCallback)failure;

/// 取消当前的请求.
- (void)cancel;

#pragma mark - Initialization
///---------------------
/// @name Initialization
///---------------------

/**
 *  Initializes a `DZBatchRequest` object with the specified requests.
 *
 *  @param requests The requests for the receiver. If same requests contained in this array,
 *                  the later will be ignored.
 */
- (instancetype)initWithRequests:(NSArray<DZBaseRequest *>*) requests;

@end
