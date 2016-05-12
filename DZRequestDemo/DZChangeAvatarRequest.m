//
//  DZChangeAvatarRequest.m
//  DZRequestDemo
//
//  Created by Wenbing Zuo on 5/13/16.
//  Copyright © 2016 DaZuo. All rights reserved.
//

#import "DZChangeAvatarRequest.h"
#import "NSMutableDictionary+DZRequest.h"

@implementation DZChangeAvatarRequest

- (NSDictionary *)requestDefaultHeader {
    NSMutableDictionary *header = [NSMutableDictionary dictionary];
    [header dz_setNilableValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"cookie"]  forKey:@"Authorization"];
    return header;
}

- (DZRequestMethod)requestMethod {
    return DZRequestMethodPOST;
}

- (NSString *)requestURL {
    return @"https://api.dongqiudi.com/users/update";
}

- (DZRequestConstructionCallback)requestConstructionCallback {
    return ^(id<AFMultipartFormData> formData) {
        NSData *imageData = UIImageJPEGRepresentation(self.avatar, 1);
        [formData appendPartWithFileData:imageData name:@"avatar" fileName:@"avatar.jpg" mimeType:@"image/jpeg"];
    };
}

@end
