//
//  AppBaseRequest.m
//  DZNetworking
//
//  Created by Wenbing Zuo on 5/9/16.
//  Copyright © 2016 DaZuo. All rights reserved.
//

#import "AppBaseRequest.h"

@implementation AppBaseRequest

- (NSString *)requestBaseURL {
    return @"https://www.api.com";
}

- (NSDictionary *)requestDefaultHeader {
    NSMutableDictionary *header = [NSMutableDictionary dictionary];
    [header dz_setNilableValue:nil forKey:@"Authorization"];
    return header;
}

@end
