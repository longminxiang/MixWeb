//
//  MixWebValue.m
//  MixWebDemo
//
//  Created by Eric on 2019/3/15.
//  Copyright © 2019 Eric. All rights reserved.
//

#import "MixWebValue.h"
#import "MixWebUtils.h"

@interface MixWebValue ()

@property (nonatomic, readonly) NSMutableDictionary *dictionary;

@end

@implementation MixWebValue
@synthesize dictionary = _dictionary;

- (instancetype)initWithObject:(id)obj
{
    if (self = [super init]) {
        _obj = obj;
        if ([obj isKindOfClass:[NSDictionary class]]) {
            _dictionary = [NSMutableDictionary new];
            [self.dictionary addEntriesFromDictionary:obj];
        }
    }
    return self;
}

- (int)intV
{
    return [self.obj intValue];
}

- (long)longV
{
    return [self.obj longValue];
}

- (BOOL)boolV
{
    return [self.obj boolValue];
}

- (float)floatV
{
    return [self.obj floatValue];
}

- (double)doubleV
{
    return [self.obj doubleValue];
}

- (NSString *)string
{
    if (!self.obj || [self.obj isKindOfClass:[NSNull class]]) return nil;
    return [NSString stringWithFormat:@"%@", self.obj];
}

- (NSArray *)array
{
    return [self.obj isKindOfClass:[NSArray class]] ? self.obj : nil;
}

- (NSDictionary *)dict
{
    return [self.obj isKindOfClass:[NSDictionary class]] ? self.obj : nil;
}

- (UIColor *)color
{
    return [MixWebColor hex:self.string];
}

- (NSString *)description
{
    return [self.obj isKindOfClass:[NSDictionary class]] ? [self.dictionary description] : [self.obj description];
}

@end

MixWebValue* MixWebValueI(id obj)
{
    return [[MixWebValue alloc] initWithObject:obj];
}

@implementation MixWebValue (Dictionary)

- (MixWebValue *)valK:(NSString *)keyPath
{
    id obj = self.dictionary[keyPath];
    if (!obj) return nil;
    return MixWebValueI(obj);
}

- (id)objK:(NSString *)keyPath
{
    return [self valK:keyPath].obj;
}

- (int)intK:(NSString *)keyPath
{
    return [self valK:keyPath].intV;
}

- (long)longK:(NSString *)keyPath
{
    return [self valK:keyPath].longV;
}

- (BOOL)boolK:(NSString *)keyPath
{
    return [self valK:keyPath].boolV;
}

- (float)floatK:(NSString *)keyPath
{
    return [self valK:keyPath].floatV;
}

- (double)doubleK:(NSString *)keyPath
{
    return [self valK:keyPath].doubleV;
}

- (NSString *)stringK:(NSString *)keyPath
{
    return [self valK:keyPath].string;
}

- (NSArray *)arrayK:(NSString *)keyPath
{
    return [self valK:keyPath].array;
}

- (NSDictionary *)dictK:(NSString *)keyPath
{
    return [self valK:keyPath].dict;
}

- (UIColor *)colorK:(NSString *)keyPath
{
    return [self valK:keyPath].color;
}

- (void)set:(id)value key:(NSString *)keyPath
{
    if (!keyPath || !value) return;
    if (!_dictionary) _dictionary = [NSMutableDictionary new];
    NSArray *keyPaths = [keyPath componentsSeparatedByString:@"."];
    if (keyPaths.count == 1) {
        self.dictionary[keyPath] = value;
    }
    else {
        NSMutableDictionary *dict = self.dictionary;
        for (int i = 0; i < keyPaths.count - 1; i++) {
            NSString *key = keyPaths[i];
            id obj = dict[key];
            if (![obj isKindOfClass:[NSDictionary class]]) break;
            if (![obj isKindOfClass:[NSMutableDictionary class]]) {
                obj = [obj mutableCopy];
                dict[key] = obj;
            }
            dict = obj;
        }
        dict[[keyPaths lastObject]] = value;
    }
}

- (void)merge:(id)obj
{
    NSDictionary *dict;
    if ([obj isKindOfClass:[MixWebValue class]]) {
        dict = ((MixWebValue *)obj).dictionary;
    }
    else if ([obj isKindOfClass:[NSDictionary class]]) {
        dict = obj;
    }
    if (dict) {
        if (!_dictionary) _dictionary = [NSMutableDictionary new];
         [self.dictionary addEntriesFromDictionary:dict];
    }
}

- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context
{
    [self.dictionary addObserver:observer forKeyPath:keyPath options:options context:context];
}

- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath
{
    [self.dictionary removeObserver:observer forKeyPath:keyPath];
}

- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context
{
    [self.dictionary removeObserver:observer forKeyPath:keyPath context:context];
}

@end
