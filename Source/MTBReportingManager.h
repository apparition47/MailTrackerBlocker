//
//  MTBReportingManager.h
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2021/05/01.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTBReportingManager : NSObject
+ (instancetype)sharedInstance;
-(void)markEmailRead:(NSString*)emailBody;
-(void)purgeReports30DaysOrOlder;
@end

NS_ASSUME_NONNULL_END
