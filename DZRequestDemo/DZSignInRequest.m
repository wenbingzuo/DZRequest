//
//  DZSignInRequest.m
//  DZRequestDemo
//
//  Created by Wenbing Zuo on 5/13/16.
//  Copyright © 2016 DaZuo. All rights reserved.
//

#import "DZSignInRequest.h"
#import "NSMutableDictionary+DZRequest.h"

@implementation DZSignInRequest

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addAccessory:self];
    }
    return self;
}

- (DZRequestMethod)requestMethod {
    return DZRequestMethodPOST;
}

- (NSString *)requestBaseURL {
    return @"https://api.dongqiudi.com/v2";
}

- (NSString *)requestURL {
    return @"/user/login";
}

- (id)requestParameters {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params dz_setNilableValue:self.username forKey:@"username"];
    [params dz_setNilableValue:self.password forKey:@"password"];
    return params;
}

//- (void)requestWillStart:(id)request {
//    NSLog(@"%@ will start --> %@", [request class], [NSThread currentThread]);
//}
//
//- (void)requestDidStart:(id)request {
//    NSLog(@"%@ did start --> %@", [request class], [NSThread currentThread]);
//}
//
//- (void)requestWillStop:(id)request {
//    if (!self.error) {
//        [[NSUserDefaults standardUserDefaults] setObject:self.responseObject[@"user"][@"access_token"] forKey:@"accessToken"];
//    }
//}
//
//- (void)requestDidStop:(id)request {
//    NSLog(@"%@ did stop --> %@", [request class], [NSThread currentThread]);
//}

- (void)requestDidFinishSuccess {
    [[NSUserDefaults standardUserDefaults] setObject:self.responseObject[@"user"][@"access_token"] forKey:@"accessToken"];
}

@end
