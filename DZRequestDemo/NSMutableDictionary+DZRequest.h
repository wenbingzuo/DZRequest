//
//  NSMutableDictionary+DZRequest.h
//  DZNetworking
//
//  Created by Wenbing Zuo on 5/9/16.
//  Copyright © 2016 DaZuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (DZRequest)

- (void)dz_setNilableValue:(id)value forKey:(NSString *)key;

@end
