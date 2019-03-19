//
//  MWVRequestModule.m
//  MixWebDemo
//
//  Created by Eric on 2017/10/11.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import "MWVRequestModule.h"

@implementation MWVRequestModule

MIX_WEBVIEW_MODULE_INIT

- (void)setup
{
    [self.webView registerBridgeHandler:@"request" handler:^(MixWebValue *value, MixWebJSResponseCallback responseCallback) {

        NSString *urlString = [value stringK:@"url"];
        NSString *method = [[value stringK:@"method"] uppercaseString];
        if (![method isEqualToString:@"GET"] && ![method isEqualToString:@"POST"]) method = @"GET";
        float timeoutInterval = [value floatK:@"timeoutInterval"];
        if (timeoutInterval <= 0) timeoutInterval = 15;
        NSDictionary *headers = [value dictK:@"headers"];
        NSString *body = [value stringK:@"body"];
        NSData *bodyData = [body dataUsingEncoding:NSUTF8StringEncoding];

        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setTimeoutInterval:timeoutInterval];
        [request setHTTPMethod:method];
        [headers enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL * _Nonnull stop) {
            [request addValue:obj forHTTPHeaderField:key];
        }];

        if (bodyData) [request setHTTPBody:bodyData];

        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];

        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSString *base64String = [data base64EncodedStringWithOptions:0];
            NSInteger code = !error ? 1 : 0;
            id message = !error ? [NSNull null] : @"请稍后再试";
            NSDictionary *response1 = @{@"data": base64String, @"code": @(code), @"message": message};
            if (responseCallback) responseCallback(response1);
        }];
        [dataTask resume];
    }];
}

@end
