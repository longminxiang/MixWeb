//
//  AppDelegate.m
//  MixWebDemo
//
//  Created by Eric on 2017/9/27.
//  Copyright © 2017年 Eric. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "WebVC.h"
#import <MixWeb/MWVViewControllerModule.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];

    [MixWebView setWhiteList:@[@"localhost", @"192.168.0.102", @"amz-1252491566.cos-website.ap-shanghai.myqcloud.com"]];
    
    WebVC *vc = [[WebVC alloc] initWithURLString:@"https://amz-1252491566.cos-website.ap-shanghai.myqcloud.com"];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = nav;
    
//    UITabBarController *barVC = [UITabBarController new];
//    barVC.tabBar.tintColor = [UIColor orangeColor];
//    barVC.automaticallyAdjustsScrollViewInsets = NO;
//
//    NSDictionary *config = @{@"navBar": @{@"barTintColor": @"#6d61ff"},
//                             @"bounces": @(NO),
//                             @"title": @{@"text": @"网易", @"useHtmlTitle": @(NO)},
//                             };
//
//    NSDictionary *config1 = @{@"navBar": @{@"barTintColor": @"#FF8000"},
//                              @"title": @{@"text": @"百度"},
//                              };
//
//    MixWebVC *vc = [[WebVC alloc] initWithURLString:@"http://baidu.com"];
//    [vc mergeConfig:config];
//
//    MixWebVC *vc1 = [[WebVC alloc] initWithURLString:@"http://baidu.com"];
//    [vc1 mergeConfig:config1];
//
//    MixWebVC *vc2 = [[WebVC alloc] initWithURLString:@"http://hao123.com"];
//
//    NSArray *titles = @[@"首页", @"通讯录", @"发现", @"我的"];
//    NSArray *vcs = @[[ViewController new], vc, vc1, vc2];
//    NSMutableArray *navs = [NSMutableArray new];
//    for (int i = 0; i < titles.count; i++) {
//        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vcs[i]];
//        nav.automaticallyAdjustsScrollViewInsets = NO;
//        nav.tabBarItem = [[UITabBarItem alloc] initWithTitle:titles[i] image:nil tag:i];
//        nav.navigationBar.barTintColor = [UIColor orangeColor];
//        nav.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
//        nav.navigationBar.barStyle = UIBarStyleBlack;
//        nav.navigationBar.translucent = YES;
//        nav.navigationBar.tintColor = [UIColor whiteColor];
//        [navs addObject:nav];
//    }
//
//    barVC.viewControllers = navs;
//
//    self.window.rootViewController = barVC;
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
