//
//  MWVCFailedViewModule.m
//  MixWebDemo
//
//  Created by Eric Lung on 2019/2/22.
//  Copyright © 2019 Eric. All rights reserved.
//

#import "MWVCFailedViewModule.h"

@interface MWVCFailedViewModule ()

@property (nonatomic, readonly) UIView *failedView;

@end

@implementation MWVCFailedViewModule
@synthesize failedView = _failedView;

MIX_WEB_MODULE_INIT

- (void)setup
{
    
}

- (BOOL)shouldMergeConfig:(id)value forKey:(NSString *)key
{
    return NO;
}

- (UIView *)failedView
{
    if (!_failedView) {
        UIButton *errorView = [[UIButton alloc] initWithFrame:self.vc.webView.bounds];
        [errorView setTitle:@"点击屏幕重新加载" forState:UIControlStateNormal];
        errorView.titleLabel.font = [UIFont systemFontOfSize:14];
        [errorView setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [errorView addTarget:self action:@selector(errorViewDidTouched) forControlEvents:UIControlEventTouchUpInside];
        [self.vc.webView addSubview:errorView];
        _failedView = errorView;
    }
    return _failedView;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [_failedView removeFromSuperview];
    _failedView = nil;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_failedView removeFromSuperview];
    _failedView = nil;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.vc.webView bringSubviewToFront:self.failedView];
}

- (void)errorViewDidTouched
{
    [self.vc.webView reloadOriginRequest];
}

@end
