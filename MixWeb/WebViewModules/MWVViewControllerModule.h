//
//  MWVViewControllerModule.h
//  MixWebDemo
//
//  Created by Eric Lung on 2017/9/29.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import "MixWebView.h"

@interface MWVViewControllerModule : NSObject<MixWebViewModule>

+ (void)setWebViewControllerClass:(Class)cls;

@end
