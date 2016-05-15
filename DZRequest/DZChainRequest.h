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
    DZChainRequestStateIdle, ///<未开始状态
    DZChainRequestStateRunning, ///<请求进行中
    DZChainRequestStateCompleted, ///<已完成
    DZChainRequestStateCanceling, ///<取消
};

typedef void(^DZChainRequestSuccessCallback)(DZChainRequest *chainRequest, __kindof DZBaseRequest *request, id responseObject);
typedef void(^DZChainRequestFailureCallback)(DZChainRequest *chainRequest, __kindof DZBaseRequest *request, NSError *error);

@interface DZChainRequest : NSObject

/// 所有要运行的请求.
@property (nonatomic, strong, readonly) NSArray *requests;

/// 状态码非200区段的错误.
@property (nonatomic, strong) NSError *error;

/// 请求状态.
@property (nonatomic, assign, readonly) DZChainRequestState state;

/// 成功和失败的回调队列，默认是主队列
@property (nonatomic, strong) dispatch_queue_t completionQueue;

@property (nonatomic, copy) DZChainRequestSuccessCallback successCallback;
@property (nonatomic, copy) DZChainRequestFailureCallback failureCallback;


/**
 *  初始化方法，请求会按照`requests`数组的顺序来依次请求.
 *
 *  @param requests 所有的请求数组.
 */
- (instancetype)initWithRequests:(NSArray<DZBaseRequest *>*) requests;

/// 开始请求.
- (void)start;

- (void)startChainRequestSuccessCallback:(DZChainRequestSuccessCallback)success failureCallback:(DZChainRequestFailureCallback)failure;

/// 取消请求.
- (void)cancel;

@end



@interface DZChainRequestManager : NSObject

+ (instancetype)sharedManager;

- (void)addChainRequest:(DZChainRequest *)chainRequest;

- (void)removeChainRequest:(DZChainRequest *)chainRequest;

@end

