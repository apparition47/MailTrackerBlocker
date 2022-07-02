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
@property(readonly, nonatomic) NSString *subjectField;
@property(readonly, nonatomic) NSString *fromField;
@property(readonly, nonatomic) NSString *deeplinkField;
@property(readonly, nonatomic) NSString *originalHtml;
@property (assign) BOOL isBlockingEnabled;
@property (nonatomic, assign, readonly) NSUInteger knownTrackerCount;
- (instancetype)init NS_UNAVAILABLE;
- (id)initWithHtml:(NSString*)html;
- (id)initWithHtml:(NSString*)html from:(NSString*)from subject:(NSString*)subject deeplink:(NSString*)deeplink;
- (NSString *)detectedTracker;
- (NSSet *)detectedTrackers;
- (enum BLOCKING_RESULT_CERTAINTY)certainty;
- (NSString*)sanitizedHtml;
@end
