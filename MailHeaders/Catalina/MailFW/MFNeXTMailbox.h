//
//     Generated by class-dump 3.5b1 (64 bit) (Debug version compiled Dec  3 2019 19:59:57).
//
//  Copyright (C) 1997-2019 Steve Nygard.
//

#import <MailFW/MFMboxDocument.h>

@class NSURL;

@interface MFNeXTMailbox : MFMboxDocument
{
    NSURL *_tableOfContentsFile;	// 8 = 0x8
}

+ (BOOL)isValidItem:(id)arg1;	// IMP=0x00000000001b63eb
@property(readonly, nonatomic) NSURL *tableOfContentsFile; // @synthesize tableOfContentsFile=_tableOfContentsFile;
// - (void).cxx_destruct;	// IMP=0x00000000001b83af
- (id)_headerDigestForHeaders:(id)arg1 key:(id)arg2;	// IMP=0x00000000001b827e
- (BOOL)exportMessagesToURL:(id)arg1 error:(id *)arg2;	// IMP=0x00000000001b7279
- (id)messagesForImporter;	// IMP=0x00000000001b6527
- (id)initWithContentsOfURL:(id)arg1 error:(id *)arg2;	// IMP=0x00000000001b645a

@end

