//
//  MWVCProgressModule.m
//  MixWebDemo
//
//  Created by Eric Lung on 2019/2/21.
//  Copyright © 2019 Eric. All rights reserved.
//

#import "MWVCProgressModule.h"
#import "MixWebUtils.h"

NSString *MWVCCompleteRPCURL = @"mixwebviewprogressproxy:///complete";

const float MWVCInitialProgressValue = 0.1f;
const float MWVCInteractiveProgressValue = 0.5f;
const float MWVCFinalProgressValue = 0.9f;

@interface MWVCProgressView : UIView

@property (nonatomic) UIView *progressBarView;
@property (nonatomic) NSTimeInterval barAnimationDuration; // default 0.1
@property (nonatomic) NSTimeInterval fadeAnimationDuration; // default 0.27
@property (nonatomic) NSTimeInterval fadeOutDelay; // default 0.1

- (void)setProgress:(float)progress animated:(BOOL)animated;

@end

@implementation MWVCProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _progressBarView = [[UIView alloc] initWithFrame:self.bounds];
        _progressBarView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        UIColor *tintColor = [UIColor colorWithRed:22.f / 255.f green:126.f / 255.f blue:251.f / 255.f alpha:1.0]; // iOS7 Safari bar color
        if ([UIApplication.sharedApplication.delegate.window respondsToSelector:@selector(setTintColor:)] && UIApplication.sharedApplication.delegate.window.tintColor) {
            tintColor = UIApplication.sharedApplication.delegate.window.tintColor;
        }
        _progressBarView.backgroundColor = tintColor;
        [self addSubview:_progressBarView];

        _barAnimationDuration = 0.27f;
        _fadeAnimationDuration = 0.27f;
        _fadeOutDelay = 0.1f;
    }
    return self;
}

- (void)setProgress:(float)progress animated:(BOOL)animated
{
    BOOL isGrowing = progress > 0.0;
    [UIView animateWithDuration:(isGrowing && animated) ? _barAnimationDuration : 0.0 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect frame = self.progressBarView.frame;
        frame.size.width = progress * self.bounds.size.width;
        self.progressBarView.frame = frame;
    } completion:nil];

    if (progress >= 1.0) {
        [UIView animateWithDuration:animated ? _fadeAnimationDuration : 0.0 delay:_fadeOutDelay options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.progressBarView.alpha = 0.0;
        } completion:^(BOOL completed){
            CGRect frame = self.progressBarView.frame;
            frame.size.width = 0;
            self.progressBarView.frame = frame;
        }];
    }
    else {
        [UIView animateWithDuration:animated ? _fadeAnimationDuration : 0.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.progressBarView.alpha = 1.0;
        } completion:nil];
    }
}

@end

@interface MWVCProgressModule ()

@property (nonatomic, strong) MWVCProgressView *progressView;

@property (nonatomic, readonly) BOOL enable;

@property (nonatomic) float progress;

@property (nonatomic, assign) NSUInteger loadingCount;
@property (nonatomic, assign) NSUInteger maxLoadCount;
@property (nonatomic, strong) NSURL *currentURL;
@property (nonatomic, assign) BOOL interactive;

@end

@implementation MWVCProgressModule

MIX_WEB_MODULE_INIT

- (void)setup
{
    _config = MixWebValueI(@{@"enable": @(YES), @"color": @"#00F", @"height": @(3)});
}

/**
 progress: 进度条
 -  enable: bool 是否允许显示，默认YES,
 -  color: string 颜色，默认#0000FF,
 -  height: float 高度，默认3,
 */
- (BOOL)shouldMergeConfig:(id)value forKey:(NSString *)key
{
    if (![key isEqualToString:@"progress"]) return NO;
    [self.config merge:value];
    return YES;
}

- (void)viewDidLoad
{

}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.enable) [self.vc.navigationController.navigationBar addSubview:self.progressView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_progressView removeFromSuperview];
}

- (BOOL)enable
{
    return [self.config boolK:@"enable"];
}

- (MWVCProgressView *)progressView
{
    if (!_progressView) {
        CGFloat height = [self.config floatK:@"height"];
        CGRect frame = CGRectMake(0, 44 - height, self.vc.view.bounds.size.width, height);
        MWVCProgressView *progressView = [[MWVCProgressView alloc] initWithFrame:frame];
        progressView.progressBarView.backgroundColor = [self.config colorK:@"color"];
        progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        progressView.progressBarView.frame = CGRectMake(0, 0, 0, height);
        _progressView = progressView;
    }
    return _progressView;
}

- (void)setupProgress:(float)progress
{
    // progress should be incremental only
    if (progress > self.progress || progress == 0) {
        [self.progressView setProgress:progress animated:YES];
    }
}

- (void)incrementProgress
{
    float progress = self.progress;
    float maxProgress = self.interactive ? MWVCFinalProgressValue : MWVCInteractiveProgressValue;
    float remainPercent = (float)self.loadingCount / (float)self.maxLoadCount;
    float increment = (maxProgress - progress) * remainPercent;
    progress += increment;
    progress = fmin(progress, maxProgress);
    [self setupProgress:progress];
}

- (void)completeProgress
{
    [self setupProgress:1.0];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (!self.enable) return YES;

    if ([request.URL.absoluteString isEqualToString:MWVCCompleteRPCURL]) {
        [self completeProgress];
        return NO;
    }

    BOOL ret = YES;

    BOOL isFragmentJump = NO;
    if (request.URL.fragment) {
        NSString *nonFragmentURL = [request.URL.absoluteString stringByReplacingOccurrencesOfString:[@"#" stringByAppendingString:request.URL.fragment] withString:@""];
        isFragmentJump = [nonFragmentURL isEqualToString:webView.request.URL.absoluteString];
    }

    BOOL isTopLevelNavigation = [request.mainDocumentURL isEqual:request.URL];

    BOOL isHTTP = [request.URL.scheme isEqualToString:@"http"] || [request.URL.scheme isEqualToString:@"https"];
    if (ret && !isFragmentJump && isHTTP && isTopLevelNavigation) {
        self.currentURL = request.URL;
        self.maxLoadCount = self.loadingCount = 0;
        self.interactive = NO;
        [self setupProgress:0.0];
    }
    return ret;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if (!self.enable) return;

    self.loadingCount++;
    self.maxLoadCount = fmax(self.maxLoadCount, self.loadingCount);

    if (self.progress < MWVCInitialProgressValue) {
        [self setupProgress:MWVCInitialProgressValue];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (!self.enable) return;

    self.loadingCount--;
    [self incrementProgress];

    NSString *readyState = [webView stringByEvaluatingJavaScriptFromString:@"document.readyState"];

    BOOL interactive = [readyState isEqualToString:@"interactive"];
    if (interactive) {
        self.interactive = YES;
        NSString *waitForCompleteJS = [NSString stringWithFormat:@"window.addEventListener('load',function() { var iframe = document.createElement('iframe'); iframe.style.display = 'none'; iframe.src = '%@'; document.body.appendChild(iframe);  }, false);", MWVCCompleteRPCURL];
        [webView stringByEvaluatingJavaScriptFromString:waitForCompleteJS];
    }

    BOOL isNotRedirect = self.currentURL && [self.currentURL isEqual:webView.request.mainDocumentURL];
    BOOL complete = [readyState isEqualToString:@"complete"];
    if (complete && isNotRedirect) {
        [self completeProgress];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (!self.enable) return;

    self.loadingCount--;
    [self incrementProgress];

    NSString *readyState = [webView stringByEvaluatingJavaScriptFromString:@"document.readyState"];

    BOOL interactive = [readyState isEqualToString:@"interactive"];
    if (interactive) {
        self.interactive = YES;
        NSString *waitForCompleteJS = [NSString stringWithFormat:@"window.addEventListener('load',function() { var iframe = document.createElement('iframe'); iframe.style.display = 'none'; iframe.src = '%@'; document.body.appendChild(iframe);  }, false);", MWVCCompleteRPCURL];
        [webView stringByEvaluatingJavaScriptFromString:waitForCompleteJS];
    }

    BOOL isNotRedirect = self.currentURL && [self.currentURL isEqual:webView.request.mainDocumentURL];
    BOOL complete = [readyState isEqualToString:@"complete"];
    if (complete && isNotRedirect) {
        [self completeProgress];
    }
}

@end
