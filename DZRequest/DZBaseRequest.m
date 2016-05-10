//
//  DZBaseRequest.m
//  DZNetworking
//
//  Created by Wenbing Zuo on 5/3/16.
//  Copyright © 2016 DaZuo. All rights reserved.
//

#import "DZBaseRequest.h"
#import "DZRequestManager.h"
#import <objc/runtime.h>

@implementation DZBaseRequest

- (instancetype)init {
    self = [super init];
    if (self) {
        self.requestMethod = DZRequestMethodGET;
        self.requestTimeoutInterval = 20;
        self.requestSerializerType = DZRequestSerializerTypeJSON;
        self.responseSerializerType = DZResponseSerializerTypeJSON;
    }
    return self;
}

- (void)start {
    [[DZRequestManager sharedManager] addRequest:self];
}

- (void)startRequestWithSuccessCallback:(DZRequestCompletionCallback)success failureCallback:(DZRequestCompletionCallback)failure {
    [self setSuccessCallback:success failure:failure];
    [self start];
}

- (void)setSuccessCallback:(DZRequestCompletionCallback)success failure:(DZRequestCompletionCallback)failure {
    self.requestSuccessCallback = success;
    self.requestFailureCallback = failure;
}

- (void)cancel {
    [[DZRequestManager sharedManager] removeRequest:self];
}

- (NSInteger)responseStatusCode {
    return [(NSHTTPURLResponse *)self.task.response statusCode];
}

@end



@implementation DZBaseRequest (DZRequestAdd)

@dynamic responseFilterCallback;

- (void)setResponseFilterCallback:(BOOL (^)(DZBaseRequest *))responseFilterCallback {
    objc_setAssociatedObject(self, _cmd, responseFilterCallback, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL (^)(DZBaseRequest *))responseFilterCallback {
    return objc_getAssociatedObject(self, @selector(setResponseFilterCallback:));
}

@end
