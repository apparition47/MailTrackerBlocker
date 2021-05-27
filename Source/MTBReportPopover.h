//
//  MTBReportPopover.h
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2021/04/18.
//

#import <Cocoa/Cocoa.h>
#import "MTBBlockedMessage.h"

@interface MTBReportPopover : NSViewController
@property(retain) MTBBlockedMessage *blockedMessage;
@end
