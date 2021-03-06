//
//     Generated by class-dump 3.5b1 (64 bit) (Debug version compiled Dec  3 2019 19:59:57).
//
//  Copyright (C) 1997-2019 Steve Nygard.
//

#import <AppKit/NSView.h>

#import "SlidingAnimationDelegate-Protocol.h"

@class ClippedItemsIndicator, NSMutableArray, NSString, SlidingAnimation;
@protocol NSCopying;

@interface SlidingViewsBar : NSView <SlidingAnimationDelegate>
{
    unsigned long long _dropIndex;	// 112 = 0x70
    unsigned long long _dragSourceIndex;	// 120 = 0x78
    ClippedItemsIndicator *_rightClipIndicator;	// 128 = 0x80
    NSMutableArray *_buttons;	// 136 = 0x88
    SlidingAnimation *_animation;	// 144 = 0x90
    double _draggedItemWidth;	// 152 = 0x98
}

+ (double)buttonBottomOffset;	// IMP=0x0000000100280554
@property(nonatomic) double draggedItemWidth; // @synthesize draggedItemWidth=_draggedItemWidth;
@property(retain, nonatomic) SlidingAnimation *animation; // @synthesize animation=_animation;
@property(retain, nonatomic) NSMutableArray *buttons; // @synthesize buttons=_buttons;
@property(readonly, nonatomic) ClippedItemsIndicator *rightClipIndicator; // @synthesize rightClipIndicator=_rightClipIndicator;
@property(nonatomic) unsigned long long dragSourceIndex; // @synthesize dragSourceIndex=_dragSourceIndex;
// - (void).cxx_destruct;	// IMP=0x0000000100282068
- (void)_ensureButtonIsInViewHierarchy:(id)arg1;	// IMP=0x0000000100281f3e
- (void)_mainStatusDidChange:(id)arg1;	// IMP=0x0000000100030c92
- (BOOL)isFlipped;	// IMP=0x000000010000bc07
- (void)viewWillBeginDragging:(id)arg1;	// IMP=0x0000000100281e65
@property(readonly, nonatomic) NSView<NSCopying> *viewPinnedToOverflowIndicator;
- (void)moveSlidingViewToCurrentDropIndex:(id)arg1;	// IMP=0x0000000100281d9d
@property(readonly, nonatomic) BOOL isSliding;
- (void)draggingEnded:(id)arg1;	// IMP=0x0000000100281d6e
- (void)draggingEnded;	// IMP=0x0000000100281d47
- (unsigned long long)draggingUpdated:(id)arg1;	// IMP=0x0000000100281d35
- (void)draggingExited:(id)arg1;	// IMP=0x0000000100281d19
- (unsigned long long)draggingEntered:(id)arg1;	// IMP=0x0000000100281c3f
- (unsigned long long)updateDropTarget:(id)arg1;	// IMP=0x0000000100281c37
- (double)slidingWidthForView:(id)arg1;	// IMP=0x0000000100281bf4
- (double)widthOfDraggingInfo:(id)arg1;	// IMP=0x0000000100281beb
- (void)resumeAnimation;	// IMP=0x0000000100281bce
- (void)pauseAnimation;	// IMP=0x0000000100281bb1
- (BOOL)reorderSlidingView:(id)arg1 fromMouseDownEvent:(id)arg2;	// IMP=0x0000000100281571
- (id)_lastDraggedOrUpEventFollowing:(id)arg1;	// IMP=0x0000000100281448
- (id)_lastDraggedEventFollowing:(id)arg1;	// IMP=0x000000010028134c
@property(nonatomic) unsigned long long dropIndex;
- (void)slideButtonsIntoPlace;	// IMP=0x000000010028092a
- (unsigned long long)dropIndexFromLocalPoint:(struct CGPoint)arg1;	// IMP=0x00000001002805af
- (unsigned long long)dropIndexFromDraggingInfo:(id)arg1;	// IMP=0x000000010028056f
- (void)refreshButtons;	// IMP=0x0000000100280569
- (void)draggedSlidingView:(id)arg1;	// IMP=0x0000000100280563
- (void)reorderedSlidingView:(id)arg1;	// IMP=0x000000010028055d
@property(readonly, nonatomic) double paddingBetweenButtons;
- (struct CGRect)_constrainProposedButtonFrame:(struct CGRect)arg1;	// IMP=0x0000000100280450
@property(readonly, nonatomic) double minSlidingViewX;
@property(readonly, nonatomic) double minButtonX;
@property(readonly, nonatomic) double maxButtonX;
@property(readonly, nonatomic) double maxButtonXWithClipIndicator;
@property(readonly, nonatomic) double maxButtonXWithoutClipIndicator;
@property(readonly, nonatomic) unsigned long long lastNonSlidingViewIndex;
- (void)dealloc;	// IMP=0x000000010028030a
- (void)_slidingViewsBarCommonInit;	// IMP=0x000000010000b784
- (id)initWithCoder:(id)arg1;	// IMP=0x00000001002802c3
- (id)initWithFrame:(struct CGRect)arg1;	// IMP=0x000000010000b725

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end

