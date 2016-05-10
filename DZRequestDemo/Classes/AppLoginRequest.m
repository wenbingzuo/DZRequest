//
//  AppLoginRequest.m
//  DZRequestDemo
//
//  Created by Wenbing Zuo on 5/9/16.
//  Copyright © 2016 DaZuo. All rights reserved.
//

#import "AppLoginRequest.h"

@implementation AppLoginRequest

- (instancetype)initWithUsername:(NSString *)username password:(NSString *)password {
    self = [super init];
    if (self) {
        self.username = username;
        self.password = password;
    }
    return self;
}

- (NSString *)requestURL {
    return @"/v1/user/login";
}

- (DZRequestMethod)requestMethod {
    return DZRequestMethodPOST;
}

- (id)requestParameters {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params dz_setNilableValue:self.username forKey:@"phone"];
    [params dz_setNilableValue:self.password forKey:@"password"];
    return params;
}

@end
