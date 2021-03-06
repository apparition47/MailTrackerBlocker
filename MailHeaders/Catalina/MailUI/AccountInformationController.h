//
//     Generated by class-dump 3.5b1 (64 bit) (Debug version compiled Dec  3 2019 19:59:57).
//
//  Copyright (C) 1997-2019 Steve Nygard.
//

#import <AppKit/NSViewController.h>

@class ACAccount, NSImage, NSPopUpButton, NSString;

@interface AccountInformationController : NSViewController
{
    BOOL _accountNeedsSaving;	// 16 = 0x10
    BOOL _allowEventDonationConsent;	// 17 = 0x11
    NSImage *_accountStatusImage;	// 24 = 0x18
    NSString *_accountStatusDescription;	// 32 = 0x20
    NSPopUpButton *_emailAddressesPopUp;	// 40 = 0x28
    long long _lastSelectedEmailAddressIndex;	// 48 = 0x30
}

+ (id)keyPathsForValuesAffectingAccountIsEnabled;	// IMP=0x000000010009a43d
+ (id)keyPathsForValuesAffectingAccountDescription;	// IMP=0x000000010009a2fa
@property(nonatomic) BOOL allowEventDonationConsent; // @synthesize allowEventDonationConsent=_allowEventDonationConsent;
@property(nonatomic) long long lastSelectedEmailAddressIndex; // @synthesize lastSelectedEmailAddressIndex=_lastSelectedEmailAddressIndex;
@property(nonatomic) BOOL accountNeedsSaving; // @synthesize accountNeedsSaving=_accountNeedsSaving;
@property(nonatomic) __weak NSPopUpButton *emailAddressesPopUp; // @synthesize emailAddressesPopUp=_emailAddressesPopUp;
@property(copy, nonatomic) NSString *accountStatusDescription; // @synthesize accountStatusDescription=_accountStatusDescription;
@property(retain, nonatomic) NSImage *accountStatusImage; // @synthesize accountStatusImage=_accountStatusImage;
// - (void).cxx_destruct;	// IMP=0x000000010009d3ac
- (void)_didEditEmailAliases:(id)arg1;	// IMP=0x000000010009c709
- (void)_prepareToEditEmailAliases:(id)arg1;	// IMP=0x000000010009c16d
- (id)_aliasesBySettingDefaultAlias:(id)arg1 inAliases:(id)arg2;	// IMP=0x000000010009ba17
- (void)emailAddressesPopUpClicked:(id)arg1;	// IMP=0x000000010009b5ac
- (void)_emailAddressesPopUpWillPop:(id)arg1;	// IMP=0x000000010009b550
- (void)_updateEmailAddressesPopUp;	// IMP=0x000000010009adb7
- (void)_didUpdateAccountStatus:(id)arg1;	// IMP=0x000000010009aa6b
- (void)setUpUIForAccount:(id)arg1;	// IMP=0x000000010009a66f
@property(nonatomic) BOOL accountIsEnabled;
@property(readonly, nonatomic) BOOL canEnableAccount;
@property(copy) NSString *accountDescription;
- (void)observeValueForKeyPath:(id)arg1 ofObject:(id)arg2 change:(id)arg3 context:(void *)arg4;	// IMP=0x000000010009a26a
- (void)dismissViewController:(id)arg1;	// IMP=0x000000010009a0c9
- (void)prepareForSegue:(id)arg1 sender:(id)arg2;	// IMP=0x0000000100099ff5
@property(retain) ACAccount *representedObject;
- (void)viewDidDisappear;	// IMP=0x0000000100099daa
- (void)viewWillAppear;	// IMP=0x0000000100099cb7
- (void)viewDidLoad;	// IMP=0x0000000100099bc2
- (void)dealloc;	// IMP=0x0000000100099b13

@end

