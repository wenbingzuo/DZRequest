//
//  NSMutableDictionary+DZRequest.m
//  DZNetworking
//
//  Created by Wenbing Zuo on 5/9/16.
//  Copyright © 2016 DaZuo. All rights reserved.
//

#import "NSMutableDictionary+DZRequest.h"

@implementation NSMutableDictionary (DZRequest)

- (void)dz_setNilableValue:(id)value forKey:(NSString *)key {
    if (!value) {
        [self removeObjectForKey:key];
        return;
    }
    [self setValue:value forKey:key];
}

@end
