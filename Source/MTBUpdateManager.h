//
//  MTBUpdateManager.h
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2021/05/18.
//

#import <Foundation/Foundation.h>


@interface MTBUpdateManager : NSObject

-(void)scheduleCheck;
-(void)requestAutoUpdatePermissionWith:(void (^)(BOOL granted))completion;
-(void)checkBundleUpdateAvailableWith:(void (^)(NSURL *latestDownloadURL))completion;
-(void)downloadFromRemote:(NSURL*)pkgDownloadURL completion:(void (^)(NSURL *pkgLocalURL, NSError *error))completion;

@end
