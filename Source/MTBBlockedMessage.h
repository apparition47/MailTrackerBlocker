//
//  MTBBlockedMessage.h
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2020/07/12.
//

#import <Foundation/Foundation.h>

@protocol MTBBlockedMessageDelegate <NSObject>
@optional
- (void)didCompleteSantizationWith:(NSUInteger)count;
@end

@interface MTBBlockedMessage : NSObject
- (id)initWithHtml:(NSString*)html;
- (NSUInteger)blockedCount;
- (NSString*)sanitizedHtml;
- (id)description;
@end
