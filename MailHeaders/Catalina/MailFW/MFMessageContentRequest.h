//
//     Generated by class-dump 3.5b1 (64 bit) (Debug version compiled Dec  3 2019 19:59:57).
//
//  Copyright (C) 1997-2019 Steve Nygard.
//

#import <objc/NSObject.h>

#import <MailFW/EFLoggable-Protocol.h>

@class EMContentRequestOptions, EMObjectID, MCMessage, MFMessageTransformer, NSString;
@protocol EFScheduler, EMContentItemRequestDelegate;

@interface MFMessageContentRequest : NSObject <EFLoggable>
{
    id <EFScheduler> _scheduler;	// 8 = 0x8
    EMObjectID *_objectID;	// 16 = 0x10
    MCMessage *_legacyMessage;	// 24 = 0x18
    MFMessageTransformer *_messageTransformer;	// 32 = 0x20
    NSString *_clientIdentifier;	// 40 = 0x28
    EMContentRequestOptions *_options;	// 48 = 0x30
    id <EMContentItemRequestDelegate> _delegate;	// 56 = 0x38
}

+ (id)onScheduler:(id)arg1 requestContentForObjectID:(id)arg2 legacyMessage:(id)arg3 messageTransformer:(id)arg4 clientIdentifier:(id)arg5 options:(id)arg6 delegate:(id)arg7 completionHandler:(id)arg8;	// IMP=0x0000000000177961
+ (id)log;	// IMP=0x0000000000177869
@property(retain, nonatomic) id <EMContentItemRequestDelegate> delegate; // @synthesize delegate=_delegate;
@property(retain, nonatomic) EMContentRequestOptions *options; // @synthesize options=_options;
@property(retain, nonatomic) NSString *clientIdentifier; // @synthesize clientIdentifier=_clientIdentifier;
@property(retain, nonatomic) MFMessageTransformer *messageTransformer; // @synthesize messageTransformer=_messageTransformer;
@property(retain, nonatomic) MCMessage *legacyMessage; // @synthesize legacyMessage=_legacyMessage;
@property(retain, nonatomic) EMObjectID *objectID; // @synthesize objectID=_objectID;
@property(retain, nonatomic) id <EFScheduler> scheduler; // @synthesize scheduler=_scheduler;
// - (void).cxx_destruct;	// IMP=0x0000000000178410
- (id)requestRawRepresentationWithCompletionHandler:(id)arg1;	// IMP=0x0000000000177c6e
- (id)beginRequestWithCompletionHandler:(id)arg1;	// IMP=0x0000000000177b16
- (id)_init;	// IMP=0x0000000000177932

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end

