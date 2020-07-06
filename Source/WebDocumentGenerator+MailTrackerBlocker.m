//
//  WebDocumentGenerator+MailTrackerBlocker.m
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2020/07/04.
//

#import "WebDocumentGenerator+MailTrackerBlocker.h"
#import "MUIWebDocument.h"
#import "MTBMailBundle.h"
#import "NSString+MailTrackerBlocker.h"

@implementation WebDocumentGenerator_MailTrackerBlocker

- (void)MTBSetWebDocument:(MUIWebDocument *)webDocument {
    webDocument.html = [webDocument.html trackerSanitized];
    [self MTBSetWebDocument:webDocument];
}

@end
