//
//  MWVInteractiveModule.m
//  MixWebDemo
//
//  Created by Eric Lung on 2017/10/10.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import "MWVInteractiveModule.h"
#import "MixWebUtils.h"

@implementation MWVInteractiveModule

MIX_WEBVIEW_MODULE_INIT

- (void)setup
{
    __weak typeof(self) weaks = self;

    [self.webView registerBridgeHandler:@"showTextHUD" handler:^(MixWebValue *value, MixWebJSResponseCallback responseCallback) {
        NSString *text = [value stringK:@"text"];
        float delay = [value floatK:@"delay"];
        BOOL bottom = [value boolK:@"bottom"];
        if (delay <= 0) delay = 1;
        [MixWebHUD showText:text delay:delay bottom:bottom];
    }];

    [self.webView registerBridgeHandler:@"showHUD" handler:^(MixWebValue *value, MixWebJSResponseCallback responseCallback) {
        [MixWebHUD showInView:weaks.webView];
    }];

    [self.webView registerBridgeHandler:@"hideHUD" handler:^(MixWebValue *value, MixWebJSResponseCallback responseCallback) {
        [MixWebHUD hideInView:weaks.webView];
    }];

    [self.webView registerBridgeHandler:@"showAlert" handler:^(MixWebValue *value, MixWebJSResponseCallback responseCallback) {
        NSString *title = [value stringK:@"title"];
        NSString *message = [value stringK:@"message"];
        NSString *cancelTitle = [value stringK:@"cancelTitle"];
        NSString *confirmTitle = [value stringK:@"confirmTitle"];
        [MWVInteractiveModule showAlertWithType:UIAlertControllerStyleAlert title:title message:message cancelTitle:cancelTitle otherTitles:@[confirmTitle] block:^(NSInteger buttonIndex) {
            if (responseCallback) responseCallback(@{@"buttonIndex": @(buttonIndex)});
        }];
    }];

    [self.webView registerBridgeHandler:@"showActionSheet" handler:^(MixWebValue *value, MixWebJSResponseCallback responseCallback) {
        NSString *title = [value stringK:@"title"];
        NSString *cancelTitle = [value stringK:@"cancelTitle"];
        NSArray *otherTitles = [value arrayK:@"otherTitles"];
        [MWVInteractiveModule showAlertWithType:UIAlertControllerStyleActionSheet title:title message:nil cancelTitle:cancelTitle otherTitles:otherTitles block:^(NSInteger buttonIndex) {
            if (responseCallback) responseCallback(@{@"buttonIndex": @(buttonIndex)});
        }];
    }];
}

+ (void)showAlertWithType:(UIAlertControllerStyle)style
                    title:(NSString *)title
                  message:(NSString *)message
              cancelTitle:(NSString *)cancelTitle
              otherTitles:(NSArray<NSString *> *)otherTitles
                    block:(void (^)(NSInteger buttonIndex))block
{

    if (!title && style != UIAlertControllerStyleActionSheet) title = @"提示";
    if (!cancelTitle) cancelTitle = @"取消";

    UIAlertController *vc = [UIAlertController alertControllerWithTitle:title  message:message preferredStyle:style];

    if (otherTitles.count) {
        for (int i = 0; i < otherTitles.count; i++) {
            NSString *otitle = otherTitles[i];
            UIAlertActionStyle actionStyle = i == 0 && style == UIAlertControllerStyleActionSheet ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault;
            UIAlertAction *action = [UIAlertAction actionWithTitle:otitle style:actionStyle handler:^(UIAlertAction * _Nonnull action) {
                if (block) block(i + 1);
            }];
            [vc addAction:action];
        }
    }
    else {
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (block) block(1);
        }];
        [vc addAction:action];
    }
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (block) block(0);
    }];
    [vc addAction:cancelAction];

    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (!rootVC) {
        rootVC = [[UIApplication sharedApplication].delegate window].rootViewController;
    }
    [rootVC presentViewController:vc animated:YES completion:nil];
}

@end
