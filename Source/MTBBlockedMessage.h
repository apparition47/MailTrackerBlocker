//
//  MTBBlockedMessage.h
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2020/07/12.
//

#import <Foundation/Foundation.h>

typedef enum BLOCKING_RESULT_CERTAINTY: NSUInteger {
    BLOCKING_RESULT_CERTAINTY_LOW_NO_MATCHES,
    BLOCKING_RESULT_CERTAINTY_MODERATE_HEURISTIC,
    BLOCKING_RESULT_CERTAINTY_CONFIDENT_HARD_MATCH
} BLOCKING_RESULT_CERTAINTY;

@protocol MTBBlockedMessageDelegate <NSObject>
@optional
- (void)didCompleteSantizationWith:(NSUInteger)count;
@end

@interface MTBBlockedMessage : NSObject
- (id)initWithHtml:(NSString*)html;
- (NSString *)detectedTracker;
- (enum BLOCKING_RESULT_CERTAINTY)certainty;
- (NSString*)sanitizedHtml;
@end
