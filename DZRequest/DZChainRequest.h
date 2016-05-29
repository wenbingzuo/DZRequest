//
//  DZChainRequest.h
//  DZNetworking
//
//  Created by Wenbing Zuo on 5/6/16.
//  Copyright © 2016 DaZuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DZBaseRequest.h"
@class DZChainRequest;

typedef void(^DZChainRequestSuccessCallback)(DZChainRequest *chainRequest, __kindof DZBaseRequest *request, id responseObject);
typedef void(^DZChainRequestFailureCallback)(DZChainRequest *chainRequest, __kindof DZBaseRequest *request, NSError *error);
typedef void(^DZChainRequestCancelCallback)(DZChainRequest *chainRequest);

@interface DZChainRequest : NSObject

@property (nonatomic, strong, readonly) NSArray *requests;
@property (nonatomic, strong) dispatch_queue_t completionQueue;

@property (nonatomic, strong, readonly) NSPointerArray *accessories;
- (void)addAccessory:(id<DZRequestAccessory>)accessory;

@property (nonatomic, copy) DZChainRequestSuccessCallback successCallback;
@property (nonatomic, copy) DZChainRequestFailureCallback failureCallback;
- (void)setSuccessCallback:(DZChainRequestSuccessCallback)success failureCallback:(DZChainRequestFailureCallback)failure;

- (instancetype)initWithRequests:(NSArray<DZBaseRequest *>*) requests;

- (void)start;
- (void)startChainRequestSuccessCallback:(DZChainRequestSuccessCallback)success failureCallback:(DZChainRequestFailureCallback)failure;

@property (nonatomic, copy) DZChainRequestCancelCallback cancelCallback;
- (void)cancel;
- (void)cancelWithCallback:(DZChainRequestCancelCallback)cancel;

@end



@interface DZChainRequestManager : NSObject

+ (instancetype)sharedManager;

- (void)addChainRequest:(DZChainRequest *)chainRequest;

- (void)removeChainRequest:(DZChainRequest *)chainRequest;

@end

