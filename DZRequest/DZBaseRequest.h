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
    DZRequestMethodDELETE,
    DZRequestMethodPATCH,
    DZRequestMethodHEAD,
};

typedef NS_ENUM(NSUInteger, DZRequestSerializerType) {
    DZRequestSerializerTypeHTTP = 0,
    DZRequestSerializerTypeJSON,
};

typedef NS_ENUM(NSUInteger, DZResponseSerializerType) {
    DZResponseSerializerTypeHTTP = 0,
    DZResponseSerializerTypeJSON,
};


/**
 This protocol is used in `DZBaseRequest`, `DZBatchRequest` and `DZChainRequest`.
 Call super if the request itself want to do the hook.
 */
@protocol DZRequestAccessory <NSObject>

@optional

/**
 This method will be invoked immediately when invoking `-start` method.
 */
- (void)requestWillStart:(id)request;
/**
 This method will be invoked immediately when resume the `task`.
 */
- (void)requestDidStart:(id)request;
/**
 This method will be invoked before `successCallback` or `failureCallback` is invoked.
 */
- (void)requestWillStop:(id)request;
/**
 This method will be invoked after `successCallback` or `failureCallback` is invoked.
 */
- (void)requestDidStop:(id)request;

@end

typedef NSError *(^DZRequestResponseFilterCallback)(__kindof DZBaseRequest *request, id responseObject);
typedef void(^DZRequestSuccessCallback)(__kindof DZBaseRequest *request, id responseObject);
typedef void(^DZRequestFailureCallback)(__kindof DZBaseRequest *request, NSError *error);
typedef void(^DZRequestCancelCallback)(__kindof DZBaseRequest *request);
typedef void(^DZRequestConstructionCallback)(id<AFMultipartFormData> formData);
typedef void(^DZRequestUploadProgressCallback)(NSProgress *progress);

@interface DZBaseRequest : NSObject

/**
 The data task from `NSURLSession`.
*/
@property (nonatomic, strong) NSURLSessionDataTask *task;

@property (nonatomic, strong, readonly) NSMutableArray *accessories;
- (void)addAccessory:(id<DZRequestAccessory>)accessory;

///----------------------------
/// @name Request Configuration
///----------------------------

@property (nonatomic, copy) NSString *requestBaseURL;
@property (nonatomic, copy) NSString *requestURL;
@property (nonatomic, assign) DZRequestMethod requestMethod;
@property (nonatomic, assign) NSTimeInterval requestTimeoutInterval;
@property (nonatomic, strong) NSDictionary *requestDefaultHeader;
@property (nonatomic, strong) NSDictionary *requestHeader;
@property (nonatomic, strong) id requestParameters;
@property (nonatomic, copy) DZRequestConstructionCallback requestConstructionCallback;
@property (nonatomic, assign) DZRequestSerializerType requestSerializerType;
@property (nonatomic, assign) BOOL showActivityIndicator;

///---------------
/// @name Response
///---------------

@property (nonatomic, assign) DZResponseSerializerType responseSerializerType;
@property (nonatomic, strong) id responseObject;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, assign, readonly) NSInteger responseStatusCode;
@property (nonatomic, strong, readonly) NSDictionary *responseHeader;

///---------------
/// @name Callback
///---------------

/**
 If the request is a multipart `POST` request, this block will be invoked multiple times until upload finishes.
 */
@property (nonatomic, copy) DZRequestUploadProgressCallback uploadProgressCallback;
@property (nonatomic, copy) DZRequestResponseFilterCallback responseFilterCallback;
- (void)setResponseFilterCallback:(DZRequestResponseFilterCallback)responseFilterCallback;

@property (nonatomic, copy) DZRequestSuccessCallback successCallback;
@property (nonatomic, copy) DZRequestFailureCallback failureCallback;
- (void)setSuccessCallback:(DZRequestSuccessCallback)success failure:(DZRequestFailureCallback)failure;

- (void)start;
- (void)startRequestSuccessCallback:(DZRequestSuccessCallback)success failureCallback:(DZRequestFailureCallback)failure;

/**
 Indicate whether the request can cancel or not.
 */
@property (nonatomic, assign, readonly) BOOL canCancel;

/**
 When the request is cancelled, the block will be invoked.
 */
@property (nonatomic, copy) DZRequestCancelCallback cancelCallback;

/**
 Cancel the current task. A specific task can be cancelled for only once.
 It's recommended to check whether the request can cancel or not by using `canCancel` before call this method.
 */
- (void)cancel;

/**
 Cancel the current task with a specific block.
 */
- (void)cancelWithCallback:(DZRequestCancelCallback)cancel;

/**
 Revoked when request succeeds.
 */
- (void)requestDidFinishSuccess;

/**
 Revoked when request fails.
 */
- (void)requestDidFinishFailure;

@end



@interface DZRequestManager : NSObject

///---------------------
/// @name Instialization
///---------------------

/**
 Creates and returns the shared `DZRequestManager` object.
 */
+ (instancetype)sharedManager;

///------------------------
/// @name Managing Requests
///------------------------

/**
 Add and start the request.
 
 @param request The request to operate.
 */
- (void)addRequest:(DZBaseRequest *)request;

/**
 Cancel and remove the request.
 
 @param request The request to cancel.
 */
- (void)removeRequest:(DZBaseRequest *)request;

@end
