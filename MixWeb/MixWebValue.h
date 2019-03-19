//
//  MixWebValue.h
//  MixWebDemo
//
//  Created by Eric on 2019/3/15.
//  Copyright © 2019 Eric. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MixWebValue : NSObject

@property (nonatomic, readonly) id obj;

@property (nonatomic, readonly) int intV;
@property (nonatomic, readonly) long longV;
@property (nonatomic, readonly) BOOL boolV;
@property (nonatomic, readonly) float floatV;
@property (nonatomic, readonly) double doubleV;
@property (nonatomic, readonly) NSString *string;
@property (nonatomic, readonly) NSArray *array;
@property (nonatomic, readonly) NSDictionary *dict;
@property (nonatomic, readonly) UIColor *color;

@end

MixWebValue* MixWebValueI(id obj);

@interface MixWebValue (Dictionary)

- (MixWebValue *)valK:(NSString *)keyPath;
- (id)objK:(NSString *)keyPath;
- (int)intK:(NSString *)keyPath;
- (long)longK:(NSString *)keyPath;
- (BOOL)boolK:(NSString *)keyPath;
- (float)floatK:(NSString *)keyPath;
- (double)doubleK:(NSString *)keyPath;
- (NSString *)stringK:(NSString *)keyPath;
- (NSArray *)arrayK:(NSString *)keyPath;
- (NSDictionary *)dictK:(NSString *)keyPath;
- (UIColor *)colorK:(NSString *)keyPath;

- (void)set:(id)value key:(NSString *)keyPath;

- (void)merge:(id)obj;

@end
