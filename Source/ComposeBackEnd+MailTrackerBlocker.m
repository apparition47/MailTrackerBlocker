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
#import "NSString+MailTrackerBlocker.h"
#import "MTBMailBundle.h"
#import "ComposeBackEnd+MailTrackerBlocker.h"

#import "ComposeViewController.h"
#import "HeadersEditor.h"
#import "MCActivityMonitor.h"

#import "MCKeychainManager.h"

#import "MCMessageBody.h"

@interface ComposeBackEnd_MailTrackerBlocker ()

@end

@implementation ComposeBackEnd_MailTrackerBlocker

// generated quoted text in reply/forwards
- (NSArray*)MTBGeneratedMessageBodies {
    NSArray *bodies = [self MTBGeneratedMessageBodies];
    for (MCMessageBody *body in bodies) {
        body.html = [body.html trackerSanitized];
    }
    return bodies;
}

@end
