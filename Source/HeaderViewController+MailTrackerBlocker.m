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

#define mailself ((HeaderViewController *)self)

@implementation HeaderViewController_MailTrackerBlocker

NSString * const kBlockingBtn = @"kBlockingBtn";

- (void)MTBDealloc {
    [mailself _unregisterKVOForRepresentedObject:self];
    [self MTBDealloc];
}

- (void)MTBViewDidLoad {
    [self MTBViewDidLoad];
    NSButton *blockingBtn = [NSButton buttonWithImage:[NSImage imageNamed:@"inactive"] target:self action:@selector(didPressBlockingBtn)];
    [mailself setIvar:kBlockingBtn value:blockingBtn];
    
    [blockingBtn setImagePosition: NSImageOnly];
    [blockingBtn setEnabled:NO];
    blockingBtn.bordered = NO;

    [[mailself view] addSubview:blockingBtn];
    
    blockingBtn.translatesAutoresizingMaskIntoConstraints = NO;
    if (@available(macOS 11.0, *)) {
          [blockingBtn.topAnchor constraintEqualToAnchor:mailself.detailsLink.bottomAnchor constant:0].active = YES;
    } else {
          [blockingBtn.topAnchor constraintEqualToAnchor:mailself.detailsLink.bottomAnchor constant:8].active = YES;
    }
    [blockingBtn.rightAnchor constraintEqualToAnchor:mailself.detailsLink.rightAnchor].active = YES;

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
    [alert addButtonWithTitle:@"Ok"];
    [alert setMessageText: @"MailBlockerTracker"];
    if ([blkMsg certainty] == BLOCKING_RESULT_CERTAINTY_LOW_NO_MATCHES) {
        [alert setInformativeText: @"MailTrackerBlocker did not detect any trackers in this email."];
    } else if ([blkMsg certainty] == BLOCKING_RESULT_CERTAINTY_MODERATE_HEURISTIC) {
        [alert setInformativeText: @"MailTrackerBlocker detected and preemptively blocked a possible tracker in this email."];
    } else {
        [alert setInformativeText: [NSString stringWithFormat:@"MailTrackerBlocker blocked a tracker from %@. This tool can track if you opened the email, when you opened it (and how often), where you are located, and how you opened it (phone, computer). Some or all of this data could have been reported back to its sender.", [blkMsg detectedTracker]]];
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
