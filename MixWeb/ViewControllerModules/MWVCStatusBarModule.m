//
//  MWVCStatusBarModule.m
//  MixWebDemo
//
//  Created by Eric Lung on 2019/2/22.
//  Copyright © 2019 Eric. All rights reserved.
//

#import "MWVCStatusBarModule.h"

@implementation MWVCStatusBarModule

MIX_WEB_MODULE_INIT

- (void)setup
{
    _config = MixWebValueI(@{@"style": @"black"});
    
    for (NSString *key in [self keys]) {
        [self.config addObserver:self forKeyPath:key options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    }
}

/**
 statusBar: 静态栏
 -  hidden: bool 隐藏
 -  style: string 风格, black, white, 默认black
 */
- (BOOL)shouldMergeConfig:(id)value forKey:(NSString *)key
{
    if (![key isEqualToString:@"statusBar"]) return NO;
    [self.config merge:value];
    return YES;
}

- (NSArray<NSString *> *)keys
{
    return @[@"hidden", @"style"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"hidden"]) {
        self.vc.mixE.item.statusBarHidden = [self.config boolK:@"hidden"];
    }
    else if ([keyPath isEqualToString:@"style"]) {
        self.vc.mixE.item.statusBarStyle = [[self.config stringK:@"style"] isEqualToString:@"white"] ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
    }
}

- (void)dealloc
{
    for (NSString *key in [self keys]) {
        [self.config removeObserver:self forKeyPath:key];
    }
}

@end
