/* GPGMailBundle.m completely re-created by Lukas Pitschl (@lukele) on Thu 13-Jun-2013 */
/*
 * Copyright (c) 2000-2016, GPGTools Project Team <gpgtools-devel@lists.gpgtools.org>
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of GPGTools Project Team nor the names of GPGMail
 *       contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE GPGTools Project Team ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE GPGTools Project Team BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <mach-o/getsect.h>
#import <mach-o/dyld.h>
#import <dlfcn.h>
#import <objc/message.h>
#import <objc/runtime.h>
#import "CCLog.h"
#import "JRLPSwizzle.h"
#import "GMCodeInjector.h"
#import "MTBMailBundle.h"
#import "MVMailBundle.h"
#import "ComposeViewController.h"
#import "MTBReportingManager.h"
#import "MTBUpdateManager.h"

@interface MTBMailBundle ()

@end


#pragma mark Constants and global variables

NSString *MTBMailSwizzledMethodPrefix = @"MTB";

int MTBMailLoggingLevel = 0;

#pragma mark MTBMailBundle Implementation

@implementation MTBMailBundle

#pragma mark Multiple Installations

+ (NSArray *)multipleInstallations {
    NSArray *libraryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSAllDomainsMask, YES);
    NSString *bundlesPath = [@"Mail" stringByAppendingPathComponent:@"Bundles"];
    NSString *bundleName = @"MailTrackerBlocker.mailbundle";
    
    NSMutableArray *installations = [NSMutableArray array];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    for(NSString *libraryPath in libraryPaths) {
        NSString *bundlePath = [libraryPath stringByAppendingPathComponent:[bundlesPath stringByAppendingPathComponent:bundleName]];
        if([fileManager fileExistsAtPath:bundlePath])
            [installations addObject:bundlePath];
    }
    
    return (NSArray *)installations;
}

+ (void)showMultipleInstallationsErrorAndExit:(NSArray *)installations {
    NSAlert *errorModal = [[NSAlert alloc] init];
    
    errorModal.messageText = MTBLocalizedString(@"MTB_MULTIPLE_INSTALLATIONS_TITLE");
    errorModal.informativeText = [NSString stringWithFormat:MTBLocalizedString(@"MTB_MULTIPLE_INSTALLATIONS_MESSAGE"), [installations componentsJoinedByString:@"\n\n"]];
    [errorModal addButtonWithTitle:MTBLocalizedString(@"MTB_MULTIPLE_INSTALLATIONS_BUTTON")];
    [errorModal runModal];
    
    
    // It's not at all a good idea to use exit and kill the app,
    // but in this case it's alright because otherwise the user would experience a
    // crash anyway.
    exit(0);
}


#pragma mark Init, dealloc etc.

+ (void)initialize {    
    // Make sure the initializer is only run once.
    // Usually is run, for every class inheriting from
    // GPGMailBundle.
    if(self != [MTBMailBundle class])
        return;
    
    // If one happens to have for any reason (like for example installed GPGMail
    // from the installer, which will reside in /Library and compiled with XCode
    // which will reside in ~/Library) two GPGMail.mailbundle's,
    // display an error message to the user and shutdown Mail.app.
    NSArray *installations = [self multipleInstallations];
    if([installations count] > 1) {
        [self showMultipleInstallationsErrorAndExit:installations];
        return;
    }
    
    Class mvMailBundleClass = NSClassFromString(@"MVMailBundle");
    // If this class is not available that means Mail.app
    // doesn't allow plugins anymore. Fingers crossed that this
    // never happens!
    if(!mvMailBundleClass)
        return;

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated"
    class_setSuperclass([self class], mvMailBundleClass);
#pragma GCC diagnostic pop
    
    // Initialize the bundle by swizzling methods, loading keys, ...
    MTBMailBundle *instance = [MTBMailBundle sharedInstance];

    [[MTBReportingManager sharedInstance] purgeReports30DaysOrOlder];
    
    MTBUpdateManager *updater = [[MTBUpdateManager alloc] init];
    [updater scheduleCheck];
}

- (id)init {
	if (self = [super init]) {
		NSLog(@"Loaded MailTrackerBlocker %@", [self version]);
        
        NSBundle *myBundle = [MTBMailBundle bundle];
        [self _loadImages];
        
        [GMCodeInjector injectUsingMethodPrefix:MTBMailSwizzledMethodPrefix];
	}
    
	return self;
}

- (void)dealloc {

}

- (void)_loadImages {
    /**
     * Loads all images which are used in the MTB User interface.
     */
    // We need to load images and name them, because all images are searched by their name; as they are not located in the main bundle,
    // +[NSImage imageNamed:] does not find them.
    NSBundle *myBundle = [MTBMailBundle bundle];
    
    NSArray *bundleImageNames = @[@"possible",
                                  @"inactive",
                                  @"active"];
    NSMutableArray *bundleImages = [[NSMutableArray alloc] initWithCapacity:[bundleImageNames count]];
    
    for (NSString *name in bundleImageNames) {
        NSImage *image = [[NSImage alloc] initByReferencingFile:[myBundle pathForImageResource:name]];

        // Shoud an image not exist, log a warning, but don't crash because of inserting
        // nil!
        if(!image) {
            NSLog(@"MTB: Image %@ not found in bundle resources.", name);
            continue;
        }
        [image setName:name];
        [bundleImages addObject:image];
    }
    
    _bundleImages = bundleImages;
    
}

#pragma mark Localization Helper

+ (NSString *)localizedStringForKey:(NSString *)key {
    return NSLocalizedStringFromTableInBundle(key, @"Localizable", [MTBMailBundle bundle], nil);
}

#pragma mark General Infos

+ (NSBundle *)bundle {
    return [NSBundle bundleForClass:[MTBMailBundle class]];
}


- (NSString *)version {
    return [[MTBMailBundle bundle] infoDictionary][@"CFBundleShortVersionString"];
}

+ (NSString *)bundleVersion {
    /**
     Returns the version of the bundle as string.
     */
    return [[[MTBMailBundle bundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)bundleBuildNumber {
    return [[[MTBMailBundle bundle] infoDictionary] valueForKey:@"BuildNumber"];
}

+ (Class)resolveMailClassFromName:(NSString *)name {
    NSArray *prefixes = @[@"", @"MC", @"MF"];
    
    // MessageWriter is called MessageGenerator under Mavericks.
    if([name isEqualToString:@"MessageWriter"] && !NSClassFromString(@"MessageWriter"))
        name = @"MessageGenerator";
    
    __block Class resolvedClass = nil;
    [prefixes enumerateObjectsUsingBlock:^(NSString *prefix, NSUInteger idx, BOOL *stop) {
        NSString *modifiedName = [name copy];
        if([prefixes containsObject:[modifiedName substringToIndex:2]])
            modifiedName = [modifiedName substringFromIndex:2];
        
        NSString *className = [prefix stringByAppendingString:modifiedName];
        resolvedClass = NSClassFromString(className);
        if(resolvedClass)
            *stop = YES;
    }];
    
    return resolvedClass;
}

+ (NSError *)errorWithCode:(NSInteger)code userInfo:(nullable NSDictionary *)userInfo {
    NSString *errorDomain = @"MFMessageErrorDomain";
    
    NSError *mailError = nil;
    NSMutableDictionary *extendedUserInfo = [userInfo mutableCopy];
    extendedUserInfo[@"NSLocalizedDescription"] = userInfo[@"_MFShortDescription"];
    extendedUserInfo[@"NSLocalizedRecoverySuggestion"] = userInfo[@"NSLocalizedDescription"];
    mailError = [NSError errorWithDomain:errorDomain code:code userInfo:extendedUserInfo];
    
    return mailError;
}

+(BOOL)isAppearanceDark {
    NSAppearance * appearance = [NSApp effectiveAppearance];
    if (@available(macOS 10.14, *)) {
        NSAppearanceName basicAppearance = [appearance bestMatchFromAppearancesWithNames:@[
            NSAppearanceNameAqua,
            NSAppearanceNameDarkAqua
        ]];
        return [basicAppearance isEqualToString:NSAppearanceNameDarkAqua];
    } else {
        return NO;
    }
}

#pragma mark - mailbundle Application Support directory

+ (NSURL *)bundleApplicationSupportDirectory {
    NSError *error;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *applicationSupport = [manager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:false error:&error];
    NSString *identifier = [[MTBMailBundle bundle] bundleIdentifier];
    NSURL *folder = [applicationSupport URLByAppendingPathComponent:identifier];
    [manager createDirectoryAtURL:folder withIntermediateDirectories:true attributes:nil error:&error];
    return folder;
}
@end
