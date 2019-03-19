//
//  MWVCTitleModule.m
//  MixWebDemo
//
//  Created by Eric Lung on 2019/2/22.
//  Copyright © 2019 Eric. All rights reserved.
//

#import "MWVCTitleModule.h"
#import "MixWebUtils.h"

@implementation MWVCTitleModule

MIX_WEB_MODULE_INIT

- (void)setup
{
    _config = MixWebValueI(@{@"useHtmlTitle": @(YES), @"color": @"#000"});
    for (NSString *key in [self keys]) {
        [self.config addObserver:self forKeyPath:key options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    }
}

/**
 title: 标题
 -  useHtmlTitle: 是否使用HTML的标题, 默认YES,
 -  color: 颜色, 默认#000,
 -  text: 文字,
 */
- (BOOL)shouldMergeConfig:(id)value forKey:(NSString *)key
{
    if (![key isEqualToString:@"title"]) return NO;
    if ([value isKindOfClass:[NSDictionary class]]) {
        [self.config merge:value];
    }
    else if ([value isKindOfClass:[NSString class]]) {
        [self.config set:value key:@"text"];
    }
    return YES;
}

- (NSArray<NSString *> *)keys
{
    return @[@"color", @"text"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"color"]) {
        UIColor *color = [self.config colorK:@"color"];
        if (!color) color = [MixWebColor hex:@"#000"];
        NSMutableDictionary *atts = [self.vc.mixE.item.navigationBarTitleTextAttributes mutableCopy];
        if (!atts) atts = [NSMutableDictionary new];
        atts[NSForegroundColorAttributeName] = color;
        self.vc.mixE.item.navigationBarTitleTextAttributes = atts;
    }
    else if ([keyPath isEqualToString:@"text"]) {
        self.vc.navigationItem.title = [self.config stringK:@"text"];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if ([self.config boolK:@"useHtmlTitle"]) {
        NSString *title = [self.vc.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
        [self.config set:title key:@"text"];
    }
}

- (void)dealloc
{
    for (NSString *key in [self keys]) {
        [self.config removeObserver:self forKeyPath:key];
    }
}

@end

