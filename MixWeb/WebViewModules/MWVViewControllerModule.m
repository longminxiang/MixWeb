//
//  MWVViewControllerModule.m
//  MixWebDemo
//
//  Created by Eric Lung on 2017/9/29.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import "MWVViewControllerModule.h"
#import "MixWebVC.h"

@implementation MWVViewControllerModule

MIX_WEBVIEW_MODULE_INIT

static Class _webViewControllerClass;

+ (void)setWebViewControllerClass:(Class)cls
{
    _webViewControllerClass = cls;
}

- (void)setup
{
    __weak typeof(self) weaks = self;
    [self.webView registerBridgeHandler:@"navigateBack" handler:^(MixWebValue *value, MixWebJSResponseCallback responseCallback) {
        int delta = [value intK:@"delta"];

        UIViewController *vc = [weaks vc];
        int count = (int)vc.navigationController.viewControllers.count;
        delta = MAX(1, delta);
        if (delta >= count) {
            [vc.navigationController popToRootViewControllerAnimated:YES];
        }
        else {
            UIViewController *avc = vc.navigationController.viewControllers[count - delta - 1];
            [vc.navigationController popToViewController:avc animated:YES];
        }
    }];

    [self.webView registerBridgeHandler:@"navigateTo" handler:^(MixWebValue *value, MixWebJSResponseCallback responseCallback) {
        NSString *urlString = [value stringK:@"url"];
        NSDictionary *configDict = [value dictK:@"config"];
        NSString *webClass = [value stringK:@"webClass"];
        Class cls = NSClassFromString(webClass);
        if (!cls) cls = _webViewControllerClass ? _webViewControllerClass : [MixWebVC class];
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:0 timeoutInterval:10];
        id avc = [[cls alloc] initWithRequest:request];
        [avc mergeConfig:configDict];
        [[weaks vc].navigationController pushViewController:avc animated:YES];
    }];

    [self.webView registerBridgeHandler:@"setViewConfig" handler:^(MixWebValue *value, MixWebJSResponseCallback responseCallback) {
        NSDictionary *dict = [value dictK:@"config"];
        [[weaks vc] mergeConfig:dict];
    }];
}

- (MixWebVC *)vc
{
    MixWebVC *vc = (MixWebVC *)[self.webView.superview nextResponder];
    return vc;
}

@end
