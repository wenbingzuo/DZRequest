# DZRequest
======

DZRequest is a simple wrapper of AFNetworking 3.0.

## Installation
======

### CocoaPods

``` bash
pod "DZRequest"
```

### Manual

Just drop the `DZRequest` folder to your project.

## Usage
======

### GET

``` objc
	DZBaseRequest *request = [DZBaseRequest new];
	request.url = @"http://api.com/example";
    [request startRequestSuccessCallback:^(__kindof DZBaseRequest *request, id responseObject) {

    } failureCallback:^(__kindof DZBaseRequest *request, NSError *error) {

    }];
```

### POST

``` objc
	DZBaseRequest *request = [DZBaseRequest new];
	request.url = @"http://api.com/example";
	request.requestMethod = DZRequestMethodPOST;
	request.requestParameters = {@"username":@"HAHA", @"password":@"******"};
    [request startRequestSuccessCallback:^(__kindof DZBaseRequest *request, id responseObject) {

    } failureCallback:^(__kindof DZBaseRequest *request, NSError *error) {

    }];
```

You can find more usage in the demo project.

[中文介绍](http://dazuo.github.io/2016/05/10/introduction-to-opensource-dzrequest/)