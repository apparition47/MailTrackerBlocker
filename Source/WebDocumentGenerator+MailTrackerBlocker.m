//
//  WebDocumentGenerator+MailTrackerBlocker.m
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2020/07/04.
//

#import "WebDocumentGenerator+MailTrackerBlocker.h"
#import "MUIWebDocument.h"
#import "MCMessage.h"
#import "MTBMailBundle.h"
//#import "NSObject+LPDynamicIvars.h"
#import "NSString+MailTrackerBlocker.h"

@implementation WebDocumentGenerator_MailTrackerBlocker

- (void)MASetWebDocument:(MUIWebDocument *)webDocument {
    webDocument.html = [webDocument.html trackerSanitized];
    [self MASetWebDocument:webDocument];
}

@end
