//
//  NSObject+Json.m
//  Interview02-runtime应用
//
//  Created by MJ Lee on 2018/5/29.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "NSObject+Json.h"
#import <objc/runtime.h>

@implementation NSObject (Json)

+ (instancetype)mj_objectWithJson:(NSDictionary *)json
{
    id obj = [[self alloc] init];
    
    unsigned int count;
    /*
     struct objc_ivar {
         char * _Nullable ivar_name                               OBJC2_UNAVAILABLE;
         char * _Nullable ivar_type                               OBJC2_UNAVAILABLE;
         int ivar_offset                                          OBJC2_UNAVAILABLE;
     #ifdef __LP64__
         int space                                                OBJC2_UNAVAILABLE;
     #endif
     }
     */
    Ivar *ivars = class_copyIvarList(self, &count);
    for (int i = 0; i < count; i++) {
        // 取出i位置的成员变量
        Ivar ivar = ivars[i];
        // _no
        NSMutableString *name = [NSMutableString stringWithUTF8String:ivar_getName(ivar)];
        [name deleteCharactersInRange:NSMakeRange(0, 1)];
        
        // 设值
        id value = json[name];
        if ([name isEqualToString:@"ID"]) {
            value = json[@"id"];
        }
        [obj setValue:value forKey:name];// KVC
    }
    free(ivars);
    
    
    count = 0;
//    /*
//     /// Defines a property attribute
//     typedef struct {
//         const char * _Nonnull name;           /**< The name of the attribute */
//         const char * _Nonnull value;          /**< The value of the attribute (usually empty) */
//     } objc_property_attribute_t;
//
//     */
    objc_property_t *properties = class_copyPropertyList(self, &count);
    for ( int i = 0 ; i < count ; i ++ ) {
    
        objc_property_t property = properties[i];
        
        // 1.属性名 no
        NSMutableString *name = [NSMutableString stringWithUTF8String:property_getName(property)];
        // 2.成员类型
        NSString *attrs = @(property_getAttributes(property));
        NSUInteger dotLoc = [attrs rangeOfString:@","].location;
        NSString *code = nil;
        NSUInteger loc = 1;
        if (dotLoc == NSNotFound) { // 没有,
            code = [attrs substringFromIndex:loc];
        } else {
            code = [attrs substringWithRange:NSMakeRange(loc, dotLoc - loc)];
        }
        
        
        // 设值
        id value = json[name];
        if ([name isEqualToString:@"ID"]) {
            value = json[@"id"];
        }
        [obj setValue:value forKey:name];// KVC
    }
    
    return obj;
}

@end
