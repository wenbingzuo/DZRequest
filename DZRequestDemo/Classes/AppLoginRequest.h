//
//  AppLoginRequest.h
//  DZRequestDemo
//
//  Created by Wenbing Zuo on 5/9/16.
//  Copyright © 2016 DaZuo. All rights reserved.
//

#import "AppBaseRequest.h"

@interface AppLoginRequest : AppBaseRequest

- (instancetype)initWithUsername:(NSString *)username password:(NSString *)password;

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;

@end
