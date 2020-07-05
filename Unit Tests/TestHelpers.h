//
//  TestHelpers.h
//  GPGMail
//
//  Created by Lukas Pitschl on 06.08.13.
//
//

#import <Foundation/Foundation.h>

@interface TestHelpers : NSObject

+ (NSArray *)requiredFrameworks;
+ (void)loadFrameworks;
+ (void)loadBundleAtPath:(NSString *)path;
+ (void)loadGPGMail;
+ (NSArray *)mailClasses;
+ (id)classWithName:(NSString *)name;
+ (BOOL)class:(id)class respondsToSelectorWithName:(NSString *)selectorName;
+ (BOOL)instancesOfClass:(id)class respondToSelectorWithName:(NSString *)selectorName;

@end
