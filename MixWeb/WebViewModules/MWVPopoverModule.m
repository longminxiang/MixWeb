//
//  MWVPopoverModule.m
//  MixWebDemo
//
//  Created by Eric Lung on 2017/10/25.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import "MWVPopoverModule.h"

@implementation MWVPopoverModule

MIX_WEBVIEW_MODULE_INIT

- (void)setup
{
    ///弹窗
    [self.webView registerBridgeHandler:@"popover" handler:^(MixWebValue *value, MixWebJSResponseCallback responseCallback) {
        NSString *urlString = [value stringK:@"url"];
        NSString *key = [value stringK:@"key"];

        CGRect frame = [UIScreen mainScreen].bounds;
        MixWebView *view = [[MixWebView alloc] initWithFrame:frame];
        view.tag = [MWVPopoverModule tagWithKey:key];
        view.scrollView.bounces = NO;
        view.backgroundColor = [UIColor clearColor];
        view.opaque = NO;
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        [view loadRequest:request];
        [[UIApplication sharedApplication].delegate.window addSubview:view];
        view.alpha = 0;
        [UIView animateWithDuration:0.25 animations:^{
            view.alpha = 1;
        }];
    }];

    ///退出弹窗
    [self.webView registerBridgeHandler:@"dismissPopover" handler:^(MixWebValue *value, MixWebJSResponseCallback responseCallback) {
        NSString *key = [value stringK:@"key"];
        NSInteger tag = [MWVPopoverModule tagWithKey:key];

        UIView *view = [[UIApplication sharedApplication].delegate.window viewWithTag:tag];
        [UIView animateWithDuration:0.25 animations:^{
            view.alpha = 0;
        } completion:^(BOOL finished) {
            [view removeFromSuperview];
            if (responseCallback) responseCallback(nil);
        }];
    }];
}

+ (NSInteger)tagWithKey:(NSString *)key
{
    if (!key) return 3001;

    static NSMutableDictionary *dict;
    static NSInteger tagIndex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dict = [NSMutableDictionary new];
        tagIndex = 3002;
    });

    NSInteger tag = [dict[key] integerValue];
    if (tag == 0) {
        tag = tagIndex++;
        dict[key] = @(tag);
    }
    return tag;
}

@end
