//
//  MWVNotificationModule.m
//  MixWeb
//
//  Created by Eric Lung on 2018/4/10.
//  Copyright © 2018年 YOOEE. All rights reserved.
//

#import "MWVNotificationModule.h"

NSNotificationName const MixWebViewNotificationModulePostNotification = @"MixWebViewNotificationModulePostNotification";

@implementation MWVNotificationModule

MIX_WEBVIEW_MODULE_INIT

- (void)setup
{
    __weak typeof(self) weaks = self;
    [self.webView registerBridgeHandler:@"postNotification" handler:^(MixWebValue *value, MixWebJSResponseCallback responseCallback) {
        NSString *name = [value stringK:@"name"];
        if (name) {
            NSMutableDictionary *dict = [@{@"name": name} mutableCopy];
            NSDictionary *data = [value dictK:@"data"];
            if (data) dict[@"data"] = data;
            [[NSNotificationCenter defaultCenter] postNotificationName:MixWebViewNotificationModulePostNotification object:weaks userInfo:dict];
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPostNotification:) name:MixWebViewNotificationModulePostNotification object:nil];
}

- (void)didPostNotification:(NSNotification *)notification
{
    NSString *name = notification.userInfo[@"name"];
    NSString *dataString;
    NSDictionary *dict = notification.userInfo[@"data"];
    if ([dict isKindOfClass:[NSDictionary class]]) {
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
        dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    NSString *script = [NSString stringWithFormat:@"if (typeof $app.notifications.%@ == \"function\") $app.notifications.%@(%@)", name, name, dataString ? dataString : @""];
    [self.webView stringByEvaluatingJavaScriptFromString:script];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
