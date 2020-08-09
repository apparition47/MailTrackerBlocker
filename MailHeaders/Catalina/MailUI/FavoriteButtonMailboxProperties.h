//
//     Generated by class-dump 3.5b1 (64 bit) (Debug version compiled Dec  3 2019 19:59:57).
//
//  Copyright (C) 1997-2019 Steve Nygard.
//

#import <objc/NSObject.h>

@class NSString;

@interface FavoriteButtonMailboxProperties : NSObject
{
    BOOL _isContainer;	// 8 = 0x8
    BOOL _isPreferredSelection;	// 9 = 0x9
    int _type;	// 12 = 0xc
    NSString *_persistentID;	// 16 = 0x10
    NSString *_selectedSubMailboxPersistentID;	// 24 = 0x18
    NSString *_displayName;	// 32 = 0x20
    NSString *_accountURLString;	// 40 = 0x28
}

@property(nonatomic) BOOL isPreferredSelection; // @synthesize isPreferredSelection=_isPreferredSelection;
@property(nonatomic) BOOL isContainer; // @synthesize isContainer=_isContainer;
@property(nonatomic) int type; // @synthesize type=_type;
@property(retain, nonatomic) NSString *accountURLString; // @synthesize accountURLString=_accountURLString;
@property(retain, nonatomic) NSString *displayName; // @synthesize displayName=_displayName;
@property(retain, nonatomic) NSString *selectedSubMailboxPersistentID; // @synthesize selectedSubMailboxPersistentID=_selectedSubMailboxPersistentID;
@property(retain, nonatomic) NSString *persistentID; // @synthesize persistentID=_persistentID;
// - (void).cxx_destruct;	// IMP=0x0000000100155e6a
- (id)dictionaryRepresentation;	// IMP=0x000000010007cf78
- (id)init;	// IMP=0x0000000100155d36
- (id)initWithDictionaryRepresentation:(id)arg1;	// IMP=0x000000010000f310
- (id)initWithPersistentID:(id)arg1 selectedSubMailboxPersistentID:(id)arg2 displayName:(id)arg3 accountURLString:(id)arg4 type:(int)arg5 isContainer:(BOOL)arg6 isPreferredSelection:(BOOL)arg7;	// IMP=0x0000000100155c3e

@end
