//
//     Generated by class-dump 3.5b1 (64 bit) (Debug version compiled Dec  3 2019 19:59:57).
//
//  Copyright (C) 1997-2019 Steve Nygard.
//

#import <MailFW/MFLocalAccount.h>

@class NSURL;

@interface MFParentalControlAccount : MFLocalAccount
{
    NSURL *_accountDirectory;	// 8 = 0x8
}

+ (id)_mailboxNameForAccount:(id)arg1;	// IMP=0x00000000001bb55d
+ (id)storeForAccount:(id)arg1;	// IMP=0x00000000001bb4f5
+ (id)storeForMailbox:(id)arg1;	// IMP=0x00000000001bb472
+ (id)mailboxForAccount:(id)arg1;	// IMP=0x00000000001bb36d
+ (id)allMailboxes;	// IMP=0x00000000001bb2fb
+ (id)originalAccountForIncomingMailbox:(id)arg1;	// IMP=0x00000000001bb0f6
+ (id)parentalControlAccount;	// IMP=0x00000000001badb7
+ (id)allocWithZone:(struct _NSZone *)arg1;	// IMP=0x00000000001bacfe
- (id)accountDirectory;	// IMP=0x00000000001bb69f
// - (void).cxx_destruct;	// IMP=0x00000000001bb6b0
- (id)mailboxPathExtension;	// IMP=0x00000000001bb680
- (Class)storeClassForMailbox:(id)arg1;	// IMP=0x00000000001bb667
- (void)setIsActive:(BOOL)arg1;	// IMP=0x00000000001bb0f0
- (BOOL)isActive;	// IMP=0x00000000001bb0e5
- (void)dealloc;	// IMP=0x00000000001bb015
- (id)initWithSystemAccount:(id)arg1;	// IMP=0x00000000001bae72

@end

