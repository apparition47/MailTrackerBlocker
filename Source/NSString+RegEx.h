//
//  NSString+RegEx.h
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2020/08/02.
//

#import <Foundation/Foundation.h>

/**
 Get range from a regex string. Returns NSNotFound if non-existent.
 */
@interface NSString (RegEx)
- (NSRange)matchedRange:(NSRange)range from:(NSString*)pattern;
@end
