
//
//  MWVTimerModule.m
//  MixWeb
//
//  Created by Eric Lung on 2018/8/7.
//  Copyright © 2018年 YOOEE. All rights reserved.
//

#import "MWVTimerModule.h"
#import <MixExtention/MixExtention.h>

@interface MWVTimerModule ()

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation MWVTimerModule

MIX_WEBVIEW_MODULE_INIT

- (void)setup
{
    __weak typeof(self) weaks = self;
    [self.webView registerBridgeHandler:@"startTimer" handler:^(MixWebValue *value, MixWebJSResponseCallback responseCallback) {
        NSString *func = [value stringK:@"func"];
        if (!func || [func isEqualToString:@""]) return;

        float time = [value floatK:@"timeinterval"];
        if (time <= CGFLOAT_MIN) time = 1000.0;
        time = time / 1000;
        BOOL repeats = [value boolK:@"repeats"];
        BOOL fire = [value boolK:@"fire"];

        [weaks removeTimer];
        weaks.timer = [NSTimerMixExtention scheduledTimerWithTimeInterval:time repeats:repeats block:^(NSTimer *timer) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *script = [NSString stringWithFormat:@"if (typeof %@ == \"function\") %@();", func, func];
                [weaks.webView stringByEvaluatingJavaScriptFromString:script];
            });
        }];
        [[NSRunLoop mainRunLoop] addTimer:weaks.timer forMode:NSRunLoopCommonModes];
        if (fire) [weaks.timer fire];
    }];

    [self.webView registerBridgeHandler:@"removeTimer" handler:^(MixWebValue *value, MixWebJSResponseCallback responseCallback) {
        [weaks removeTimer];
    }];
}

- (void)removeTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)dealloc
{
    [self removeTimer];
}

@end
