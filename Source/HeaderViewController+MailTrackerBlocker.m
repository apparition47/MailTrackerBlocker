//
//  HeaderViewController+MailTrackerBlocker.m
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2020/07/11.
//

#import "HeaderViewController+MailTrackerBlocker.h"
#import "HeaderViewController.h"
#import "ConversationMember.h"
#import "MUIWebDocument.h"
#import "NSObject+LPDynamicIvars.h"
#import "WebDocumentGenerator.h"
#import "MTBMailBundle.h"
#import "MTBReportPopover.h"
#import "MTBReportingManager.h"

#define mailself ((HeaderViewController *)self)

@implementation HeaderViewController_MailTrackerBlocker

NSString * const kBlockingBtn = @"kBlockingBtn";

#pragma mark - Lifecycle

- (void)MTBDealloc {
    [mailself _unregisterKVOForRepresentedObject:self];
    [self MTBDealloc];
}

- (void)MTBViewDidLoad {
    [self MTBViewDidLoad];
    [self setupButtonView];
    [mailself _registerKVOForRepresentedObject:self];
}

#pragma mark - Buttons

-(void)setupButtonView {
    NSButton *blockingBtn;
    if (@available(macOS 10.12, *)) {
        blockingBtn = [NSButton buttonWithImage:[NSImage imageNamed:@"inactive"] target:self action:@selector(didPressBlockingBtn:)];
    } else {
        blockingBtn = [[NSButton alloc] init];
        [blockingBtn setImage: [NSImage imageNamed:@"inactive"]];
        [blockingBtn setAction:@selector(didPressBlockingBtn:)];
        [blockingBtn setTarget:self];
    }
    
    [mailself setIvar:kBlockingBtn value:blockingBtn];
    
    [blockingBtn setImagePosition: NSImageOnly];
    [blockingBtn setEnabled:NO];
    blockingBtn.bordered = NO;

    [[mailself view] addSubview:blockingBtn];
    
    blockingBtn.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Big Sur: attachment icons were moved inbetween the dateView and detailsLink
    // which reduces space for our button
    if (@available(macOS 11.0, *)) {
        [blockingBtn.topAnchor constraintEqualToAnchor:mailself.detailsLink.bottomAnchor].active = YES;
        if (mailself.detailsLink.isHidden) {
            [blockingBtn.trailingAnchor constraintEqualToAnchor:mailself.dateView.trailingAnchor].active = YES;
        } else {
            [blockingBtn.topAnchor constraintEqualToAnchor:mailself.detailsLink.bottomAnchor constant:8].active = YES;
        }
    } else {
        [blockingBtn.topAnchor constraintEqualToAnchor:mailself.detailsLink.bottomAnchor constant:8].active = YES;
        [blockingBtn.trailingAnchor constraintEqualToAnchor:mailself.detailsLink.trailingAnchor].active = YES;
    }
}

-(void) setButton:(NSButton *)button fontColor:(NSColor *)color {
    NSMutableAttributedString *colorTitle = [[NSMutableAttributedString alloc] initWithAttributedString:[button attributedTitle]];
    NSRange range = NSMakeRange(0, button.attributedTitle.length);
    [colorTitle addAttribute:NSForegroundColorAttributeName value:color range:range];
    [colorTitle fixAttributesInRange:range];
    [button setAttributedTitle:colorTitle];
}

- (void)didPressBlockingBtn:(NSButton*)sender {
    MTBBlockedMessage *blkMsg = [[mailself representedObject]  getIvar:@"MTBBlockedMessage"];
    
    MTBReportPopover *reportPopover = [[MTBReportPopover alloc] initWithNibName:@"MTBReportPopover" bundle:[MTBMailBundle bundle]];
    reportPopover.blockedMessage = blkMsg;
    NSRect entryRect = [sender convertRect:sender.bounds
                                  toView:mailself.view];
    [mailself presentViewController:reportPopover asPopoverRelativeToRect:entryRect ofView:mailself.view preferredEdge:NSMaxYEdge behavior:NSPopoverBehaviorSemitransient];
}

- (void)updateButtonState {
    MTBBlockedMessage *blkMsg = [[mailself representedObject] getIvar:@"MTBBlockedMessage"];
    
    // report hit
    [[MTBReportingManager sharedInstance] markEmailRead:blkMsg];
    
    // update UI
    NSButton *blockingBtn = [mailself getIvar:kBlockingBtn];
    [blockingBtn setEnabled:YES];
    if ([blkMsg certainty] == BLOCKING_RESULT_CERTAINTY_LOW_NO_MATCHES) {
        [blockingBtn setImage: [NSImage imageNamed:@"inactive"]];
    } else if ([blkMsg certainty] == BLOCKING_RESULT_CERTAINTY_MODERATE_HEURISTIC) {
        [blockingBtn setImage: [NSImage imageNamed:@"possible"]];
    } else {
        [blockingBtn setImage: [NSImage imageNamed:@"active"]];
    }
}

#pragma mark - representedObject KVO

- (void)MTBObserveValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    [self MTBObserveValueForKeyPath:keyPath ofObject:object change:change context:context];
    [self updateButtonState];
}
@end
#undef mailself
