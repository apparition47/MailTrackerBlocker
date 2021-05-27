//
//  MTBGitHubReleases.h
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2021/05/18.
//

#import <Foundation/Foundation.h>

/**
 Check GitHub Releases RSS for latest version
 */
@interface MTBGitHubReleases : NSObject
-(void)checkLatestWithCompletion:(void (^)(NSString *version, NSURL *pkgURL))completion;
@end
