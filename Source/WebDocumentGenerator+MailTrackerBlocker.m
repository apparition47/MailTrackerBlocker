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

#define mailself ((WebDocumentGenerator *)self)
@implementation WebDocumentGenerator_MailTrackerBlocker

- (void)MTBSetWebDocument:(MUIWebDocument *)webDocument {
    MTBBlockedMessage *blkMsg = [[MTBBlockedMessage alloc] initWithHtml:webDocument.html];
    [[mailself conversationMember] setIvar: @"MTBBlockedMessage" value: blkMsg];
    webDocument.html = [blkMsg sanitizedHtml];
    [self MTBSetWebDocument:webDocument];
}

@end
#undef mailself
