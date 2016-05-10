//
//  AppDemoDataController.h
//  DZNetworking
//
//  Created by Wenbing Zuo on 5/9/16.
//  Copyright © 2016 DaZuo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^AppDemoDataCompletionCallback)(NSError *error);

@interface AppDemoDataController : NSObject

@property (nonatomic, strong, readonly) id result;

- (void)sendLoginRequest:(NSString *)name password:(NSString *)password callback:(AppDemoDataCompletionCallback)callback;

@end
