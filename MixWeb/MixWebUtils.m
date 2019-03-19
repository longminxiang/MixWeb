//
//  MixWebUtils.m
//
//  Created by Eric on 2017/9/27.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import "MixWebUtils.h"
#import <SDWebImage/SDWebImageManager.h>
#import <MBProgressHUD/MBProgressHUD.h>

@implementation MixWebBundle

+ (NSBundle *)bundle
{
    NSBundle *frameworkBundle = [NSBundle bundleWithIdentifier:@"org.cocoapods.MixWeb"];
    NSString *bundlePath = [frameworkBundle pathForResource:@"MixWeb" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    return bundle ? bundle : [NSBundle mainBundle];
}

@end

@implementation MixWebColor

+ (UIColor *)hex:(NSString *)hex
{
    if (!hex) return nil;
    hex = [[hex uppercaseString] stringByReplacingOccurrencesOfString:@"#" withString:@""];
    hex = [hex stringByReplacingOccurrencesOfString:@"0X" withString:@""];

    if (hex.length == 3 || hex.length == 4) {
        NSString *newHex = @"";
        for (int i = 0; i < hex.length; i++) {
            NSString *sub = [hex substringWithRange:NSMakeRange(i, 1)];
            newHex = [newHex stringByAppendingString:sub];
            newHex = [newHex stringByAppendingString:sub];
        }
        hex = newHex;
    }
    if (hex.length == 6) hex = [@"FF" stringByAppendingString:hex];
    
    if (hex.length != 8) return nil;

    NSRange range = NSMakeRange(0, 2);
    NSString *aString = [hex substringWithRange:range];
    range.location = 2;
    NSString *rString = [hex substringWithRange:range];
    range.location = 4;
    NSString *gString = [hex substringWithRange:range];
    range.location = 6;
    NSString *bString = [hex substringWithRange:range];

    unsigned int a, r, g, b;
    [[NSScanner scannerWithString:aString] scanHexInt:&a];
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:((float) a / 255.0f)];
}

@end


@implementation MixWebImage

+ (int)getImageScaleWithNameOrURL:(NSString *)nameOrURL
{
    if ([nameOrURL isKindOfClass:[NSURL class]]) nameOrURL = ((NSURL *)nameOrURL).absoluteString;
    NSString *string = [[nameOrURL componentsSeparatedByString:@"."] firstObject];
    if (string.length <= 3) return 0;
    string = [string substringFromIndex:string.length - 3];
    if ([string hasPrefix:@"@"] && ([string hasSuffix:@"x"] || [string hasSuffix:@"X"])) {
        return [[string substringWithRange:NSMakeRange(1, 1)] intValue];
    }
    return 0;
}

+ (void)getImage:(NSString *)nameOrURL scale:(int)scale completion:(void (^)(UIImage *image))completion
{
    if (!nameOrURL) {
        if (completion) completion(nil); return;
    }
    UIImage *image = [UIImage imageNamed:nameOrURL];
    if (image && completion) {
        completion(image); return;
    }
    if (scale <= 0) scale = [self getImageScaleWithNameOrURL:nameOrURL];
    
    [self getImageWithURL:nameOrURL completion:^(UIImage *image, NSString *url) {
        image = [UIImage imageWithCGImage:image.CGImage scale:scale orientation:UIImageOrientationUp];
        if (completion) completion(image);
    }];
}


+ (void)getImageWithURL:(NSString *)url completion:(void (^)(UIImage *image, NSString *url))completion
{
    NSString *prefix = @"data:image/jpg;base64,";
    if ([url hasPrefix:prefix]) {
        NSString *base64String = [url substringFromIndex:prefix.length];
        NSData *data = [[NSData alloc] initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
        UIImage *image = [UIImage imageWithData:data];
        if (completion) completion(image, nil);
        return;
    }
    [[SDWebImageManager sharedManager] loadImageWithURL:(NSURL *)url options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (completion) completion(image, imageURL.absoluteString);
    }];
}

+ (UIImage *)imageName:(NSString *)imageName
{
    return [UIImage imageNamed:imageName inBundle:[MixWebBundle bundle] compatibleWithTraitCollection:nil];
}

@end

@implementation MixWebHUD

+ (UIWindow *)window
{
    UIApplication *app = [UIApplication sharedApplication];
    UIWindow *window = app.keyWindow;
    if (!window && [app.delegate respondsToSelector:@selector(window)]) {
        window = [app.delegate window];
    }
    return window;
}

+ (void)show
{
    [MixWebHUD showInView:nil];
}

+ (void)hide
{
    [MixWebHUD hideInView:nil];
}

+ (void)showInView:(UIView *)view
{
    if (!view) view = [self window];
    MBProgressHUD *hud = [MBProgressHUD HUDForView:view];
    if (!hud || hud.mode != MBProgressHUDModeIndeterminate) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        [hud hide:YES afterDelay:10];
    }
}

+ (void)hideInView:(UIView *)view
{
    if (!view) view = [self window];
    [MBProgressHUD hideAllHUDsForView:view animated:YES];
}

+ (void)showText:(NSString *)string
{
    return [self showText:string delay:1.0 bottom:NO];
}

+ (void)showText:(NSString *)string delay:(CGFloat)delay bottom:(BOOL)bottom
{
    if (!string) return;
    UIApplication *app = [UIApplication sharedApplication];
    UIWindow *window = app.keyWindow;
    if (!window && [app.delegate respondsToSelector:@selector(window)]) {
        window = [app.delegate window];
    }
    [MBProgressHUD hideAllHUDsForView:window animated:YES];
    if (delay <= CGFLOAT_MIN) delay = 1;
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:window];
    hud.userInteractionEnabled = NO;
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabelText = string;
    hud.removeFromSuperViewOnHide = YES;
    hud.yOffset = bottom ? [UIScreen mainScreen].bounds.size.height / 2 - 50 : 0;
    [window addSubview:hud];
    [hud show:YES];
    [hud hide:YES afterDelay:delay];
}

@end
