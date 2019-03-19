
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
        float time = [value floatK:@"timeinterval"] / 1000;
        BOOL repeats = [value boolK:@"repeats"];
        [weaks startTimer:func time:time repeats:repeats];
    }];

    [self.webView registerBridgeHandler:@"removeTimer" handler:^(MixWebValue *value, MixWebJSResponseCallback responseCallback) {
        [weaks removeTimer];
    }];
}

- (void)startTimer:(NSString *)func time:(float)time repeats:(BOOL)repeats
{
    [self removeTimer];
    __weak typeof(self) weaks = self;
    self.timer = [NSTimerMixExtention scheduledTimerWithTimeInterval:time repeats:repeats block:^(NSTimer *timer) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *script = [NSString stringWithFormat:@"if(typeof %@ == \"function\") %@();", func, func];
            [weaks.webView stringByEvaluatingJavaScriptFromString:script];
        });
    }];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
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
