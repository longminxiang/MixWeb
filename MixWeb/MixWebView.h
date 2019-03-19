//
//  MixWebView.h
//
//  Created by Eric on 2017/9/27.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MixWebValue.h"

@class MixWebView;
@class MixWebValue;

typedef void (^MixWebJSResponseCallback)(NSDictionary *response);

typedef void (^MixWebJSHandler)(MixWebValue *value, MixWebJSResponseCallback responseCallback);

@protocol MixWebViewModule <NSObject>

@property (nonatomic, weak, readonly) MixWebView *webView;

- (instancetype)initWithWebView:(MixWebView *)webView;

- (void)setup;

@optional

- (NSString *)initialJavaScript;

@end

void mixWebViewModuleRegister(Class<MixWebViewModule> moduleClass);

NSSet* mixWebViewModuleClasses(void);

#define MIX_WEBVIEW_MODULE_INIT \
@synthesize webView = _webView; \
+ (void)load \
{ \
    mixWebViewModuleRegister(self); \
} \
- (instancetype)initWithWebView:(MixWebView *)webView \
{ \
    if (self = [super init]) { \
        _webView = webView; \
        [self setup]; \
    } \
    return self; \
}

@interface MixWebView : UIWebView

@property (nonatomic, readonly) NSURLRequest *originRequest;

- (void)reloadOriginRequest;

- (void)registerBridgeHandler:(NSString *)name handler:(MixWebJSHandler)handler;

- (void)callBridgeHandler:(NSString *)name data:(id)data response:(MixWebJSResponseCallback)response;

@end
