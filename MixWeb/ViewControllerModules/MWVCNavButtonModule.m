//
//  MWVCNavButtonModule.m
//  MixWebDemo
//
//  Created by Eric Lung on 2019/2/22.
//  Copyright © 2019 Eric. All rights reserved.
//

#import "MWVCNavButtonModule.h"
#import "MixWebUtils.h"
#import "MixWebVC.h"

@interface MWVCNavButtonModule ()

@property (nonatomic, strong) UIBarButtonItem *backItem, *closeItem;

@end

@implementation MWVCNavButtonModule

MIX_WEB_MODULE_INIT

- (void)setup
{
    _config = MixWebValueI(@{@"backButton": [self buttonConfig], @"closeButton": [self buttonConfig]});
}

/**
 title: 标题, 和图片2选1, 图片优先,
 titleColor: 标题颜色, 默认#000,
 titleFontSize: 标题字号, 默认16,
 tintColor: 主题色, 如果为空，则用navBar和tintColor,
 image: 图片, 和标题2选1，图片优先,
 imageScale: 图片比例, @2x, @3x, 默认2
 imageIsOriginal: 是否使用原始图片，不受主题色影响，默认YES,
 handler: 点击事件,
 handlerType: 点击事件类型, 0: bridge, 1: jsfunc, 2: js
 */
- (MixWebValue *)buttonConfig
{
    return MixWebValueI(@{@"titleColor": @"#000", @"titleFontSize": @(16), @"imageScale": @(2), @"imageIsOriginal": @(YES)});
}

/**
 rightButtons: 右边按钮组,
 backButton: 返回按钮, 默认有值
 closeButton: 关闭按钮, 默认有值
 */
- (BOOL)shouldMergeConfig:(id)value forKey:(NSString *)key
{
    if (![[self keys] containsObject:key]) return NO;
    [self.config set:value key:key];
    return YES;
}

- (NSArray<NSString *> *)keys
{
    return @[@"rightButtons", @"backButton", @"closeButton"];
}

- (void)viewDidLoad
{
    for (NSString *key in [self keys]) {
        [self.config addObserver:self forKeyPath:key options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    }
}

- (UIBarButtonItem *)createButtonItem:(MixWebValue *)config defaultImage:(UIImage *)defaultImage
{
    UIBarButtonItem *item;
    NSString *title = [config stringK:@"title"];
    NSString *imageName = [config stringK:@"image"];

    //图片
    if (imageName || defaultImage) {
        item = [[UIBarButtonItem alloc] initWithImage:defaultImage style:UIBarButtonItemStylePlain target:self action:@selector(buttonItemsTouched:)];
        __weak typeof(item) witem = item;
        [MixWebImage getImage:imageName scale:[config intK:@"imageScale"] completion:^(UIImage *image) {
            if (!image) return ;
            witem.image = [config boolK:@"imageIsOriginal"] ? [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] : image;
        }];
    }
    //标题
    else if (title) {
        item = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(buttonItemsTouched:)];
        NSMutableDictionary *atts = [NSMutableDictionary new];
        UIColor *titleColor = [config colorK:@"titleColor"];
        if (titleColor) atts[NSForegroundColorAttributeName] = titleColor;
        CGFloat titleFontSize = [config floatK:@"titleFontSize"];
        if (titleFontSize > 0) atts[NSFontAttributeName] = [UIFont systemFontOfSize:titleFontSize];
        [item setTitleTextAttributes:atts forState:UIControlStateNormal];
        [item setTitleTextAttributes:atts forState:UIControlStateHighlighted];
    }
    item.tintColor = [config colorK:@"tintColor"];
    return item;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"rightButtons"]) {
        NSArray *rightButtons = [self.config arrayK:@"rightButtons"];
        NSUInteger count = rightButtons.count;
        if (count) {
            NSMutableArray *items = [NSMutableArray new];
            for (NSUInteger i = 0; i < count; i++) {
                MixWebValue *config = MixWebValueI(rightButtons[i]);
                UIBarButtonItem *item = [self createButtonItem:config defaultImage:nil];
                item.tag = i;
                if (item) [items addObject:item];
            }
            if (items.count) self.vc.navigationItem.rightBarButtonItems = items;

        }
        else {
            self.vc.navigationItem.rightBarButtonItems = nil;
        }
    }
    else if ([keyPath isEqualToString:@"backButton"]) {
        MixWebValue *config = [self.config valK:@"backButton"];
        //默认返回图片
        NSString *image = [config stringK:@"image"];
        NSString *title = [config stringK:@"title"];
        UIImage *defaultImage = !image && !title ? [self backImage] : nil;
        UIBarButtonItem *item = [self createButtonItem:config defaultImage:defaultImage];
        item.tag = 100;
        self.backItem = item;
        [self resetLeftBarButtonItems];
    }
    else if ([keyPath isEqualToString:@"closeButton"]) {
        MixWebValue *config = [self.config valK:@"closeButton"];
        //默认关闭图片
        NSString *image = [config stringK:@"image"];
        NSString *title = [config stringK:@"title"];
        UIImage *defaultImage = !image && !title ? [self closeImage] : nil;
        UIBarButtonItem *item = [self createButtonItem:config defaultImage:defaultImage];
        item.tag = 101;
        self.closeItem = item;
        [self resetLeftBarButtonItems];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self resetLeftBarButtonItems];
}

- (void)resetLeftBarButtonItems
{
    NSArray *items;
    BOOL isFirstVC = [self.vc.navigationController.viewControllers firstObject] == self.vc;
    BOOL showBackItem = self.backItem && (!isFirstVC || self.vc.webView.canGoBack);
    BOOL showCloseItem = self.closeItem && self.vc.webView.canGoBack && !isFirstVC;
    if (showCloseItem && showBackItem) items = @[self.backItem, self.closeItem];
    else if (!showCloseItem && showBackItem) items = @[self.backItem];
    else if (!showBackItem && showCloseItem) items = @[self.closeItem];
    self.vc.navigationItem.leftBarButtonItems = items;
}

- (void)buttonItemsTouched:(UIBarButtonItem *)item
{
    MixWebValue *config;
    if (item.tag == 100) config = [self.config valK:@"backButton"];
    else if (item.tag == 101) config = [self.config valK:@"closeButton"];
    else config = MixWebValueI([self.config arrayK:@"rightButtons"][item.tag]);

    NSString *handler = [config stringK:@"handler"];
    if (handler) {
        switch ([config intK:@"handlerType"]) {
            case 0: {
                [self.vc.webView callBridgeHandler:handler data:nil response:nil];
                break;
            }
            case 1: {
                NSString *script = [NSString stringWithFormat:@"%@();", handler];
                [self.vc.webView stringByEvaluatingJavaScriptFromString:script];
                break;
            }
            case 2: {
                [self.vc.webView stringByEvaluatingJavaScriptFromString:handler];
                break;
            }
        }
    }
    else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id target = nil; // = [config v].obj(@"target");
        SEL action = nil; // = config.sel(@"action");
        if (!target || !action) {
            target = self;
            if (item.tag == 100) action = @selector(backButtonItemDefaultHandler);
            else if (item.tag == 101) action = @selector(closeButtonItemDefaultHandler);
        }
        if (target && action) [target performSelector:action];
#pragma clang diagnostic pop
    }
}

- (void)backButtonItemDefaultHandler
{
    if (self.vc.webView.canGoBack) {
        [self.vc.webView goBack];
    }
    else {
        [self closeButtonItemDefaultHandler];
    }
}

- (void)closeButtonItemDefaultHandler
{
    if (self.vc.navigationController.viewControllers.count <= 1) {
        [self.vc.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self.vc.navigationController popViewControllerAnimated:YES];
    }
}

- (UIImage *)backImage
{
    static id obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGSize size = CGSizeMake(11, 20.5);
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGFloat halfLineWidth = 0.7;
        CGContextSetLineWidth(context, halfLineWidth * 2);
        CGContextMoveToPoint(context, size.width - halfLineWidth, halfLineWidth);
        CGContextAddLineToPoint(context, halfLineWidth * 2, size.height / 2);
        CGContextAddLineToPoint(context, size.width - halfLineWidth, size.height - halfLineWidth);
        CGContextStrokePath(context);
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        obj = image;
    });
    return obj;
}

- (UIImage *)closeImage
{
    static id obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGSize size = CGSizeMake(18, 18);
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGFloat halfLineWidth = 0.7;
        CGContextSetLineWidth(context, halfLineWidth * 2);
        CGContextMoveToPoint(context, halfLineWidth, halfLineWidth);
        CGContextAddLineToPoint(context, size.width - halfLineWidth, size.height - halfLineWidth);
        CGContextMoveToPoint(context, size.width - halfLineWidth, halfLineWidth);
        CGContextAddLineToPoint(context, halfLineWidth, size.height - halfLineWidth);
        CGContextStrokePath(context);
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        obj = image;
    });
    return obj;
}

- (void)dealloc
{
    for (NSString *key in [self keys]) {
        [self.config removeObserver:self forKeyPath:key];
    }
}

@end
