//
//  MixWebUtils.h
//
//  Created by Eric on 2017/9/27.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MixWebColor : NSObject

+ (UIColor *)hex:(NSString *)hex;

@end

@interface MixWebImage : NSObject

+ (void)getImage:(NSString *)nameOrURL scale:(int)scale completion:(void (^)(UIImage *image))completion;

+ (void)getImageWithURL:(NSString *)url completion:(void (^)(UIImage *image, NSString *url))completion;

+ (UIImage *)imageName:(NSString *)imageName bundleName:(NSString *)bundleName;

@end

@interface MixWebHUD : NSObject

+ (void)show;

+ (void)hide;

+ (void)showInView:(UIView *)view;

+ (void)hideInView:(UIView *)view;

+ (void)showText:(NSString *)string;

+ (void)showText:(NSString *)string delay:(CGFloat)delay bottom:(BOOL)bottom;

@end
