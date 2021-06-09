//
//  MTBPreferences.h
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2021/05/18.
//

#import <Foundation/Foundation.h>

extern NSString * _Nonnull const kMTBIsFirstStartupKey;
extern NSString * _Nonnull const kMTBIsAutoUpdateCheckAllowedKey;
extern NSString * _Nonnull const kMTBLastUpdateCheckDateKey;

@interface MTBPreferences : NSObject
+(void)save:(NSString*)key value:(nullable id)value;
+(id)valueForKey:(NSString*)key;
@end
