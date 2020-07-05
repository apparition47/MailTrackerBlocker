//
//  TestHelpers.m
//  GPGMail
//
//  Created by Lukas Pitschl on 06.08.13.
//
//

#import <AppKit/AppKit.h>
#import "TestHelpers.h"
#import "CDMachOFile.h"
#import "CDOCClass.h"
#import "CDObjectiveCProcessor.h"
#import <objc/runtime.h>

@implementation TestHelpers

+ (NSArray *)requiredFrameworks {
    NSArray *frameworks = @[@"/System/Library/PrivateFrameworks/CoreMessage.framework",
                            @"/System/Library/PrivateFrameworks/IMAP.framework",
                            @"/System/Library/Frameworks/Message.framework"];
    if(floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_8) {
        frameworks = @[@"/System/Library/PrivateFrameworks/MailCore.framework",
                       @"/System/Library/PrivateFrameworks/Mail.framework",
                       @"/System/Library/PrivateFrameworks/MailUI.framework"];
    }
	return frameworks;
}

+ (NSString *)systemRootPath {
	return @"/";
}

+ (void)loadFrameworks {
	for(NSString *frameworkPath in [self requiredFrameworks])
		[self loadBundleAtPath:[[TestHelpers systemRootPath] stringByAppendingString:frameworkPath]];
}

+ (void)loadBundleAtPath:(NSString *)path {
	NSBundle *bundle;
	bundle = [NSBundle bundleWithPath:path];
	
	// Try to load the bundle but with load instead of loadAndReturnError,
    // since that appears to reveal more information on why the bundle couldn't be loaded.
	if(![bundle load])
        return;
}

+ (void)loadGPGMail {
	NSString *GPGMailPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"GPGMail" ofType:@"mailbundle" inDirectory:nil];
	// First, load the frameworks otherwise GPGMailBundle won't load, since it depends on them.
	[self loadFrameworks];
	[self loadBundleAtPath:GPGMailPath];
	[self loadMail];
}

+ (void)loadMail {
	[self mailClasses];
}

+ (NSArray *)mailClasses {
	static dispatch_once_t onceToken;
	static NSArray *_mailClasses;
	dispatch_once(&onceToken, ^{
		NSString *cdPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"cd-bundle" ofType:@"bundle" inDirectory:nil];
		[self loadBundleAtPath:cdPath];
		
		NSString *mailPath = [[TestHelpers systemRootPath] stringByAppendingString:@"/Applications/Mail.app/Contents/MacOS/Mail"];
		
		CDMachOFile *file = (CDMachOFile *)[NSClassFromString(@"CDFile") fileWithContentsOfFile:mailPath searchPathState:nil];
		CDObjectiveCProcessor *processor = [[[file processorClass] alloc] initWithMachOFile:file];
		[processor process];
		
		_mailClasses = processor.classes;
	});
	return _mailClasses;
}

+ (id)classWithName:(NSString *)name {
	return NSClassFromString(name) ? : [self classFromMailAppWithName:name];
}

+ (CDOCClass *)classFromMailAppWithName:(NSString *)name {
	for(id class in [self mailClasses])
		if([[class name] isEqualToString:name])
			return class;
	return nil;
}

+ (BOOL)class:(id)class respondsToSelectorWithName:(NSString *)selectorName {
	if(![class isKindOfClass:[NSClassFromString(@"CDOCClass") class]])
		return [class respondsToSelector:NSSelectorFromString(selectorName)];
	
	__block BOOL found = NO;
	[[class classMethods] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if([[obj name] isEqualToString:selectorName]) {
			found = YES;
			*stop = YES;
		}
	}];
	return found;
}

+ (BOOL)instancesOfClass:(id)class respondToSelectorWithName:(NSString *)selectorName {
	if(![class isKindOfClass:[NSClassFromString(@"CDOCClass") class]])
		return class_getInstanceMethod(class, NSSelectorFromString(selectorName)) != NULL;
	
	__block BOOL found = NO;
	[[class instanceMethods] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if([[obj name] isEqualToString:selectorName]) {
			found = YES;
			*stop = YES;
		}
	}];
	return found;
}


@end
