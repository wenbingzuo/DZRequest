//
//  DZBatchRequestManager.h
//  DZNetworking
//
//  Created by Wenbing Zuo on 5/6/16.
//  Copyright © 2016 DaZuo. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DZBatchRequest;

@interface DZBatchRequestManager : NSObject

+ (instancetype)sharedManager;

- (void)addBatchRequest:(DZBatchRequest *)batchRequest;

- (void)removeBatchRequest:(DZBatchRequest *)batchRequest;

@end
