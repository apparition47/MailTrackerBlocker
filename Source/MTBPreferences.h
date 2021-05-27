//
//  MTBPreferences.h
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2021/05/18.
//

#import <Foundation/Foundation.h>

extern NSString *const kMTBIsFirstStartupKey;
extern NSString *const kMTBIsAutoUpdateCheckAllowedKey;

@interface MTBPreferences : NSObject
+(void)save:(NSString*)key value:(nullable id)value;
+(id)valueForKey:(NSString*)key;
@end
