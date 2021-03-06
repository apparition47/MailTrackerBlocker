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

#define mailself ((HeaderViewController *)self)

@implementation HeaderViewController_MailTrackerBlocker

NSString * const kBlockingBtn = @"kBlockingBtn";

- (void)MTBDealloc {
    [mailself _unregisterKVOForRepresentedObject:self];
    [self MTBDealloc];
}

- (void)MTBViewDidLoad {
    [self MTBViewDidLoad];
    NSButton *blockingBtn = [[NSButton alloc] init];
    [blockingBtn setImage: [NSImage imageNamed:@"inactive"]];
    [blockingBtn setAction:@selector(didPressBlockingBtn)];
    [blockingBtn setTarget:self];
    [mailself setIvar:kBlockingBtn value:blockingBtn];
    
    [blockingBtn setImagePosition: NSImageOnly];
    [blockingBtn setEnabled:NO];
    blockingBtn.bordered = NO;

    [[mailself view] addSubview:blockingBtn];
    
    blockingBtn.translatesAutoresizingMaskIntoConstraints = NO;
    if (@available(macOS 11.0, *)) {
        [blockingBtn.topAnchor constraintEqualToAnchor:mailself.detailsLink.bottomAnchor].active = YES;
        [blockingBtn.trailingAnchor constraintEqualToAnchor:mailself.detailsLink.leadingAnchor].active = YES;
    } else {
        [blockingBtn.topAnchor constraintEqualToAnchor:mailself.detailsLink.bottomAnchor constant:8].active = YES;
        [blockingBtn.trailingAnchor constraintEqualToAnchor:mailself.detailsLink.trailingAnchor].active = YES;
    }

    [mailself _registerKVOForRepresentedObject:self];

}

#pragma mark - Buttons

-(void) setButton:(NSButton *)button fontColor:(NSColor *)color {
    NSMutableAttributedString *colorTitle = [[NSMutableAttributedString alloc] initWithAttributedString:[button attributedTitle]];
    NSRange range = NSMakeRange(0, button.attributedTitle.length);
    [colorTitle addAttribute:NSForegroundColorAttributeName value:color range:range];
    [colorTitle fixAttributesInRange:range];
    [button setAttributedTitle:colorTitle];
}

- (void)didPressBlockingBtn {
    MTBBlockedMessage *blkMsg = [[mailself representedObject]  getIvar:@"MTBBlockedMessage"];
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText: @"MailTrackerBlocker"];
    if ([blkMsg certainty] == BLOCKING_RESULT_CERTAINTY_LOW_NO_MATCHES) {
        [alert setInformativeText: GMLocalizedString(@"BLOCKING_RESULT_CERTAINTY_LOW_NO_MATCHES")];
    } else if ([blkMsg certainty] == BLOCKING_RESULT_CERTAINTY_MODERATE_HEURISTIC) {
        [alert setInformativeText: GMLocalizedString(@"BLOCKING_RESULT_CERTAINTY_MODERATE_HEURISTIC")];
    } else {
        NSString *hardMatchText = [NSString stringWithFormat:GMLocalizedString(@"BLOCKING_RESULT_CERTAINTY_CONFIDENT_HARD_MATCH"), [blkMsg detectedTracker], [blkMsg detectedTracker]];
        [alert setInformativeText: hardMatchText];
    }
    [alert setAlertStyle: NSAlertStyleWarning];
    [alert beginSheetModalForWindow:[[mailself view] window] completionHandler:nil];
}

- (void)updateButtonState {
    MTBBlockedMessage *blkMsg = [[mailself representedObject]  getIvar:@"MTBBlockedMessage"];
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
