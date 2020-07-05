/* IntegrationHooks.m created by Lukas Pitschl (@lukele) on Mon 24-Jun-2013 */

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

#import <XCTest/XCTest.h>
#import "TestHelpers.h"
#import "GMCodeInjector.h"

@interface IntegrationHooks : XCTestCase

@end

@implementation IntegrationHooks

+ (void)setUp {
	[super setUp];
	
	[TestHelpers loadGPGMail];
}

- (void)testRequiredFrameworksExist {
	NSArray *frameworks = [TestHelpers requiredFrameworks];
	for(__strong id framework in frameworks) {
		NSError * __autoreleasing error;
		// Try to load the framework.
		NSBundle *frameworkBundle = [NSBundle bundleWithPath:framework];
		BOOL success = [frameworkBundle loadAndReturnError:&error];
		XCTAssertTrue(success && frameworkBundle != nil, @"Framework couldn't be loaded at path: %@\nError: %@", framework, !success && error ? error : @"N/A");
	}
}

- (void)testRequiredHooksExist {
	// Make sure the GMCodeInjector is available.
	XCTAssertTrue(NSClassFromString(@"GMCodeInjector") != nil, @"Fuck this!");
	NSDictionary *hooks = [NSClassFromString(@"GMCodeInjector") hooks];
	for(NSString *className in hooks) {
		NSArray *selectorNames = hooks[className];
		
		// Firt check if the class is from frameworks or form Mail.app itself.
		id mailClass = [TestHelpers classWithName:className];
		// Make sure the class exists.
		XCTAssertNotNil(mailClass, @"Class %@ doesn't exist. This will lead to problems!", className);
		// Test all the selectors.
		for(id selectorName in selectorNames) {
            NSString *newSelectorName = [selectorName isKindOfClass:[NSArray class]] ? selectorName[1] : selectorName;
            unsigned int match = 0;
			if([TestHelpers instancesOfClass:mailClass respondToSelectorWithName:newSelectorName])
				match += 1;
			if([TestHelpers class:mailClass respondsToSelectorWithName:newSelectorName])
				match += 1;
			
			XCTAssertTrue(match, @"Class %@ doesn't implement selector %@", className, newSelectorName);
		}
	}
}

@end
