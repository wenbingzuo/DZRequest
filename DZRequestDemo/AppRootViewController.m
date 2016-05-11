//
//  AppRootViewController.m
//  DZRequestDemo
//
//  Created by Wenbing Zuo on 5/11/16.
//  Copyright © 2016 DaZuo. All rights reserved.
//

#import "AppRootViewController.h"
#import "AppNormalViewController.h"
#import "AppSuggestViewController.h"

@interface AppRootViewController ()

@end

@implementation AppRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [UIView new];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rootCellIdentifier" forIndexPath:indexPath];
    cell.textLabel.text = indexPath.row==0?@"一般用法":@"推荐用法";
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *vc;
    if (indexPath.row == 0) {
        AppNormalViewController *normalVC = [AppNormalViewController new];
        vc = normalVC;
    } else {
        AppSuggestViewController *suggestVC = [AppSuggestViewController new];
        vc = suggestVC;
    }
    [self.navigationController pushViewController:vc animated:YES];
}

@end
