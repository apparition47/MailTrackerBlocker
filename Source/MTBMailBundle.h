/* GPGMailBundle.h created by dave on Thu 29-Jun-2000 */
/* GPGMailBundle.h re-created by Lukas Pitschl (@lukele) on Fri 14-Jun-2013 */

/*
 * Copyright (c) 2000-2013, GPGToolz Project Team <gpgtoolz-devel@lists.gpgtoolz.org>
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of GPGToolz Project Team nor the names of GPGMail
 *       contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE GPGToolz Project Team ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE GPGToolz Project Team BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <CoreFoundation/CoreFoundation.h>

#if !__has_feature(nullability)
#define nullable
#endif

@class Message, GMMessageRulesApplier, GMKeyManager;

@interface MTBMailBundle : NSObject <NSToolbarDelegate> {

    NSMutableArray *_bundleImages;
}

/**
 Checks for multiple installations of GPGMail.mailbundle in
 all Library folders.
 */
+ (NSArray *)multipleInstallations;

/**
 Warn the user that multiple installations were found and
 bail out.
 */
+ (void)showMultipleInstallationsErrorAndExit:(NSArray *)installations;

// Load all necessary images.
- (void)_loadImages;

// Returns the bundle version.
+ (NSString *)bundleVersion;
- (NSString *)version;

/**
 Returns the NSBundle for GPGMail.
 It's a bit faster than [NSBundle bundleForClass:[self class]].
 */
+ (NSBundle *)bundle;

+ (NSString *)localizedStringForKey:(NSString *)key;

/**
 On Mavericks most Mail classes have been prefixed.
 This method receives the old name and tries to find the matching
 new class.
 */
+ (Class)resolveMailClassFromName:(NSString *)name;

+ (NSError *)errorWithCode:(NSInteger)code userInfo:(nullable NSDictionary *)userInfo;

@end

@interface MTBMailBundle (NoImplementation)
// Prevent "incomplete implementation" warning.
+ (id)sharedInstance;
@end


