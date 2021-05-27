//
//  WebDocumentGenerator+MailTrackerBlocker.m
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2020/07/04.
//

#import "WebDocumentGenerator+MailTrackerBlocker.h"
#import "MUIWebDocument.h"
#import "MTBMailBundle.h"
#import "MTBBlockedMessage.h"
#import "NSObject+LPDynamicIvars.h"
#import "ConversationMember.h"
#import "MCMessage.h"
#import "MCMessageHeaders.h"

#define mailself ((WebDocumentGenerator *)self)
@implementation WebDocumentGenerator_MailTrackerBlocker

- (void)MTBSetWebDocument:(MUIWebDocument *)webDocument {
    ConversationMember *member = [mailself conversationMember];
    MTBBlockedMessage *blkMsg = [[MTBBlockedMessage alloc] initWithHtml:webDocument.html from:member.sender subject:member.subject deeplink:member.originalMessage.URLString];
    [[mailself conversationMember] setIvar: @"MTBBlockedMessage" value: blkMsg];
    webDocument.html = [blkMsg sanitizedHtml];
    [self MTBSetWebDocument:webDocument];
}

@end
#undef mailself
