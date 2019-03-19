//
//  MixWebVC.h
//
//  Created by Eric on 2017/9/27.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MixExtention/MixExtention.h>
#import "MixWebView.h"

@class MixWebVC;

@protocol MixWebViewControllerModule <NSObject, UIWebViewDelegate>

@property (nonatomic, weak, readonly) MixWebVC *vc;

@property (nonatomic, strong, readonly) MixWebValue *config;

- (instancetype)initWithVC:(MixWebVC *)vc;

- (void)setup;

- (BOOL)shouldMergeConfig:(id)value forKey:(NSString *)key;

@optional

- (void)viewDidLoad;

- (void)viewWillAppear:(BOOL)animated;

- (void)viewDidAppear:(BOOL)animated;

- (void)viewWillDisappear:(BOOL)animated;

- (void)viewDidDisappear:(BOOL)animated;

@end

NSSet* mixWebViewControllerModuleClasses(void);

void mixWebViewControllerModuleRegister(Class<MixWebViewControllerModule> moduleClass);

#define MIX_WEB_MODULE_INIT \
@synthesize vc = _vc; \
@synthesize config = _config; \
+ (void)load \
{ \
mixWebViewControllerModuleRegister(self); \
} \
- (instancetype)initWithVC:(MixWebVC *)vc \
{ \
if (self = [super init]) { \
_vc = vc; \
[self setup]; \
} \
return self; \
}

@interface MixWebVC : UIViewController<UIViewControllerMixExtention, UIWebViewDelegate>

@property (nonatomic, strong, readonly) MixWebView *webView;

- (instancetype)initWithRequest:(NSURLRequest *)request;

- (void)mergeConfig:(NSDictionary *)config;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

@end

@interface MixWebVC (UIWebViewDelegate)

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType  NS_REQUIRES_SUPER;
- (void)webViewDidStartLoad:(UIWebView *)webView  NS_REQUIRES_SUPER;
- (void)webViewDidFinishLoad:(UIWebView *)webView NS_REQUIRES_SUPER;
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error NS_REQUIRES_SUPER;

@end
