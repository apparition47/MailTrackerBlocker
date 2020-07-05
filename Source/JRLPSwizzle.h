//	Copyright (c) 2007-2011 Jonathan 'Wolf' Rentzsch: http://rentzsch.com
//	Some rights reserved: http://opensource.org/licenses/mit-license.php

#import <Foundation/Foundation.h>

@interface NSObject (JRLPSwizzle)

+ (BOOL)jrlp_swizzleMethod:(SEL)origSel_ withMethod:(SEL)altSel_ error:(NSError**)error_;
+ (BOOL)jrlp_swizzleClassMethod:(SEL)origSel_ withClassMethod:(SEL)altSel_ error:(NSError**)error_;
+ (BOOL)jrlp_addClassMethod:(SEL)selector fromClass:(Class)class error:(NSError **)error;
+ (BOOL)jrlp_addMethod:(SEL)selector fromClass:(Class)class error:(NSError **)error;
+ (BOOL)jrlp_addMethodsFromClass:(Class)aClass error:(NSError **)error;
+ (BOOL)jrlp_swizzleMethod:(SEL)selector newMethodName:(SEL)newMethodName withBlock:(id)block error:(NSError **)error;
@end
