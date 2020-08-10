//
//  NSString+RegEx.h
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2020/08/02.
//

#import <Foundation/Foundation.h>

@interface NSString (RegEx)
- (BOOL)hasMatchFromPattern:(NSString*)pattern;
/**
 Get range from a regex string. Returns NSNotFound if non-existent.
 */
- (NSRange)rangeFromPattern:(NSString*)pattern;
@end
