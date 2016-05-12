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

@end
