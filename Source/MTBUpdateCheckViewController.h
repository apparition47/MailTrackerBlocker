//
//  MTBUpdateCheckViewController.h
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2021/05/19.
//

#import <AppKit/AppKit.h>
#import "MTBUpdateManager.h"

@interface MTBUpdateCheckViewController : NSViewController
-(instancetype)initWithNibWithUpdateURL:(nullable NSURL*)updateURL updater:(MTBUpdateManager*)updatr;
@end

