//
//  MWVCPreloadImageModule.m
//  MixWebDemo
//
//  Created by Eric Lung on 2019/2/22.
//  Copyright © 2019 Eric. All rights reserved.
//

#import "MWVCPreloadImageModule.h"
#import "MixWebUtils.h"

@interface MWVCPreloadImageModule ()

@property (nonatomic, readonly) UIImageView *preloadImageView;

@end

@implementation MWVCPreloadImageModule

MIX_WEB_MODULE_INIT

- (void)setup
{
    
}

/**
 proloadImage:
 url: string 图片URL
 */
- (BOOL)shouldMergeConfig:(id)value forKey:(NSString *)key
{
    if (![key isEqualToString:@"proloadImage"]) return NO;
    if (!self.config) _config = [MixWebValue new];
    if ([value isKindOfClass:[NSDictionary class]]) {
        [self.config merge:value];
    }
    else if ([value isKindOfClass:[NSString class]]) {
        [self.config set:value key:@"url"];
    }
    return YES;
}

- (void)viewDidLoad
{
    NSString *url = [self.config stringK:@"url"];
    if (!url) return;

    UIScrollView *scrollView = self.vc.webView.scrollView;
    [[scrollView subviews] firstObject].opaque = NO;
    [[scrollView subviews] firstObject].backgroundColor = [UIColor clearColor];

    UIImageView *preloadView = [[UIImageView alloc] initWithFrame:scrollView.bounds];
    preloadView.backgroundColor = [UIColor whiteColor];
    preloadView.contentMode = UIViewContentModeScaleAspectFill;
    preloadView.clipsToBounds = YES;
    [scrollView insertSubview:preloadView atIndex:0];

    [MixWebImage getImage:url scale:0 completion:^(UIImage *image) {
        preloadView.image = image;
        if (!image) return;
        CGSize ssize = scrollView.frame.size;
        CGRect frame = CGRectMake(0, 0, ssize.width, ssize.width * image.size.height / image.size.width);
        preloadView.frame = frame;
    }];
    _preloadImageView = preloadView;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.preloadImageView removeFromSuperview];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.preloadImageView removeFromSuperview];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.preloadImageView removeFromSuperview];
}

@end
