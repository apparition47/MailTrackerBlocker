//
//  MTBWindowController.h
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2021/07/17.
//

#import <AppKit/AppKit.h>

// https://stackoverflow.com/questions/13618382/nswindowcontroller-showwindow-flashes-the-window
// Singleton to hold strong refs to windows for macOS Sierra 10.12 to prevent ARC release
// when creating WindowControllers
// unnecessary for newer versions of macOS
@interface MTBWindowController : NSWindowController <NSWindowDelegate>

@end

