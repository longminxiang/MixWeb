//
//  WebVC.m
//  MixWebDemo
//
//  Created by Eric Lung on 2019/2/27.
//  Copyright © 2019 Eric. All rights reserved.
//

#import "WebVC.h"

@interface WebVC ()

@end

@implementation WebVC

- (instancetype)initWithURLString:(NSString *)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:0 timeoutInterval:10];
    return [self initWithRequest:request];
}

- (instancetype)initWithRequest:(NSURLRequest *)request
{
    if (self = [super initWithRequest:request]) {
        NSDictionary *config = @{
                                 @"navBar": @{@"barTintColor": @"#303435", @"tintColor": @"#FFF"},
                                 @"title": @{@"color": @"#FFF"},
                                 @"statusBar": @{@"style": @"white"},
                                 @"progress": @{@"enable": @(NO)}
                                 };
        [self mergeConfig:config];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"reload" style:UIBarButtonItemStyleDone target:self.webView action:@selector(reloadOriginRequest)];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [super webViewDidFinishLoad:webView];
}

- (void)dealloc
{
    NSLog(@"%@ dealloc", NSStringFromClass([self class]));
}


@end
