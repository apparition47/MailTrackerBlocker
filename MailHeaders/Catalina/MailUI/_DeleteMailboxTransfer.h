//
//     Generated by class-dump 3.5b1 (64 bit) (Debug version compiled Dec  3 2019 19:59:57).
//
//  Copyright (C) 1997-2019 Steve Nygard.
//

#import <objc/NSObject.h>

#import "MessageDeletionTransfer-Protocol.h"

@class MCMonitoredInvocation, NSString;

@interface _DeleteMailboxTransfer : NSObject <MessageDeletionTransfer>
{
    MCMonitoredInvocation *_invocation;	// 8 = 0x8
}

@property(retain, nonatomic) MCMonitoredInvocation *invocation; // @synthesize invocation=_invocation;
// - (void).cxx_destruct;	// IMP=0x0000000100203eb2
- (void)beginTransfer;	// IMP=0x0000000100203e4e
@property(readonly, nonatomic) BOOL canBeginTransfer;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end

