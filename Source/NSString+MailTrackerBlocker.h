//
//  NSString+MailTrackerBlocker.m
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2020/07/05.
//

#import <Foundation/NSString.h>


@interface NSString (MTBMail)

/**
 Returns a string with all tracker URLs in HTML replaced with safe URLs
 */
- (NSString*)trackerSanitized;

@end
