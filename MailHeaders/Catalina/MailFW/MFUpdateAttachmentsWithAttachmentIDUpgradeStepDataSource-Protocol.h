//
//     Generated by class-dump 3.5b1 (64 bit) (Debug version compiled Dec  3 2019 19:59:57).
//
//  Copyright (C) 1997-2019 Steve Nygard.
//

@class MFUpdateAttachmentsWithAttachmentIDUpgradeStep, NSURL;
@protocol NSFastEnumeration;

@protocol MFUpdateAttachmentsWithAttachmentIDUpgradeStepDataSource
- (BOOL)updateAttachmentsWithAttachmentIDUpgradeStep:(MFUpdateAttachmentsWithAttachmentIDUpgradeStep *)arg1 isDirectoryForFileURL:(NSURL *)arg2;
- (void (^)(void))skipDescendantsBlockForUpdateAttachmentsWithAttachmentIDUpgradeStep:(MFUpdateAttachmentsWithAttachmentIDUpgradeStep *)arg1;
- (id <NSFastEnumeration>)fileURLEnumeratorForUpdateAttachmentsWithAttachmentIDUpgradeStep:(MFUpdateAttachmentsWithAttachmentIDUpgradeStep *)arg1;
@end

