//
//  MixWebView.m
//
//  Created by Eric on 2017/9/27.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import "MixWebView.h"
#import <objc/runtime.h>
#import <WebViewJavascriptBridge/WebViewJavascriptBridge.h>
#import <JavaScriptCore/JSContext.h>
#import <JavaScriptCore/JSValue.h>
#import "MixWebUtils.h"

NSMutableSet* _mixWebViewModuleClasses(void) {
    static id obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [NSMutableSet new];
    });
    return obj;
}

void mixWebViewModuleRegister(Class<MixWebViewModule> moduleClass) {
    [_mixWebViewModuleClasses() addObject:moduleClass];
}

NSSet* mixWebViewModuleClasses(void) {
    return _mixWebViewModuleClasses();
}

@interface MixWebView ()

@property (nonatomic, readonly) NSArray<id<MixWebViewModule>> *modules;
@property (nonatomic, readonly) WebViewJavascriptBridge *wjbBridge;
@property (nonatomic, assign) CFRunLoopObserverRef runLoopObserver;

@end

@implementation MixWebView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup
{   
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NSURLCache sharedURLCache].memoryCapacity = 128 * 1024 * 1024;
        [NSURLCache sharedURLCache].diskCapacity = 512 * 1024 * 1024;
    });
    self.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    self.clipsToBounds = NO;
    self.scrollView.clipsToBounds = NO;
    self.backgroundColor = [UIColor whiteColor];
    self.allowsInlineMediaPlayback = YES;
    self.mediaPlaybackRequiresUserAction = NO;
    if (@available(iOS 11.0, *)) self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;

    _wjbBridge = [WebViewJavascriptBridge bridgeForWebView:self];

    NSMutableArray *modules = [NSMutableArray new];
    for (Class class in mixWebViewModuleClasses()) {
        id<MixWebViewModule> obj = [[class alloc] initWithWebView:self];
        [modules addObject:obj];
    }
    _modules = modules;
}

+ (NSMutableArray<NSString *> *)whiteList
{
    static id obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [NSMutableArray new];
    });
    return obj;
}

+ (void)setWhiteList:(NSArray<NSString *> *)whiteList
{
    [[self whiteList] removeAllObjects];
    [[self whiteList] addObjectsFromArray:whiteList];
}

+ (BOOL)containsHost:(NSString *)host
{
    for (NSString *ahost in [MixWebView whiteList]) {
        if ([ahost isEqualToString:host] || [ahost isEqualToString:@"*"]) return YES;
    }
    return NO;
}

- (NSString *)defaultInitialJavaScript
{
    static id obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle *bundle = [MixWebBundle bundle];
        NSString *path = [bundle pathForResource:@"app" ofType:@"js"];
        NSString *script = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        
        NSString *path1 = [bundle pathForResource:@"xapp" ofType:@"js"];
        NSString *script1 = [[NSString alloc] initWithContentsOfFile:path1 encoding:NSUTF8StringEncoding error:nil];
        script = [script stringByAppendingString:script1];
        obj = script;
    });
    return obj;
}

- (NSString *)modulesInitialJavaScript
{
    NSString *javaScript = @"";
    for (id<MixWebViewModule> module in self.modules) {
        if (![module respondsToSelector:@selector(initialJavaScript)]) continue;
        NSString *script = [module initialJavaScript];
        if (script) javaScript = [javaScript stringByAppendingString:script];
    }
    return javaScript;
}

- (void)startContextRunLoop
{
    if (self.runLoopObserver) return;
    
    __weak typeof(self) weaks = self;
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        JSContext *ctx = [weaks valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
        if (![[ctx.globalObject valueForProperty:@"__didsetcustomscript"] toBool]) {
            NSString *host = weaks.request.URL.host;
            if (!host) host = weaks.originRequest.URL.host;
            if ([MixWebView containsHost:host]) {
                [ctx evaluateScript:[weaks defaultInitialJavaScript]];
                NSString *script = [weaks modulesInitialJavaScript];
                [ctx evaluateScript:script];
            }
            [ctx.globalObject setValue:@(YES) forProperty:@"__didsetcustomscript"];
        }
    });
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopDefaultMode);
    self.runLoopObserver = observer;
}

- (void)loadRequest:(NSURLRequest *)request
{
    [super loadRequest:request];
    _originRequest = request;
    [self startContextRunLoop];
}

- (void)reloadOriginRequest
{
    [self loadRequest:self.originRequest];
}

- (void)setDelegate:(id<UIWebViewDelegate>)delegate
{
    [super setDelegate:self.wjbBridge];
    [self.wjbBridge setWebViewDelegate:delegate];
}

- (void)registerBridgeHandler:(NSString *)name handler:(MixWebJSHandler)handler
{
    if (!name) return;
    [self.wjbBridge registerHandler:name handler:^(id data, WVJBResponseCallback responseCallback) {
        MixWebValue *value = MixWebValueI(data);
        handler(value, responseCallback);
    }];
}

- (void)callBridgeHandler:(NSString *)name data:(id)data response:(MixWebJSResponseCallback)response
{
    if (!name) return;
    [self.wjbBridge callHandler:name data:data responseCallback:response];
}

- (void)dealloc
{
    CFRunLoopRemoveObserver(CFRunLoopGetCurrent(), self.runLoopObserver, kCFRunLoopDefaultMode);
}

@end
