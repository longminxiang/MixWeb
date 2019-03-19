//
//  MWVSystemModule.m
//  MixWebDemo
//
//  Created by Eric Lung on 2017/10/11.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import "MWVSystemModule.h"
#import <MixDevice/MixDevice-Swift.h>

@implementation MWVSystemModule

MIX_WEBVIEW_MODULE_INIT

- (void)setup
{
    ///打电话
    [self.webView registerBridgeHandler:@"makePhoneCall" handler:^(MixWebValue *value, MixWebJSResponseCallback responseCallback) {
        NSString *phoneNumber = [value stringK:@"phoneNumber"];
        NSString *url = [NSString stringWithFormat:@"tel:%@", phoneNumber];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }];

    ///设置系统剪贴板的内容
    [self.webView registerBridgeHandler:@"setClipboardData" handler:^(MixWebValue *value, MixWebJSResponseCallback responseCallback) {
        NSString *data = [value stringK:@"data"];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = data;
    }];

    ///获取系统剪贴板的内容
    [self.webView registerBridgeHandler:@"getClipboardData" handler:^(MixWebValue *value, MixWebJSResponseCallback responseCallback) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        id data = pasteboard.string ? pasteboard.string : [NSNull null];
        if (responseCallback) responseCallback(@{@"data": data});
    }];

    ///设置屏幕亮度
    [self.webView registerBridgeHandler:@"setScreenBrightness" handler:^(MixWebValue *value, MixWebJSResponseCallback responseCallback) {
        float val = [value floatK:@"value"];
        [UIScreen mainScreen].brightness = val;
    }];

    ///获取屏幕亮度
    [self.webView registerBridgeHandler:@"getScreenBrightness" handler:^(MixWebValue *value, MixWebJSResponseCallback responseCallback) {
        float val = [UIScreen mainScreen].brightness;
        if (responseCallback) responseCallback(@{@"value": @(val)});
    }];
}

- (NSString *)initialJavaScript
{
    NSString *string = [[MixDevice shared] jsonString];
    return string ? [NSString stringWithFormat:@"$app.device=%@;\n", string] : nil;;
}

@end
