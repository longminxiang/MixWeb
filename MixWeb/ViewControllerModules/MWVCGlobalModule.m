//
//  MWVCGlobalModule.m
//  MixWebDemo
//
//  Created by Eric Lung on 2019/2/22.
//  Copyright © 2019 Eric. All rights reserved.
//

#import "MWVCGlobalModule.h"
#import "MixWebUtils.h"

@implementation MWVCGlobalModule

MIX_WEB_MODULE_INIT

- (void)setup
{
    _config = MixWebValueI(@{@"bounces": @(YES), @"backgroundColor": @"#FFFFFF98"});
}

/**
 forceUIWebView: 强制使用UIWebView, 默认NO，只在初始化时起作用;
 disablePopGesture: 禁止滑动返回, 默认NO;
 bounces: 是否开启回弹效果，默认YES;
 backgroundColor: 背影颜色，默认#FFFFFF98;
 */
- (BOOL)shouldMergeConfig:(id)value forKey:(NSString *)key
{
    if (![[self keys] containsObject:key]) return NO;
    [self.config set:value key:key];
    return YES;
}

- (NSArray *)keys
{
    return @[@"disablePopGesture", @"bounces", @"backgroundColor"];
}

- (void)viewDidLoad
{
    for (NSString *key in [self keys]) {
        [self.config addObserver:self forKeyPath:key options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"disablePopGesture"]) {
        self.vc.mixE.item.disableInteractivePopGesture = [self.config boolK:@"disablePopGesture"];
    }
    else if ([keyPath isEqualToString:@"bounces"]) {
        self.vc.webView.scrollView.bounces = [self.config boolK:@"bounces"];
    }
    else if ([keyPath isEqualToString:@"backgroundColor"]) {
        self.vc.view.backgroundColor = [self.config colorK:@"backgroundColor"];
    }
}

- (void)dealloc
{
    for (NSString *key in [self keys]) {
        [self.config removeObserver:self forKeyPath:key];
    }
}

@end
