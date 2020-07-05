//	Copyright (c) 2007-2011 Jonathan 'Wolf' Rentzsch: http://rentzsch.com
//	Some rights reserved: http://opensource.org/licenses/mit-license.php

#import "JRLPSwizzle.h"
#import <objc/objc-class.h>
#import "CCLog.h"

#define SetNSErrorFor(FUNC, ERROR_VAR, FORMAT,...)	\
	if (ERROR_VAR) {	\
		NSString *errStr = [NSString stringWithFormat:@"%s: " FORMAT,FUNC,##__VA_ARGS__]; \
		*ERROR_VAR = [NSError errorWithDomain:@"NSCocoaErrorDomain" \
										 code:-1	\
									 userInfo:[NSDictionary dictionaryWithObject:errStr forKey:NSLocalizedDescriptionKey]]; \
	}
#define SetNSError(ERROR_VAR, FORMAT,...) SetNSErrorFor(__func__, ERROR_VAR, FORMAT, ##__VA_ARGS__)

#if OBJC_API_VERSION >= 2
#define GetClass(obj)	object_getClass(obj)
#else
#define GetClass(obj)	(obj ? obj->isa : Nil)
#endif

@implementation NSObject (JRLPSwizzle)

+ (BOOL)jrlp_swizzleMethod:(SEL)origSel_ withMethod:(SEL)altSel_ error:(NSError**)error_ {
#if OBJC_API_VERSION >= 2
	Method origMethod = class_getInstanceMethod(self, origSel_);
	if (!origMethod) {
		SetNSError(error_, @"original method %@ not found for class %@", NSStringFromSelector(origSel_), [self className]);
		return NO;
	}
	
	Method altMethod = class_getInstanceMethod(self, altSel_);
	if (!altMethod) {
		SetNSError(error_, @"alternate method %@ not found for class %@", NSStringFromSelector(altSel_), [self className]);
		return NO;
	}
	
	class_addMethod(self,
					origSel_,
					class_getMethodImplementation(self, origSel_),
					method_getTypeEncoding(origMethod));
	class_addMethod(self,
					altSel_,
					class_getMethodImplementation(self, altSel_),
					method_getTypeEncoding(altMethod));
	
	method_exchangeImplementations(class_getInstanceMethod(self, origSel_), class_getInstanceMethod(self, altSel_));
	return YES;
#else
	//	Scan for non-inherited methods.
	Method directOriginalMethod = NULL, directAlternateMethod = NULL;
	
	void *iterator = NULL;
	struct objc_method_list *mlist = class_nextMethodList(self, &iterator);
	while (mlist) {
		int method_index = 0;
		for (; method_index < mlist->method_count; method_index++) {
			if (mlist->method_list[method_index].method_name == origSel_) {
				assert(!directOriginalMethod);
				directOriginalMethod = &mlist->method_list[method_index];
			}
			if (mlist->method_list[method_index].method_name == altSel_) {
				assert(!directAlternateMethod);
				directAlternateMethod = &mlist->method_list[method_index];
			}
		}
		mlist = class_nextMethodList(self, &iterator);
	}
	
	//	If either method is inherited, copy it up to the target class to make it non-inherited.
	if (!directOriginalMethod || !directAlternateMethod) {
		Method inheritedOriginalMethod = NULL, inheritedAlternateMethod = NULL;
		if (!directOriginalMethod) {
			inheritedOriginalMethod = class_getInstanceMethod(self, origSel_);
			if (!inheritedOriginalMethod) {
				SetNSError(error_, @"original method %@ not found for class %@", NSStringFromSelector(origSel_), [self className]);
				return NO;
			}
		}
		if (!directAlternateMethod) {
			inheritedAlternateMethod = class_getInstanceMethod(self, altSel_);
			if (!inheritedAlternateMethod) {
				SetNSError(error_, @"alternate method %@ not found for class %@", NSStringFromSelector(altSel_), [self className]);
				return NO;
			}
		}
		
		int hoisted_method_count = !directOriginalMethod && !directAlternateMethod ? 2 : 1;
		struct objc_method_list *hoisted_method_list = malloc(sizeof(struct objc_method_list) + (sizeof(struct objc_method)*(hoisted_method_count-1)));
        hoisted_method_list->obsolete = NULL;	// soothe valgrind - apparently ObjC runtime accesses this value and it shows as uninitialized in valgrind
		hoisted_method_list->method_count = hoisted_method_count;
		Method hoisted_method = hoisted_method_list->method_list;
		
		if (!directOriginalMethod) {
			bcopy(inheritedOriginalMethod, hoisted_method, sizeof(struct objc_method));
			directOriginalMethod = hoisted_method++;
		}
		if (!directAlternateMethod) {
			bcopy(inheritedAlternateMethod, hoisted_method, sizeof(struct objc_method));
			directAlternateMethod = hoisted_method;
		}
		class_addMethods(self, hoisted_method_list);
	}
	
	//	Swizzle.
	IMP temp = directOriginalMethod->method_imp;
	directOriginalMethod->method_imp = directAlternateMethod->method_imp;
	directAlternateMethod->method_imp = temp;
	
	return YES;
#endif
}

+ (BOOL)jrlp_swizzleClassMethod:(SEL)origSel_ withClassMethod:(SEL)altSel_ error:(NSError**)error_ {
	return [GetClass((id)self) jrlp_swizzleMethod:origSel_ withMethod:altSel_ error:error_];
}

+ (BOOL)jrlp_addMethodsFromClass:(Class)aClass error:(NSError **)error {
	unsigned int methodCount;
    SEL currentSelector;
    Method *classMethods;
    for(unsigned int i = 0; i < 2; i++) {
        classMethods = class_copyMethodList(i == 0 ? aClass : object_getClass(aClass), &methodCount);
        DebugLog(@"Number of methods found for class %@: %u", aClass, methodCount);
        
        for (unsigned int j = 0; j < methodCount; j++) {
            currentSelector = method_getName((Method)classMethods[j]);
            DebugLog(@"%d: Adding method %@ from %@", i, NSStringFromSelector(currentSelector), i == 0 ? aClass : object_getClass(aClass));
            [i == 0 ? self : object_getClass(self) jrlp_addMethod:currentSelector fromClass:i == 0 ? aClass : object_getClass(aClass) error:error];
            if(*error) {
                DebugLog(@"failed to add method: %@", NSStringFromSelector(currentSelector));
                free(classMethods);
                return NO;
            }
        }
        free(classMethods);
    }
    
    return YES;
}

+ (BOOL)jrlp_addMethod:(SEL)selector fromClass:(Class)class error:(NSError **)error {
    Method method = class_getInstanceMethod(class, selector);
    if (method == NULL) {
        SetNSError(error, @"method %@ doesn't exit in class: %@", NSStringFromSelector(selector), [self class]);
        return NO;
    }
    class_addMethod(self, selector, method_getImplementation(method), method_getTypeEncoding(method));
    return YES;
}

+ (BOOL)jrlp_addClassMethod:(SEL)selector fromClass:(Class)class error:(NSError **)error {
    return [object_getClass(self) jrlp_addClassMethod:selector fromClass:class error:error];
}

+ (BOOL)jrlp_swizzleMethod:(SEL)selector newMethodName:(SEL)newMethodName withBlock:(id)block error:(NSError **)error {
    NSAssert(self && selector && newMethodName && block, @"Pass the correct arguments");
    
    if([self respondsToSelector:newMethodName])
        return YES;
    
    Method origMethod = class_getInstanceMethod(self, selector);
    
    // Add the new method.
    IMP impl = imp_implementationWithBlock(block);
    if(!class_addMethod(self, newMethodName, impl, method_getTypeEncoding(origMethod))) {
        SetNSError(error, @"Not able to swizzle method %@ on class %@", NSStringFromSelector(selector), [self className]);
        return NO;
    }
    else {
        Method newMethod = class_getInstanceMethod(self, newMethodName);
        method_exchangeImplementations(origMethod, newMethod);
    }
    
    return YES;
}

@end
