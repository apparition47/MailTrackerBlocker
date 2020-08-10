//
//  NSString+RegEx.m
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2020/08/02.
//

#import "NSString+RegEx.h"

@implementation NSString (RegEx)
- (BOOL)hasMatchFromPattern:(NSString*)pattern {
    return [self rangeFromPattern:pattern].location != NSNotFound;
}

- (NSRange)rangeFromPattern:(NSString*)pattern {
    NSRange match = NSMakeRange(NSNotFound, 0);
    if([self length] == 0)
        return match;
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSRange range = NSMakeRange(0, self.length);
    NSTextCheckingResult *tcResult = [regex firstMatchInString:self options:0 range:range];
    if (tcResult != nil) {
        match = [tcResult range];
    }
    
    return match;
}
@end
