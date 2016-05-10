//
//  DZRequestConst.h
//  DZNetworking
//
//  Created by Wenbing Zuo on 5/6/16.
//  Copyright © 2016 DaZuo. All rights reserved.
//
#import <Foundation/Foundation.h>

FOUNDATION_EXPORT void DZLog(NSString *format, ...);

#ifndef    weakify
#define weakify(x) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
autoreleasepool{} __weak typeof(x) __weak_##x##__ = x; \
_Pragma("clang diagnostic pop")
#endif


#ifndef    strongify
#define strongify(x) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
try{} @finally{} __strong typeof(x) x = __weak_##x##__; \
_Pragma("clang diagnostic pop")

#endif
