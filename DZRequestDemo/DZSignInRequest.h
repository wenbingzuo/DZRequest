//
//  DZSignInRequest.h
//  DZRequestDemo
//
//  Created by Wenbing Zuo on 5/13/16.
//  Copyright © 2016 DaZuo. All rights reserved.
//

#import "DZBaseRequest.h"

@interface DZSignInRequest : DZBaseRequest

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;

@end
