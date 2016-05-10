//
//  AppGetUserinfoRequest.m
//  DZRequestDemo
//
//  Created by Wenbing Zuo on 5/9/16.
//  Copyright © 2016 DaZuo. All rights reserved.
//

#import "AppGetUserinfoRequest.h"

@implementation AppGetUserinfoRequest

- (NSString *)requestURL {
    return @"/v1/user/getProfile";
}

- (id)requestParameters {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params dz_setNilableValue:@(self.userid) forKey:@"userid"];
    return params;
}

@end
