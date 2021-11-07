//
//     Generated by class-dump 3.5b1 (64 bit) (Debug version compiled Dec  3 2019 19:59:57).
//
//  Copyright (C) 1997-2019 Steve Nygard.
//

#import <IMAP/IMAPNetworkTaskOperation.h>

#import <IMAP/IMAPFetchResponseHandler-Protocol.h>

@class NSIndexSet, NSMutableArray, NSMutableIndexSet, NSString;
@protocol IMAPSyncUIDsFlagsAndLabelsOperationDelegate;

@interface IMAPSyncUIDsFlagsAndLabelsOperation : IMAPNetworkTaskOperation <IMAPFetchResponseHandler>
{
    NSMutableArray *_fetchResponses;	// 8 = 0x8
    NSMutableIndexSet *_vanishedUIDs;	// 16 = 0x10
    BOOL _includeLabels;	// 24 = 0x18
    unsigned int _highestKnownUID;	// 28 = 0x1c
    NSIndexSet *_messageNumbers;	// 32 = 0x20
    unsigned long long _changedSince;	// 40 = 0x28
    id <IMAPSyncUIDsFlagsAndLabelsOperationDelegate> _delegate;	// 48 = 0x30
}

@property(readonly, nonatomic) unsigned int highestKnownUID; // @synthesize highestKnownUID=_highestKnownUID;
@property(readonly, nonatomic) __weak id <IMAPSyncUIDsFlagsAndLabelsOperationDelegate> delegate; // @synthesize delegate=_delegate;
@property(readonly, nonatomic) BOOL includeLabels; // @synthesize includeLabels=_includeLabels;
@property(readonly, nonatomic) unsigned long long changedSince; // @synthesize changedSince=_changedSince;
@property(readonly, copy, nonatomic) NSIndexSet *messageNumbers; // @synthesize messageNumbers=_messageNumbers;
- (void).cxx_destruct;	// IMP=0x000000000005909c
- (BOOL)handleResponse:(id)arg1 forCommand:(id)arg2;	// IMP=0x0000000000058b4b
- (void)main;	// IMP=0x0000000000058846
- (id)_syncUIDsFlagsAndLabelsOperationDescription:(id)arg1;	// IMP=0x00000000000586cc
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
- (id)initWithMailboxName:(id)arg1;	// IMP=0x0000000000058521
- (void)_imapSyncUIDsFlagsAndLabelsOperationCommonInitIncludeLabels:(BOOL)arg1 delegate:(id)arg2;	// IMP=0x0000000000058476
- (id)initWithChangedSince:(unsigned long long)arg1 highestKnownUID:(unsigned int)arg2 includeLabels:(BOOL)arg3 mailboxName:(id)arg4 delegate:(id)arg5;	// IMP=0x00000000000583bb
- (id)initWithMessageNumbers:(id)arg1 includeLabels:(BOOL)arg2 mailboxName:(id)arg3 delegate:(id)arg4;	// IMP=0x00000000000582e3

// Remaining properties
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end
