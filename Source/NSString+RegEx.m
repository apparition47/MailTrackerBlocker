//
//  NSString+RegEx.m
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2020/08/02.
//

#import "NSString+RegEx.h"

@implementation NSString (RegEx)
- (NSRange)matchedRange:(NSRange)range from:(NSString*)pattern {
    NSRange match = NSMakeRange(NSNotFound, 0);
    if([self length] == 0)
        return match;
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *tcResult = [regex firstMatchInString:self options:0 range:range];
    if (tcResult != nil) {
        match = [tcResult range];
    }
    
    return match;
}
@end
