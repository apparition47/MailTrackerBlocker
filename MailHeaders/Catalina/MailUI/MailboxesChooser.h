//
//     Generated by class-dump 3.5b1 (64 bit) (Debug version compiled Dec  3 2019 19:59:57).
//
//  Copyright (C) 1997-2019 Steve Nygard.
//

#import <objc/NSObject.h>

#import "NSMenuDelegate-Protocol.h"

@class NSArray, NSMenu, NSMutableSet, NSPopUpButton, NSString;

@interface MailboxesChooser : NSObject <NSMenuDelegate>
{
    NSMenu *_rootMenu;	// 8 = 0x8
    NSPopUpButton *_popUpButton;	// 16 = 0x10
    id _selectedItem;	// 24 = 0x18
    NSMutableSet *_updatedMenus;	// 32 = 0x20
    BOOL _useSelection;	// 40 = 0x28
    id _includeMailboxCondition;	// 48 = 0x30
    id _enableMailboxCondition;	// 56 = 0x38
    id _target;	// 64 = 0x40
    SEL _action;	// 72 = 0x48
    NSArray *_additionalItems;	// 80 = 0x50
}

+ (BOOL)automaticallyNotifiesObserversOfSelectedItem;	// IMP=0x00000001001ab60b
+ (BOOL)automaticallyNotifiesObserversOfPopUpButton;	// IMP=0x00000001001ab603
+ (BOOL)automaticallyNotifiesObserversOfRootMenu;	// IMP=0x00000001001ab5fb
@property(readonly, nonatomic) BOOL useSelection; // @synthesize useSelection=_useSelection;
@property(retain, nonatomic) NSArray *additionalItems; // @synthesize additionalItems=_additionalItems;
@property(nonatomic) SEL action; // @synthesize action=_action;
@property(nonatomic) __weak id target; // @synthesize target=_target;
@property(copy, nonatomic) id enableMailboxCondition; // @synthesize enableMailboxCondition=_enableMailboxCondition;
@property(copy, nonatomic) id includeMailboxCondition; // @synthesize includeMailboxCondition=_includeMailboxCondition;
// - (void).cxx_destruct;	// IMP=0x00000001001ab900
- (void)menuDidClose:(id)arg1;	// IMP=0x00000001001ab799
- (void)_popUpAction:(id)arg1;	// IMP=0x00000001001ab613
- (void)refresh;	// IMP=0x0000000100080d53
- (void)menuNeedsUpdate:(id)arg1;	// IMP=0x0000000100080f65
- (void)_outlineViewStateDidChange:(id)arg1;	// IMP=0x00000001000285ff
- (void)_invalidateUpdatedMenus:(id)arg1;	// IMP=0x000000010000959e
- (void)invalidateUpdatedMenus;	// IMP=0x00000001000095f3
- (void)_addMenuItemsForItems:(id)arg1 toMenu:(id)arg2 withIndentationLevel:(long long)arg3 initialSeparatorItem:(BOOL)arg4;	// IMP=0x0000000100081b56
- (id)_menuItemForItem:(id)arg1 indentationLevel:(long long)arg2;	// IMP=0x00000001000823b7
@property(retain, nonatomic) id selectedItem;
@property(nonatomic) __weak NSPopUpButton *popUpButton;
@property(nonatomic) __weak NSMenu *rootMenu;
- (void)_setupPopUpButton;	// IMP=0x0000000100005a6b
- (void)dealloc;	// IMP=0x00000001001ab4c0
- (void)awakeFromNib;	// IMP=0x00000001000059ed
- (id)init;	// IMP=0x0000000100005663
- (id)initWithSelection:(BOOL)arg1;	// IMP=0x00000001001ab205

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end
