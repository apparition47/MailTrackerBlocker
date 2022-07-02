//
//  MTBReportPopover.m
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2021/04/18.
//

#import "MTBMailBundle.h"
#import "MTBReportPopover.h"
#import "MTBReportViewController.h"
#import "MTBReportingManager.h"
#import "MTBSidebarMenu.h"
#import "MTBWindowController.h"
#import "MUIWebDocument.h"
#import "ConversationMember.h"

@interface MTBReportPopover () <NSPopoverDelegate>
#pragma mark - IBOutlet
@property (weak) IBOutlet NSTextField *trackerNameLabel;
@property (weak) IBOutlet NSTextField *trackerDescriptionLabel;
@property (weak) IBOutlet NSButton *blockingToggle;
@property (assign) BOOL isBlockingEnabled;
@end

@implementation MTBReportPopover

@synthesize blockingToggle, blockedMessage, documentGenerator, isBlockingEnabled;

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

#pragma mark - IBAction

-(IBAction)disableBlockingPressed:(NSButton*)sender {
    blockedMessage.isBlockingEnabled = !blockedMessage.isBlockingEnabled;
    [self setupView];
    
    MUIWebDocument *webDocument = [documentGenerator.conversationMember webDocument];
    if (blockedMessage.isBlockingEnabled) {
        [documentGenerator setWebDocument:webDocument];
    } else {
        [(WebDocumentGenerator_MailTrackerBlocker*)documentGenerator setOriginalWebDoc:webDocument];
    }
}
-(IBAction)sidebarPressed:(NSButton*)sender {
    NSPopover * targetPopover = [[NSPopover alloc] init];
    targetPopover.delegate = self;
    
    MTBSidebarMenu *sidebarPopover = [[MTBSidebarMenu alloc] initWithNibName:@"MTBSidebarMenu" bundle:[MTBMailBundle bundle]];

    targetPopover.contentViewController = sidebarPopover;
    [targetPopover setBehavior:NSPopoverBehaviorTransient];
    [targetPopover setAnimates:YES];

    NSRect entryRect = [sender convertRect:sender.bounds
                                  toView:self.view];

    [targetPopover showRelativeToRect: entryRect
                            ofView: self.view
                     preferredEdge: NSMaxYEdge];
}

-(IBAction)reportPressed:(NSButton*)sender {
    for (NSWindow *window in [[NSApplication sharedApplication] windows]) {
        if ([window.contentViewController isKindOfClass:[MTBReportViewController class]]) {
            [window makeKeyAndOrderFront:self];
            [self dismissViewController:self];
            return;
        }
    }
    
    NSViewController *vc = [[MTBReportViewController alloc] initWithNibName:@"MTBReportViewController" bundle:[MTBMailBundle bundle]];
    
    NSWindow *window = [[NSWindow alloc] init];
    NSUInteger masks = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskTexturedBackground | NSWindowStyleMaskMiniaturizable;
    [window setStyleMask:masks];
    [window setContentViewController:vc];
    [window setTitle:MTBLocalizedString(@"TRACKER_REPORT")];
    
    MTBWindowController *wc = [[MTBWindowController alloc] initWithWindow:window];
    CGFloat xPos = NSWidth([[window screen] frame])/2 - NSWidth([window frame])/2;
    CGFloat yPos = NSHeight([[window screen] frame])/2 - NSHeight([window frame])/2;
    [window setFrame:NSMakeRect(xPos, yPos, NSWidth([window frame]), NSHeight([window frame])) display:YES];
    [wc showWindow:nil];
    
    [self dismissViewController:self];
}

#pragma mark - NSPopoverDelegate

// dismiss self when MTBSidebarMenu popover is also closed
- (void)popoverWillClose:(NSNotification *)notification {
    [self dismissViewController:self];
}

#pragma mark - Private

-(void)setupView {
    if (!blockedMessage.isBlockingEnabled) {
        [blockingToggle setImage: [[MTBMailBundle bundle] imageForResource:@"toggle-off"]];
        [blockingToggle setEnabled:YES];
        _trackerNameLabel.stringValue = @"-";
        _trackerDescriptionLabel.stringValue = MTBLocalizedString(@"BLOCKING_DISABLED");
    } else if ([blockedMessage certainty] == BLOCKING_RESULT_CERTAINTY_LOW_NO_MATCHES) {
        [blockingToggle setImage: [[MTBMailBundle bundle] imageForResource:@"toggle-on"]];
        [blockingToggle setEnabled:NO];
        _trackerNameLabel.stringValue = @"-";
        _trackerDescriptionLabel.stringValue = MTBLocalizedString(@"BLOCKING_RESULT_CERTAINTY_LOW_NO_MATCHES");
    } else if ([blockedMessage certainty] == BLOCKING_RESULT_CERTAINTY_MODERATE_HEURISTIC) {
        [blockingToggle setImage: [[MTBMailBundle bundle] imageForResource:@"toggle-on"]];
        [blockingToggle setEnabled:YES];
        _trackerNameLabel.stringValue = @"-";
        _trackerDescriptionLabel.stringValue = MTBLocalizedString(@"BLOCKING_RESULT_CERTAINTY_MODERATE_HEURISTIC");
    } else {
        [blockingToggle setImage: [[MTBMailBundle bundle] imageForResource:@"toggle-on"]];
        [blockingToggle setEnabled:YES];
        _trackerNameLabel.stringValue = [blockedMessage.detectedTrackers.allObjects componentsJoinedByString:@", "];
        if ([blockedMessage knownTrackerCount] == 1) {
            _trackerDescriptionLabel.stringValue = [NSString stringWithFormat:MTBLocalizedString(@"BLOCKING_RESULT_CERTAINTY_CONFIDENT_HARD_MATCH"), blockedMessage.detectedTracker];
        } else {
            _trackerDescriptionLabel.stringValue = [NSString stringWithFormat:MTBLocalizedString(@"BLOCKING_RESULT_CERTAINTY_CONFIDENT_HARD_MATCHES"), blockedMessage.knownTrackerCount];
        }
    }
}
@end
