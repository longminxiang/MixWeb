//
//  MWVStorageModule.m
//  MixWebDemo
//
//  Created by Eric on 2017/10/9.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import "MWVStorageModule.h"
#import <MixCache_Objc/MixCache.h>

static NSString *MixWebViewStorageModuleStoragesKey = @"MixWebViewStorageModuleStorages";

@implementation MWVStorageModule

MIX_WEBVIEW_MODULE_INIT

- (void)setup
{
    [self.webView registerBridgeHandler:@"setStorage" handler:^(MixWebValue *value, MixWebJSResponseCallback responseCallback) {
        NSString *key = [value stringK:@"key"];
        id obj = [value objK:@"obj"];
        [MWVStorageModule setCacheWithKey:key obj:obj];
    }];
}

+ (void)setCacheWithKey:(NSString *)key obj:(id)obj
{
    if (!key) return;
    NSMutableDictionary *mdict = [NSMutableDictionary new];
    NSDictionary *dict = (NSDictionary *)[[MixFileCache shared] getObject:MixWebViewStorageModuleStoragesKey];
    if ([dict isKindOfClass:[NSDictionary class]]) {
        [mdict addEntriesFromDictionary:dict];
    }
    if (obj) {
        mdict[key] = obj;
    }
    else {
        [mdict removeObjectForKey:key];
    }
    [[MixFileCache shared] setObject:mdict key:MixWebViewStorageModuleStoragesKey];
}

- (NSString *)initialJavaScript
{
    NSString *string;
    NSDictionary *dict = (NSDictionary *)[[MixFileCache shared] getObject:MixWebViewStorageModuleStoragesKey];
    if ([dict isKindOfClass:[NSDictionary class]]) {
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
        string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }

    return [NSString stringWithFormat:@"$app.cache=%@;\n", string ? string : @"{}"];
}

@end
