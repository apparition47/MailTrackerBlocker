//
//  NSButton+Init.m
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2021/03/06.
//

#import "NSButton+Init.h"

#if defined(__MAC_OS_X_VERSION_MAX_ALLOWED) && __MAC_OS_X_VERSION_MAX_ALLOWED < 101200 // 10.12
@implementation NSButton (Init)
+(NSButton*)buttonWithImage: (NSImage*)image target:(id)target action:(SEL)action {
    NSButton *button = [[NSButton alloc] init];
    [button setImage: image];
    [button setTarget: target];
    [button setAction: action];
    return button;
}
@end
#endif
