//
//  DZBaseRequest.h
//  DZNetworking
//
//  Created by Wenbing Zuo on 5/3/16.
//  Copyright © 2016 DaZuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
@class DZBaseRequest;

typedef NS_ENUM(NSUInteger, DZRequestMethod) {
    DZRequestMethodGET = 0,
    DZRequestMethodPOST,
    DZRequestMethodPUT,
    DZRequestMethodDELETE
};

typedef NS_ENUM(NSUInteger, DZRequestSerializerType) {
    DZRequestSerializerTypeHTTP = 0,
    DZRequestSerializerTypeJSON
};

typedef NS_ENUM(NSUInteger, DZResponseSerializerType) {
    DZResponseSerializerTypeHTTP= 0,
    DZResponseSerializerTypeJSON
};

typedef void(^DZRequestCompletionCallback)(__kindof DZBaseRequest *request);
typedef void(^DZRequestConstructionCallback)(id<AFMultipartFormData> formData);
typedef void(^DZRequestUploadProgressCallback)(NSProgress *progress);

@interface DZBaseRequest : NSObject

/// The task from `NSURLSession`.
@property (nonatomic, strong) NSURLSessionDataTask *task;

@property (nonatomic, assign) BOOL showActivityIndicator;

#pragma mark - Request
///==============================================
/// @name Request
///==============================================

@property (nonatomic, copy) NSString *requestBaseURL;
@property (nonatomic, copy) NSString *requestURL;
@property (nonatomic, assign) DZRequestMethod requestMethod; ///<default is `DZRequestMethodGET`.
@property (nonatomic, assign) NSTimeInterval requestTimeoutInterval; ///<default is 20.
@property (nonatomic, strong) NSDictionary *requestDefaultHeader;
@property (nonatomic, strong) NSDictionary *requestHeader;
@property (nonatomic, strong) id requestParameters;
@property (nonatomic, copy) DZRequestConstructionCallback requestConstructionCallback;
@property (nonatomic, assign) DZRequestSerializerType requestSerializerType;
@property (nonatomic, assign) DZResponseSerializerType responseSerializerType;

#pragma mark - Response
///==============================================
/// @name Response
///==============================================

@property (nonatomic, strong) id responseObject;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, assign, readonly) NSInteger responseStatusCode;

#pragma mark - Callback
///==============================================
/// @name Callback
///==============================================

@property (nonatomic, copy) DZRequestCompletionCallback requestSuccessCallback;
@property (nonatomic, copy) DZRequestCompletionCallback requestFailureCallback;
@property (nonatomic, copy) DZRequestUploadProgressCallback uploadProgressCallback;

- (void)start;
- (void)startRequestWithSuccessCallback:(DZRequestCompletionCallback)success failureCallback:(DZRequestCompletionCallback)failure;
- (void)setSuccessCallback:(DZRequestCompletionCallback)success failure:(DZRequestCompletionCallback)failure;

- (void)cancel;

@end

@interface DZBaseRequest (DZRequestAdd)

@property (nonatomic, copy) BOOL (^responseFilterCallback)(DZBaseRequest *request);

@end

