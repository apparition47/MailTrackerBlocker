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
    NSButton *blockingBtn = [[NSButton alloc] init];
    [mailself setIvar:kBlockingBtn value:blockingBtn];
    
    [blockingBtn setTitle: [NSString stringWithFormat: @"🛑 %d", 0]];
    [blockingBtn setEnabled:NO];
    [blockingBtn setAction:@selector(didPressBlockingBtn)];
    [blockingBtn setTarget:self];
    blockingBtn.bezelStyle = mailself.detailsLink.bezelStyle;
    blockingBtn.bezelColor = mailself.detailsLink.bezelColor;

    [[mailself view] addSubview:blockingBtn];
    
    blockingBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [blockingBtn.topAnchor constraintEqualToAnchor:mailself.detailsLink.bottomAnchor].active = YES;
    [blockingBtn.rightAnchor constraintEqualToAnchor:mailself.detailsLink.rightAnchor].active = YES;

    [mailself _registerKVOForRepresentedObject:self];

}

#pragma mark - Buttons

- (void)didPressBlockingBtn {
    MTBBlockedMessage *blkMsg = [[mailself representedObject]  getIvar:@"MTBBlockedMessage"];
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Ok"];
    [alert setMessageText: [NSString stringWithFormat: @"MailBlockerTracker blocked %ld trackers", blkMsg.blockedCount]];
    [alert setInformativeText: blkMsg.description];
    [alert setAlertStyle: NSAlertStyleWarning];
    [alert beginSheetModalForWindow:[[mailself view] window] completionHandler:nil];
}

#pragma mark - representedObject KVO
- (void)MTBObserveValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    [self MTBObserveValueForKeyPath:keyPath ofObject:object change:change context:context];
    MTBBlockedMessage *blkMsg = [[mailself representedObject]  getIvar:@"MTBBlockedMessage"];
    NSButton *blockingBtn = [mailself getIvar:kBlockingBtn];
    [blockingBtn setEnabled: blkMsg.blockedCount > 0];
    [blockingBtn setTitle:[NSString stringWithFormat: @"🛑 %ld", [blkMsg blockedCount]]];
}
@end
#undef mailself
