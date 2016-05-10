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
    DZBatchRequestStateIdle, ///<未开始状态
    DZBatchRequestStateRunning, ///<请求进行中
    DZBatchRequestStateCompleted, ///<已完成
    DZBatchRequestStateCanceling, ///<取消
};

typedef void(^DZBatchRequestCompletionCallback)(DZBatchRequest *batchRequest);

@interface DZBatchRequest : NSObject

/// 所有要运行的请求.
@property (nonatomic, strong, readonly) NSArray *requests;

/**
 *  初始化方法，只能用这个初始化方法，要么就不管用.
 *
 *  @param requests 请求数组，这个数组中的请求不能是相同的，若有相同的则会去掉后面的.
 */
- (instancetype)initWithRequests:(NSArray<DZBaseRequest *>*) requests;

/**
 *  失败返回的错误
 *  @discussion 这个错误是最近的一个错误, 当`cancelWhenErrorOccured`为`YES`时，`error`可能是`NSURLErrorCancelled`.
 */
@property (nonatomic, strong) NSError *error;

/// 当前请求的状态.
@property (nonatomic, assign) DZBatchRequestState state;

/// 成功回调，只有所有的请求都成功才会回调.
@property (nonatomic, copy) DZBatchRequestCompletionCallback batchRequestSuccessCallback;

/// 失败回调，只要有一个请求失败就会回调.
@property (nonatomic, copy) DZBatchRequestCompletionCallback batchRequestFailureCallback;

/// 成功和失败的回调队列，默认是主队列
@property (nonatomic, strong) dispatch_queue_t completionQueue;

/// 开始请求.
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

@end
