//
//  MTBPreferences.m
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2021/05/18.
//

#import "MTBPreferences.h"

static NSString *const MTBUserDefaultsPrefix = @"_mtb_";

NSString *const kMTBIsFirstStartupKey = @"IsFirstStartup";
NSString *const kMTBIsAutoUpdateCheckAllowedKey = @"IsAutoUpdateCheckAllowed";


@implementation MTBPreferences

+(void)save:(nullable NSString*)key value:(id)value {
    NSString *prefixedKey = [MTBUserDefaultsPrefix stringByAppendingString:key];
    
    if (!value) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:prefixedKey];
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:prefixedKey];
}

+(id)valueForKey:(NSString*)key {
    NSString *prefixedKey = [MTBUserDefaultsPrefix stringByAppendingString:key];
    return [[NSUserDefaults standardUserDefaults] valueForKey:prefixedKey];
}
@end
