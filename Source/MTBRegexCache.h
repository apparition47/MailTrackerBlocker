//
//  RegexCache.h
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2021/03/09.
//

#import <Foundation/Foundation.h>

@interface MTBRegexCache : NSObject
+ (instancetype)sharedCache;
- (NSRegularExpression*) regularExpressionWithPattern:(NSString*)pattern options:(NSRegularExpressionOptions)options error:(NSError**)error;
@end
