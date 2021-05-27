//
//  MailApp+MailTrackerBlocker.m
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2021/05/17.
//

#import "MailApp+MailTrackerBlocker.h"
#import "MTBCoreDataManager.h"
#import "MTBReportingManager.h"
#import "MTBPreferences.h"
#import "MTBUpdateManager.h"
#import "MTBPreferences.h"

#pragma mark - Mail App Lifecycle

@implementation MailApp_MailTrackerBlocker
-(void)MTBApplicationDidBecomeActive:(NSNotification *)aNotification {
    if (![MTBPreferences valueForKey:kMTBIsFirstStartupKey]) {
        MTBUpdateManager *updater = [[MTBUpdateManager alloc] init];
        // NSApplication sharedApplication's mainWindow is available here
        [updater requestAutoUpdatePermissionWith:^(BOOL granted) {}];
    }
    
    [self MTBApplicationDidBecomeActive:aNotification];
}

- (void)MTBApplicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    // Saves changes in the application's managed object context before the application terminates.
    [[MTBCoreDataManager sharedInstance] saveContext];
    
    [self MTBApplicationWillTerminate:aNotification];
}
@end
