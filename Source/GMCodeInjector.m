/* GMCodeInjector.m created by Lukas Pitschl (@lukele) on Fri 14-Jun-2013 */

/*
 * Copyright (c) 2000-2013, GPGToolz Team <team@gpgtoolz.org>
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of GPGToolz nor the names of GPGMail
 *       contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE GPGToolz Team ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE GPGToolz Team BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "CCLog.h"
#import "MailTrackerBlocker_Prefix.pch"
#import "JRLPSwizzle.h"
#import "MTBMailBundle.h"
#import "GMCodeInjector.h"

@implementation GMCodeInjector

+ (NSDictionary *)commonHooks {
	return @{
        @"ComposeBackEnd": @[
            @"generatedMessageBodies"
        ],
        @"ConversationMember": @[
            @"setWebDocument:"
        ],
        @"WebDocumentGenerator": @[
            @"setWebDocument:"
        ],
        @"HeaderViewController": @[
            @"observeValueForKeyPath:ofObject:change:context:",
            @"dealloc",
            @"viewDidLoad"
        ]
    };
}

+ (NSDictionary *)hooks {
    NSDictionary *_hooks = [self commonHooks];
	return _hooks;
}

+ (NSString *)legacyClassNameForName:(NSString *)className {
    // Some classes have been renamed in Mavericks.
    // This methods converts known classes to their counterparts in Mavericks.
    if([@[@"MC", @"MF"] containsObject:[className substringToIndex:2]])
        return [className substringFromIndex:2];
    return className;
}


+ (void)injectUsingMethodPrefix:(NSString *)prefix hooks:(NSDictionary*)hooks{
    /**
     This method replaces all of Mail's methods which are necessary for GPGMail
     to work correctly.
     
     For each class of Mail that must be extended, a class with the same name
     and suffix _GPGMail (<ClassName>_GPGMail) exists which implements the methods
     to be relaced.
     On runtime, these methods are first added to the original Mail class and
     after that, the original Mail methods are swizzled with the ones of the
     <ClassName>_GPGMail class.
     
     swizzleMap contains all classes and methods which need to be swizzled.
     */
    
    NSString *extensionClassSuffix = @"MailTrackerBlocker";
    
    NSError * __autoreleasing error = nil;
    for(NSString *class in hooks) {
        NSString *klass = class;
        NSString *oldClass = [[self class] legacyClassNameForName:class];
        error = nil;
        
        NSArray *selectors = hooks[class];
        
        Class mailClass = NSClassFromString(class);
        if(!mailClass) {
            DebugLog(@"WARNING: Class %@ doesn't exist. This leads to unexpected behaviour!", class);
            continue;
        }
        
        // Check if a class exists with <class>_GPGMail. If that's
        // the case, all the methods of that class, have to be added
        // to the original Mail or Messages class.
        Class extensionClass = NSClassFromString([oldClass stringByAppendingFormat:@"_%@", extensionClassSuffix]);
        if(!extensionClass) {
            // In order to correctly hook classes on older versions of OS X than 10.9, the MC and MF prefix
            // is removed. There are however some cases, where classes where added to 10.9 which didn't exist
            // on < 10.9. In those cases, let's try to find the class with the appropriate prefix.
            
            // Try to find extensions to the original classname.
            extensionClass = NSClassFromString([class stringByAppendingFormat:@"_%@", extensionClassSuffix]);
        }
        BOOL extend = extensionClass != nil ? YES : NO;
        if(extend) {
            if(![mailClass jrlp_addMethodsFromClass:extensionClass error:&error])
                DebugLog(@"WARNING: methods of class %@ couldn't be added to %@ - %@", extensionClass,
                         mailClass, error);
        }
        
        // And on to swizzling methods and class methods.
        for(id selectorNames in selectors) {
            // If the selector changed from one OS X version to the other, selectorNames is an NSArray and
            // the selector name of the GPGMail implementation is item 0 and the Mail implementation name is
            // item 1.
            NSString *gmSelectorName = [selectorNames isKindOfClass:[NSArray class]] ? selectorNames[0] : selectorNames;
            NSString *mailSelectorName = [selectorNames isKindOfClass:[NSArray class]] ? selectorNames[1] : selectorNames;
            
            error = nil;
            NSString *extensionSelectorName = [NSString stringWithFormat:@"%@%@%@", prefix, [[gmSelectorName substringToIndex:1] uppercaseString],
                                               [gmSelectorName substringFromIndex:1]];
            SEL selector = NSSelectorFromString(mailSelectorName);
            SEL extensionSelector = NSSelectorFromString(extensionSelectorName);
            // First try to add as instance method.
            if(![mailClass jrlp_swizzleMethod:selector withMethod:extensionSelector error:&error]) {
                // If that didn't work, try to add as class method.
                if(![mailClass jrlp_swizzleClassMethod:selector withClassMethod:extensionSelector error:&error])
                    DebugLog(@"WARNING: %@ doesn't respond to selector %@", NSStringFromClass(mailClass),
                             NSStringFromSelector(selector));
            }
        }
    }
}

+ (void)injectUsingMethodPrefix:(NSString *)prefix {
    [self injectUsingMethodPrefix:prefix hooks:[self hooks]];
}

@end
