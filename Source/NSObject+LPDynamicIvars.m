//
//  Category.m
//  GPGMail
//
//  Created by Lukas Pitschl on 17.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSObject+LPDynamicIvars.h"
#import <objc/runtime.h>

@implementation NSObject (LPDynamicIvars)

- (void)setIvar:(id)key value:(id)value {
    [self setIvar:key value:value assign:NO];
}

- (void)setIvar:(id)key value:(id)value assign:(BOOL)shouldAssign {
    if(shouldAssign)
        objc_setAssociatedObject(self, (__bridge const void *)(key), value, OBJC_ASSOCIATION_ASSIGN);
    else
        objc_setAssociatedObject(self, (__bridge const void *)(key), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)getIvar:(id)key {
    return objc_getAssociatedObject(self, (__bridge const void *)(key));
}

- (void)removeIvar:(id)key {
    [self setIvar:key value:nil];
}

- (BOOL)ivarExists:(id)key {
    return [self getIvar:key] == nil ? NO : YES;
}

- (void)removeIvars {
    objc_removeAssociatedObjects(self);
}

@end
