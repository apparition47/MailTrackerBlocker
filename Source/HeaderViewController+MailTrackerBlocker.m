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
    NSButton *blockingBtn = [NSButton buttonWithTitle:[NSString stringWithFormat: @"%d", 0] image:[NSImage imageNamed:@"inactive"] target:self action:@selector(didPressBlockingBtn)];
    
    [mailself setIvar:kBlockingBtn value:blockingBtn];
    
    [blockingBtn setImagePosition: NSImageLeft];
    [blockingBtn setEnabled:NO];
    blockingBtn.bordered = NO;

    [[mailself view] addSubview:blockingBtn];
    
    blockingBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [blockingBtn.topAnchor constraintEqualToAnchor:mailself.detailsLink.bottomAnchor constant:8].active = YES;
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
    [alert setMessageText: [NSString stringWithFormat: @"MailBlockerTracker blocked %ld tracker(s)", blkMsg.blockedCount]];
    [alert setInformativeText: blkMsg.description];
    [alert setAlertStyle: NSAlertStyleWarning];
    [alert beginSheetModalForWindow:[[mailself view] window] completionHandler:nil];
}

#pragma mark - representedObject KVO
- (void)MTBObserveValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    [self MTBObserveValueForKeyPath:keyPath ofObject:object change:change context:context];
    MTBBlockedMessage *blkMsg = [[mailself representedObject]  getIvar:@"MTBBlockedMessage"];
    NSButton *blockingBtn = [mailself getIvar:kBlockingBtn];
    [blockingBtn setTitle:[NSString stringWithFormat: @"%ld", [blkMsg blockedCount]]];
    if (blkMsg.blockedCount > 0) {
        [blockingBtn setEnabled: YES];
        [blockingBtn setImage: [NSImage imageNamed:@"active"]];
        [self setButton: blockingBtn fontColor: [NSColor systemBlueColor]];
    } else {
        [blockingBtn setEnabled: NO];
        [blockingBtn setImage: [NSImage imageNamed:@"inactive"]];
        [self setButton: blockingBtn fontColor: [NSColor systemGrayColor]];
    }
}
@end
#undef mailself
