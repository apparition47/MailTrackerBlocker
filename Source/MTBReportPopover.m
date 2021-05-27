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

@interface MTBReportPopover () <NSPopoverDelegate>
#pragma mark - IBOutlet
@property (weak) IBOutlet NSTextField *trackerNameLabel;
@property (weak) IBOutlet NSTextField *trackerDescriptionLabel;
@end

@implementation MTBReportPopover

@synthesize blockedMessage;

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

#pragma mark - IBAction

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
                     preferredEdge: NSMaxXEdge];
}

-(IBAction)reportPressed:(NSButton*)sender {
    NSViewController *vc = [[MTBReportViewController alloc] initWithNibName:@"MTBReportViewController" bundle:[MTBMailBundle bundle]];
    
    NSWindow *window = [[NSWindow alloc] init];
    NSUInteger masks = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskTexturedBackground | NSWindowStyleMaskMiniaturizable;
    [window setStyleMask:masks];
    [window setContentViewController:vc];
    [window setTitle:MTBLocalizedString(@"TRACKER_REPORT")];
    
    NSWindowController *wc = [[NSWindowController alloc] initWithWindow:window];
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
    if ([blockedMessage certainty] == BLOCKING_RESULT_CERTAINTY_LOW_NO_MATCHES) {
        _trackerNameLabel.stringValue = @"-";
        _trackerDescriptionLabel.stringValue = MTBLocalizedString(@"BLOCKING_RESULT_CERTAINTY_LOW_NO_MATCHES");
    } else if ([blockedMessage certainty] == BLOCKING_RESULT_CERTAINTY_MODERATE_HEURISTIC) {
        _trackerNameLabel.stringValue = @"-";
        _trackerDescriptionLabel.stringValue = MTBLocalizedString(@"BLOCKING_RESULT_CERTAINTY_MODERATE_HEURISTIC");
    } else {
        _trackerNameLabel.stringValue = [blockedMessage detectedTracker];
        _trackerDescriptionLabel.stringValue = [NSString stringWithFormat:MTBLocalizedString(@"BLOCKING_RESULT_CERTAINTY_CONFIDENT_HARD_MATCH"), blockedMessage.detectedTracker];
    }
}
@end
