//
//  DZRequestManager.m
//  DZNetworking
//
//  Created by Wenbing Zuo on 5/4/16.
//  Copyright © 2016 DaZuo. All rights reserved.
//

#import "DZRequestManager.h"
#import "DZRequestConst.h"
#import "DZBaseRequest.h"
#import <AFNetworkActivityIndicatorManager.h>
#import "DZRequestConst.h"

@interface DZRequestManager ()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, strong) NSMutableDictionary *requests;

@end

@implementation DZRequestManager

+ (instancetype)sharedManager {
    static DZRequestManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [DZRequestManager new];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.sessionManager = [AFHTTPSessionManager manager];
        self.sessionManager.completionQueue = dispatch_queue_create("io.dazuo.github.request.session.completion.queue", DISPATCH_QUEUE_CONCURRENT);
        self.requests = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - Private

- (NSString *)_buildRequestURLWithRequest:(DZBaseRequest *)request {
    NSString *detailURL = request.requestURL;
    if ([[detailURL lowercaseString] hasPrefix:@"http"]) {
        return detailURL;
    }
    
    NSString *baseURL = request.requestBaseURL;
    if ([[baseURL lowercaseString] hasPrefix:@"http"]) {
        return [NSString stringWithFormat:@"%@%@", baseURL, detailURL.length==0?@"":detailURL];
    } else {
        DZLog(@"Error, wrong URL format.");
        return nil;
    }
}

- (NSDictionary *)_buildRequestHeaderWithRequest:(DZBaseRequest *)request {
    NSDictionary *defaultHeader = request.requestDefaultHeader;
    NSDictionary *normalHeader = request.requestHeader;
    
    NSMutableDictionary *header = [NSMutableDictionary dictionaryWithDictionary:defaultHeader];
    [header addEntriesFromDictionary:normalHeader];
    return header;
}

- (NSString *)_taskHashKey:(NSURLSessionDataTask *)task {
    return [NSString stringWithFormat:@"%lu", (unsigned long)[task hash]];
}

- (void)_addTask:(DZBaseRequest *)request {
    if (request.task) {
        NSString *key = [self _taskHashKey:request.task];
        @synchronized(self) {
            [self.requests setValue:request forKey:key];
        }
    }
}

- (void)_removeTask:(DZBaseRequest *)request {
    NSString *key = [self _taskHashKey:request.task];
    @synchronized(self) {
        [self.requests removeObjectForKey:key];
    }
}

- (void)_handleResponse:(NSURLSessionDataTask *)task response:(id)responseObject error:(NSError *)error {
    NSString *key = [self _taskHashKey:task];
    DZBaseRequest *request = self.requests[key];
    request.responseObject = responseObject;
    request.error = error;
    
    if (!error) {
        if (request.requestSuccessCallback) {
            request.requestSuccessCallback(request);
        }
    } else {
        if (request.requestFailureCallback) {
            request.requestFailureCallback(request);
        }
    }
    
    [self _removeTask:request];
}

#pragma mark - Public

- (void)addRequest:(DZBaseRequest *)request {
    DZRequestSerializerType requestSerializerType = request.requestSerializerType;
    switch (requestSerializerType) {
        case DZRequestSerializerTypeHTTP:{
            self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        } break;
        case DZRequestSerializerTypeJSON: {
            self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        } break;
        default:
            break;
    }
    self.sessionManager.requestSerializer.timeoutInterval = request.requestTimeoutInterval;
    NSDictionary *headers = [self _buildRequestHeaderWithRequest:request];
    for (id field in headers.allKeys) {
        id value = headers[field];
        if ([field isKindOfClass:[NSString class]] && [value isKindOfClass:[NSString class]]) {
            [self.sessionManager.requestSerializer setValue:value forHTTPHeaderField:field];
        } else {
            DZLog(@"Error, the key and value in HTTPRequestHeaders should be string.");
        }
    }
    
    
    DZResponseSerializerType responseSerializerType = request.responseSerializerType;
    switch (responseSerializerType) {
        case DZResponseSerializerTypeJSON:
            self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
            break;
        case DZResponseSerializerTypeHTTP:
            self.sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
            break;
        default:
            break;
    }
    self.sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"text/xml", @"text/plain", @"text/json", @"text/javascript", @"image/png", @"image/jpeg", @"application/json", nil];
    
    NSString *url = [self _buildRequestURLWithRequest:request];
    DZRequestMethod method = request.requestMethod;
    id params = request.requestParameters;
    DZRequestConstructionCallback constructionBlock = request.requestConstructionCallback;
    DZRequestUploadProgressCallback uploadProgressCallback = request.uploadProgressCallback;
    
    NSURLSessionDataTask *task = nil;
    switch (method) {
        case DZRequestMethodGET: {
            task = [self.sessionManager GET:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self _handleResponse:task response:responseObject error:nil];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self _handleResponse:task response:nil error:error];
            }];
        } break;
        
        case DZRequestMethodPOST: {
            if (constructionBlock) {
                task = [self.sessionManager POST:url parameters:params constructingBodyWithBlock:constructionBlock progress:uploadProgressCallback success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    [self _handleResponse:task response:responseObject error:nil];
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    [self _handleResponse:task response:nil error:error];
                }];
            } else {
                task = [self.sessionManager POST:url parameters:params progress:uploadProgressCallback success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    [self _handleResponse:task response:responseObject error:nil];
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    [self _handleResponse:task response:nil error:error];
                }];
            }
        } break;
            
        case DZRequestMethodPUT: {
            task = [self.sessionManager PUT:url parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self _handleResponse:task response:responseObject error:nil];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self _handleResponse:task response:nil error:error];
            }];
        } break;
            
        case DZRequestMethodDELETE: {
            task = [self.sessionManager DELETE:url parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self _handleResponse:task response:responseObject error:nil];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self _handleResponse:task response:nil error:error];
            }];
        } break;
        default:
            break;
    }
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = request.showActivityIndicator;
    request.task = task;
    [self _addTask:request];
}

- (void)removeRequest:(DZBaseRequest *)request {
    [request.task cancel];
//    [self _removeTask:request];
}

@end
