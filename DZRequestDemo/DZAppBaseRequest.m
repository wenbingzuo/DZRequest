//
//  DZAppBaseRequest.m
//  DZRequestDemo
//
//  Created by Wenbing Zuo on 5/22/16.
//  Copyright © 2016 DaZuo. All rights reserved.
//

#import "DZAppBaseRequest.h"
#import "NSMutableDictionary+DZRequest.h"

@implementation DZAppBaseRequest

- (NSString *)requestBaseURL {
    return @"https://api.dongqiudi.com";
}

- (NSDictionary *)requestDefaultHeader {
    NSMutableDictionary *header = [NSMutableDictionary dictionary];
    [header dz_setNilableValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"]  forKey:@"Authorization"];
    return header;
}

@end
