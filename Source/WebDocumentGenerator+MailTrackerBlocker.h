//
//  WebDocumentGenerator+MailTrackerBlocker.h
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2020/07/06.
//

#import <Foundation/Foundation.h>
#import "WebDocumentGenerator.h"

@class MUIWebDocument;

@interface WebDocumentGenerator_MailTrackerBlocker : NSObject

- (void)MTBSetWebDocument:(MUIWebDocument *)webDocument;

@end
