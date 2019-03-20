//
//  MixWebVC.m
//
//  Created by Eric on 2017/9/27.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import "MixWebVC.h"

NSMutableSet* _mixWebViewControllerModuleClasses(void) {
    static id obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [NSMutableSet new];
    });
    return obj;
}

void mixWebViewControllerModuleRegister(Class<MixWebViewControllerModule> moduleClass) {
    [_mixWebViewControllerModuleClasses() addObject:moduleClass];
}

NSSet* mixWebViewControllerModuleClasses(void) {
    return _mixWebViewControllerModuleClasses();
}

@interface MixWebVC ()<UIScrollViewDelegate>

@property (nonatomic, strong, readonly) NSArray<id<MixWebViewControllerModule>> *modules;

@property (nonatomic, strong, readonly) NSURLRequest *request;

@end

@implementation MixWebVC

- (instancetype)initWithRequest:(NSURLRequest *)request
{
    if (self = [super initWithNibName:nil bundle:nil]) {
        _request = request;

        NSMutableArray *modules = [NSMutableArray new];
        for (Class class in mixWebViewControllerModuleClasses()) {
            id obj = [[class alloc] initWithVC:self];
            [modules addObject:obj];
        }
        _modules = modules;
    }
    return self;
}

- (BOOL)automaticallyAdjustsScrollViewInsets
{
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    MixWebView *webView = [[MixWebView alloc] initWithFrame:self.view.bounds];
    webView.delegate = self;
    [self.view addSubview:webView];
    _webView = webView;

    [self modulesRespond:_cmd enumerate:^(id<MixWebViewControllerModule> obj) {
        [obj viewDidLoad];
    }];

    [self.webView loadRequest:self.request];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self modulesRespond:_cmd enumerate:^(id<MixWebViewControllerModule> obj) {
        [obj viewWillAppear:animated];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self modulesRespond:_cmd enumerate:^(id<MixWebViewControllerModule> obj) {
        [obj viewDidAppear:animated];
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self modulesRespond:_cmd enumerate:^(id<MixWebViewControllerModule> obj) {
        [obj viewWillDisappear:animated];
    }];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self modulesRespond:_cmd enumerate:^(id<MixWebViewControllerModule> obj) {
        [obj viewDidDisappear:animated];
    }];
}

- (void)mergeConfig:(NSDictionary *)config
{
    [config enumerateKeysAndObjectsUsingBlock:^(NSString *key, id val, BOOL *stop) {
        for (id<MixWebViewControllerModule> obj in self.modules) {
            BOOL should = [obj shouldMergeConfig:val forKey:key];
            if (should) break;
        }
    }];
}

- (void)modulesRespond:(SEL)sel enumerate:(void (^)(id<MixWebViewControllerModule> obj))block
{
    for (id<MixWebViewControllerModule> obj in self.modules) {
        if (!sel || [obj respondsToSelector:sel]) if (block) block(obj);
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

@implementation MixWebVC (UIWebViewDelegate)

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    __block BOOL should = YES;;
    [self modulesRespond:_cmd enumerate:^(id<MixWebViewControllerModule> obj) {
        should = should && [obj webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }];
    return should;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self modulesRespond:_cmd enumerate:^(id<MixWebViewControllerModule> obj) {
        [obj webViewDidStartLoad:webView];
    }];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self modulesRespond:_cmd enumerate:^(id<MixWebViewControllerModule> obj) {
        [obj webViewDidFinishLoad:webView];
    }];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self modulesRespond:_cmd enumerate:^(id<MixWebViewControllerModule> obj) {
        [obj webView:webView didFailLoadWithError:error];
    }];
}

@end
