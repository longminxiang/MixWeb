//
//  MWVCNavBarModule.m
//  MixWebDemo
//
//  Created by Eric Lung on 2019/2/22.
//  Copyright © 2019 Eric. All rights reserved.
//

#import "MWVCNavBarModule.h"
#import <MixDevice/MixDevice-Swift.h>
#import "MixWebUtils.h"

@interface MWVCNavBarModule ()

@property (nonatomic, assign) BOOL didLoadView;

@end

@implementation MWVCNavBarModule

MIX_WEB_MODULE_INIT

- (void)setup
{
    _config = MixWebValueI(@{@"tintColor": @"#000", @"barTintColor": @"#FFF"});
    
    for (NSString *key in [self keys]) {
        [self.config addObserver:self forKeyPath:key options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    }
}

/**
 navBar: 导航栏
 -  hidden: bool 隐藏,
 -  tintColor: string 颜色, 默认#000
 -  barTintColor: string 背景颜色, 默认#FFF
 -  bottomLineHidden: bool 隐藏底部线条
 */
- (BOOL)shouldMergeConfig:(id)value forKey:(NSString *)key
{
    if (![key isEqualToString:@"navBar"]) return NO;
    [self.config merge:value];
    return YES;
}

- (NSArray<NSString *> *)keys
{
    return @[@"barTintColor", @"tintColor", @"hidden", @"bottomLineHidden"];
}

- (BOOL)isTabBarRootVC
{
    NSArray *vcs = self.vc.tabBarController.viewControllers;
    UINavigationController *nav = self.vc.navigationController;
    BOOL isTabBarRootVC = [vcs containsObject:self.vc] || ([vcs containsObject:nav] && [nav.viewControllers firstObject] == self.vc);
    return isTabBarRootVC;
}

- (void)viewDidLoad
{
    self.didLoadView = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self resetWebViewFrameWithAnimation:NO];
}

- (void)resetWebViewFrameWithAnimation:(BOOL)animated
{
    //view did load 后才重设frame
    if (!self.didLoadView) return;

    CGRect frame = self.vc.view.bounds;
    frame.origin.y = [self.config boolK:@"hidden"] ? 0 : [MixDevice shared].navigationBarHeight;
    CGFloat marginBottom = [self isTabBarRootVC] ? [MixDevice shared].tabBarHeight : 0;
    frame.size.height -= frame.origin.y + marginBottom;
    if (!CGRectEqualToRect(frame, self.vc.webView.frame)) {
        if (animated) {
            [UIView animateWithDuration:0.25 animations:^{
                self.vc.webView.frame = frame;
            }];
        }
        else {
            self.vc.webView.frame = frame;
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"barTintColor"]) {
        self.vc.mixE.item.navigationBarBarTintColor = [self.config colorK:@"barTintColor"];
    }
    else if ([keyPath isEqualToString:@"tintColor"]) {
        self.vc.mixE.item.navigationBarTintColor = [self.config colorK:@"tintColor"];
    }
    else if ([keyPath isEqualToString:@"hidden"]) {
        self.vc.mixE.item.navigationBarHidden = [self.config boolK:@"hidden"];
        [self resetWebViewFrameWithAnimation:YES];
    }
    else if ([keyPath isEqualToString:@"bottomLineHidden"]) {
        self.vc.mixE.item.navigationBarBottomLineHidden = [self.config boolK:@"bottomLineHidden"];
    }
}

- (void)dealloc
{
    for (NSString *key in [self keys]) {
        [self.config removeObserver:self forKeyPath:key];
    }
}

@end
