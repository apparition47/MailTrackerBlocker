//
//  NSButton+Init.h
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2021/03/06.
//

#import <Foundation/Foundation.h>

#if defined(__MAC_OS_X_VERSION_MAX_ALLOWED) && __MAC_OS_X_VERSION_MAX_ALLOWED < 101200 // 10.12
@interface NSButton (Init)
+ (NSButton*) buttonWithImage:(NSImage*)image target:(id)target action:(SEL)action;
@end
#endif

