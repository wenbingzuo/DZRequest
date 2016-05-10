//
//  DZChainRequestManager.h
//  DZNetworking
//
//  Created by Wenbing Zuo on 5/7/16.
//  Copyright © 2016 DaZuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DZChainRequest;

@interface DZChainRequestManager : NSObject

+ (instancetype)sharedManager;

- (void)addChainRequest:(DZChainRequest *)chainRequest;

- (void)removeChainRequest:(DZChainRequest *)chainRequest;

@end
