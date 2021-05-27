//
//  MTBUpdateManager.m
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2021/05/18.
//

#import "MTBUpdateManager.h"
#import "MTBGitHubReleases.h"
#import "MTBMailBundle.h"
#import "MTBPreferences.h"
#import "MTBUpdateCheckViewController.h"
#import "MTBPackageValidator.h"

@interface MTBUpdateManager ()

@end

@implementation MTBUpdateManager

-(void)requestAutoUpdatePermissionWith:(void (^)(BOOL granted))completion {
    __weak typeof(self) weakSelf = self;
    NSWindow *mainWindow = [[NSApplication sharedApplication] mainWindow];
    if (!mainWindow) {
        return;
    }
    NSAlert *alert = [NSAlert new];
    [alert setMessageText:MTBLocalizedString(@"UPDATE_MTB")];
    [alert setInformativeText:MTBLocalizedString(@"UPDATE_PERMISSION_REQUEST")];
    [alert addButtonWithTitle:MTBLocalizedString(@"UPDATE_CANCEL")];
    [alert addButtonWithTitle:@"OK"];
    [alert setIcon:[NSImage imageNamed:@"active"]];
    [alert beginSheetModalForWindow:mainWindow completionHandler:^(NSModalResponse returnCode) {
        __strong typeof(self) strongSelf = weakSelf;
        [MTBPreferences save:kMTBIsAutoUpdateCheckAllowedKey value:returnCode == NSAlertSecondButtonReturn ? @YES : @NO];
        
        [strongSelf checkBundleUpdateAvailableWith:^(NSURL *latestDownloadURL) {}];
    }];
    
    [MTBPreferences save:kMTBIsFirstStartupKey value:@YES];
}

-(void)scheduleCheck {
    [self checkBundleUpdateAvailableWith:^(NSURL *latestDownloadURL) {}];
    
    // schedule update check
    NSBackgroundActivityScheduler *activity = [[NSBackgroundActivityScheduler alloc] initWithIdentifier:@"com.oneefatgiraffe.mailtrackerblocker.updater"];
    activity.repeats = YES;
    activity.interval = 24 * 60 * 60; // seconds
    activity.tolerance = 1 * 60 * 60;
    
    __weak typeof(self) weakSelf = self;
    [activity
    scheduleWithBlock:^(NSBackgroundActivityCompletionHandler completion) {
        if (activity.shouldDefer) {
            completion(NSBackgroundActivityResultDeferred);
            return;
        }
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf checkBundleUpdateAvailableWith:^(NSURL *latestDownloadURL) {
            completion(NSBackgroundActivityResultFinished);
        }];
    }];
}

-(void)checkBundleUpdateAvailableWith:(void (^)(NSURL *latestDownloadURL))completion {
    if (![MTBPreferences valueForKey:kMTBIsAutoUpdateCheckAllowedKey]) {
        return;
    }
    
    [[[MTBGitHubReleases alloc] init] checkLatestWithCompletion:^(NSString *latestPubVersion, NSURL *pkgURL) {
        NSString* installedVer = [MTBMailBundle bundleVersion];
        // installedVer is lower than the latestPubVersion
        if ([latestPubVersion compare:installedVer options:NSNumericSearch] == NSOrderedDescending) {
            NSViewController *vc = [[MTBUpdateCheckViewController alloc] initWithNibWithUpdateURL:pkgURL updater:self];

            NSWindow *window = [[NSWindow alloc] init];
            NSUInteger masks = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskTexturedBackground;
            [window setStyleMask:masks];
            [window setContentViewController:vc];
            [window setTitle:MTBLocalizedString(@"UPDATE_MTB")];
            
            NSWindowController *wc = [[NSWindowController alloc] initWithWindow:window];
            CGFloat xPos = NSWidth([[window screen] frame])/2 - NSWidth([window frame])/2;
            CGFloat yPos = NSHeight([[window screen] frame])/2 - NSHeight([window frame])/2;
            [window setFrame:NSMakeRect(xPos, yPos, NSWidth([window frame]), NSHeight([window frame])) display:YES];
            [wc showWindow:nil];
            completion(pkgURL);
        } else {
            completion(nil);
        }
    }];
}

-(void)downloadFromRemote:(NSURL*)pkgDownloadURL completion:(void (^)(NSURL *pkgLocalURL, NSError *error))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block NSError *error;
        NSData *urlData = [NSData dataWithContentsOfURL:pkgDownloadURL options:0 error:&error];
        if (error) {
            completion(nil, error);
            return;
        }
        NSURL *filePath = [[MTBMailBundle bundleApplicationSupportDirectory] URLByAppendingPathComponent:@"Update.pkg"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [urlData writeToURL:filePath options:0 error:&error];
            if (error) {
                completion(nil, error);
                return;
            }
            if (![MTBPackageValidator isPkgSignatureValidAtURL:filePath]) {
                error = [NSError errorWithDomain:@"MTBPKGSignatureInvalid" code:201000 userInfo:@{@"NSLocalizedDescription": @"Invalid Signature"}];
                completion(nil, error);
                return;
            }
            completion(filePath, nil);
        });
    });
}
@end
