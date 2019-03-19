//
//  ViewController.m
//  MixWebDemo
//
//  Created by Eric on 2017/9/27.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import "ViewController.h"
#import <MixDevice/MixDevice-Swift.h>
#import "WebVC.h"
#import "MixWebUtils.h"

@interface UIViewController (Hook)

@end

@implementation UIViewController (Hook)

- (BOOL)hidesBottomBarWhenPushed
{
    return self.navigationController.viewControllers.count > 1;
}

@end

@interface ViewController ()<UIGestureRecognizerDelegate, UIViewControllerMixExtention>

@property (nonatomic, strong) NSMutableDictionary *dict;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"首页";
    self.mixE.item.navigationBarBarTintColor = [MixWebColor hex:@"#FF8000"];
    self.mixE.item.navigationBarTitleTextAttributes = @{NSForegroundColorAttributeName: [MixWebColor hex:@"#F0F"]};
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    self.dict = [NSMutableDictionary new];
    [self.dict addObserver:self forKeyPath:@"xxx" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.dict[@"xxx"] = @"dddd";
    });

    [[MixDevice shared] add:@"sdfsfs" key:@"zzzzzzzzz"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"xxx"]) {
        NSLog(@"%@", self.dict[@"xxx"]);
    }
}

- (IBAction)buttonTouched:(id)sender
{
    NSDictionary *r1 = @{@"title": @"111", @"titleColor": @"#3333FF",
                         @"handler": @"alert", @"handlerType": @(1),
                         };
    
    NSDictionary *r2 = @{@"imageIsOriginal": @(YES),
                         @"image": @"https://gss2.bdstatic.com/5eR1dDebRNRTm2_p8IuM_a/her/static/indexher/container/module/servicetab/icon-re.1f70a8b.png"
                         };
    
    NSDictionary *dict = @{
                           @"preloadImage": @"loading_list",
                           @"navBar": @{@"tintColor": @"#FFF", @"barTintColor": @"#FF8000"},
                           @"title": @{@"text":  @"百度一下", @"color": @"#F00"},
                           @"backButton": @{@"tintColor": @"#00F"},
                           @"closeButton": @{@"tintColor": @"#a32"},
                           @"rightButtons": @[r1, r2],
                           @"bounces": @(YES),
                           @"progress": @{@"enable": @(YES)},
                           };
//    WebVC *vc = [[WebVC alloc] initWithURLString:@"http://localhost:8334/ffl/answer/index.html"];
    WebVC *vc = [[WebVC alloc] initWithURLString:@"http://hao123.com"];
    [vc mergeConfig:dict];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)buttonTouched1:(id)sender
{
    WebVC *vc = [[WebVC alloc] initWithURLString:@"http://163.com"];
    [self.navigationController pushViewController:vc animated:YES];
    [vc mergeConfig:@{@"title": @{@"text":  @"百度一下", @"color": @"#F00"}}];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [vc mergeConfig:@{@"title": @"cccc"}];
    });
}

- (void)xxx
{
    NSLog(@"ccc");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
