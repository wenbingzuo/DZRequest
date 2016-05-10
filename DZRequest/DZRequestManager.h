//
//  DZRequestManager.h
//  DZNetworking
//
//  Created by Wenbing Zuo on 5/4/16.
//  Copyright © 2016 DaZuo. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DZBaseRequest;

@interface DZRequestManager : NSObject

+ (instancetype)sharedManager;

- (void)addRequest:(DZBaseRequest *)request;

- (void)removeRequest:(DZBaseRequest *)request;

@end
