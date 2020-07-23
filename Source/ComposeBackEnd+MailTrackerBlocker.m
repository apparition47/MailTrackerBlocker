//
//  ComposeBackEnd+MailTrackerBlocker.m
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2020/07/04.
//

#import <MCMimePart.h>
#import <MCMessageGenerator.h>
#import <MCMutableMessageHeaders.h>
#import <ComposeBackEnd.h>
#import "MFMailAccount.h"
#import "MCAttachment.h"
#import "CCLog.h"
#import "MTBMailBundle.h"
#import "ComposeBackEnd+MailTrackerBlocker.h"

#import "ComposeViewController.h"
#import "MTBBlockedMessage.h"

#import "MCMessageBody.h"

@interface ComposeBackEnd_MailTrackerBlocker ()

@end

@implementation ComposeBackEnd_MailTrackerBlocker

// generated quoted text in reply/forwards
- (NSArray*)MTBGeneratedMessageBodies {
    NSArray *bodies = [self MTBGeneratedMessageBodies];
    for (MCMessageBody *body in bodies) {
        MTBBlockedMessage *blkMsg = [[MTBBlockedMessage alloc] initWithHtml:body.html];
        body.html = blkMsg.sanitizedHtml;
    }
    return bodies;
}

@end
