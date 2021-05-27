//
//  NSColor+Style.m
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2021/04/28.
//

#import "NSColor+Style.h"
#import "MTBMailBundle.h"

@implementation NSColor (Style)
+(NSColor*)mtbStatCellBackground {
    if ([MTBMailBundle isAppearanceDark]) {
        return [NSColor colorWithRed: 0.18 green: 0.19 blue: 0.20 alpha: 1.00];
    }
    return [NSColor colorWithRed: 0.95 green: 0.95 blue: 0.95 alpha: 1.00];
}
@end
