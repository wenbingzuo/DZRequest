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
    DZRequestSerializerTypeHTTP = 0, ///<非JSON格式，`x-www-form-urlencoded`表单.
    DZRequestSerializerTypeJSON ///<JSON格式
};

typedef NS_ENUM(NSUInteger, DZResponseSerializerType) {
    DZResponseSerializerTypeHTTP= 0, ///<服务器返回的什么数据就是什么数据
    DZResponseSerializerTypeJSON ///<服务器返回JSON数据
};

/// 这块使用`__kindof`关键字的好处是`request`参数可以是`DZBaseRequest`的子类.
typedef void(^DZRequestCompletionCallback)(__kindof DZBaseRequest *request);
typedef void(^DZRequestConstructionCallback)(id<AFMultipartFormData> formData);
typedef void(^DZRequestUploadProgressCallback)(NSProgress *progress);

@interface DZBaseRequest : NSObject

/// 每次请求的实体.
@property (nonatomic, strong) NSURLSessionDataTask *task;

///==============================================
/// @name Request
///==============================================

@property (nonatomic, assign) BOOL showActivityIndicator;

#pragma mark - 请求配置参数
/// 请求的baseURL.
@property (nonatomic, copy) NSString *requestBaseURL;

/// 请求的URL，可以是完整路径，也可以是完整路径去掉baseURL.
@property (nonatomic, copy) NSString *requestURL;

/// 请求的方法，默认是`DZRequestMethodGET`.
@property (nonatomic, assign) DZRequestMethod requestMethod;

/// 请求的超时时间，默认是20.
@property (nonatomic, assign) NSTimeInterval requestTimeoutInterval;

/// 全部请求带的请求头.
@property (nonatomic, strong) NSDictionary *requestDefaultHeader;

/// 请求头信息. 优先级高于defaultHeader.
@property (nonatomic, strong) NSDictionary *requestHeader;

/// 请求参数.
@property (nonatomic, strong) id requestParameters;

/// POST请求带文件上传应在这块配置.
@property (nonatomic, copy) DZRequestConstructionCallback requestConstructionCallback;

/// 请求的参数处理，默认是`DZRequestSerializerTypeJSON`.
@property (nonatomic, assign) DZRequestSerializerType requestSerializerType;

/// 响应的解析方式，默认是`DZResponseSerializerTypeJSON`
@property (nonatomic, assign) DZResponseSerializerType responseSerializerType;

#pragma mark - 请求方法及回调处理

@property (nonatomic, copy) DZRequestCompletionCallback requestSuccessCallback; ///<响应状态码在200区间段.
@property (nonatomic, copy) DZRequestCompletionCallback requestFailureCallback; ///<响应状态码在非200区间段. 取消也会回调这块，需要进行处理.

@property (nonatomic, copy) DZRequestUploadProgressCallback uploadProgressCallback; /// 可以获取上传文件的进度.

- (void)start;
- (void)startRequestWithSuccessCallback:(DZRequestCompletionCallback)success failureCallback:(DZRequestCompletionCallback)failure;
- (void)setSuccessCallback:(DZRequestCompletionCallback)success failure:(DZRequestCompletionCallback)failure;

- (void)cancel;

///==============================================
/// @name Response
///==============================================

#pragma mark - 响应结果的获取

@property (nonatomic, strong) id responseObject;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, assign, readonly) NSInteger responseStatusCode;

@end



@interface DZBaseRequest (DZRequestAdd)

@property (nonatomic, copy) BOOL (^responseFilterCallback)(DZBaseRequest *request);

@end

