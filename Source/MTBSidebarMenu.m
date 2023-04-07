//
//  MTBSidebarMenu.m
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2021/05/21.
//

#import "MTBSidebarMenu.h"
#import "MTBMailBundle.h"
#import "MTBPreferences.h"
#import "MTBReportViewController.h"
#import "MTBUpdateManager.h"
#import "MTBUpdateCheckViewController.h"
#import "MTBLicensesViewController.h"
#import "MTBWindowController.h"

@interface MTBSidebarMenu ()
#pragma mark - IBOutlet
@property (strong) IBOutlet NSButton *trackerReportButton;
@property (strong) IBOutlet NSButton *checkForUpdatesButton;
@property (strong) IBOutlet NSButton *websiteButton;
@property (strong) IBOutlet NSButton *licensesButton;
@property (strong) IBOutlet NSButton *helpButton;
@property (strong) IBOutlet NSButton *aboutButton;
@end

@implementation MTBSidebarMenu

@synthesize trackerReportButton;
@synthesize checkForUpdatesButton;
@synthesize websiteButton;
@synthesize licensesButton;
@synthesize helpButton;
@synthesize aboutButton;

#pragma mark - NSViewController lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

#pragma mark - IBAction

-(IBAction)trackerReportPressed:(id)sender {
    for (NSWindow *window in [[NSApplication sharedApplication] windows]) {
        if ([window.contentViewController isKindOfClass:[MTBReportViewController class]]) {
            [window makeKeyAndOrderFront:self];
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
}

-(IBAction)checkForUpdatesPressed:(id)sender {
    for (NSWindow *window in [[NSApplication sharedApplication] windows]) {
        if ([window.contentViewController isKindOfClass:[MTBUpdateCheckViewController class]]) {
            [window makeKeyAndOrderFront:self];
            return;
        }
    }
    
    MTBUpdateManager *updater = [[MTBUpdateManager alloc] init];
    NSViewController *vc = [[MTBUpdateCheckViewController alloc] initWithNibWithUpdateURL:nil updater:updater];

    NSWindow *window = [[NSWindow alloc] init];
    NSUInteger masks = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskTexturedBackground;
    [window setStyleMask:masks];
    [window setContentViewController:vc];
    [window setTitle:MTBLocalizedString(@"UPDATE_MTB")];
    
    MTBWindowController *wc = [[MTBWindowController alloc] initWithWindow:window];
    CGFloat xPos = NSWidth([[window screen] frame])/2 - NSWidth([window frame])/2;
    CGFloat yPos = NSHeight([[window screen] frame])/2 - NSHeight([window frame])/2;
    [window setFrame:NSMakeRect(xPos, yPos, NSWidth([window frame]), NSHeight([window frame])) display:YES];
    [wc showWindow:nil];
}

-(IBAction)autoUpdateCheckPressed:(NSButton*)sender {
    NSNumber *isChecked = sender.state == NSOnState ? @YES : @NO;
    [MTBPreferences save:kMTBIsAutoUpdateCheckAllowedKey value:isChecked];
}

-(IBAction)websitePressed:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: @"https://apparition47.github.io/MailTrackerBlocker/"]];
}

-(IBAction)licensesPressed:(id)sender {
    for (NSWindow *window in [[NSApplication sharedApplication] windows]) {
        if ([window.contentViewController isKindOfClass:[MTBLicensesViewController class]]) {
            [window makeKeyAndOrderFront:self];
            return;
        }
    }
    
    NSViewController *vc = [[MTBLicensesViewController alloc] initWithNibName:@"MTBLicensesViewController" bundle:[MTBMailBundle bundle]];

    NSWindow *window = [[NSWindow alloc] init];
    NSUInteger masks = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskTexturedBackground | NSWindowStyleMaskMiniaturizable;
    [window setStyleMask:masks];
    [window setContentViewController:vc];
    [window setTitle:MTBLocalizedString(@"Licenses")];
    
    MTBWindowController *wc = [[MTBWindowController alloc] initWithWindow:window];
    CGFloat xPos = NSWidth([[window screen] frame])/2 - NSWidth([window frame])/2;
    CGFloat yPos = NSHeight([[window screen] frame])/2 - NSHeight([window frame])/2;
    [window setFrame:NSMakeRect(xPos, yPos, NSWidth([window frame]), NSHeight([window frame])) display:YES];
    [wc showWindow:nil];
}

-(IBAction)helpPressed:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/apparition47/MailTrackerBlocker/issues"]];
}

#pragma mark - Private

-(void)setupView {
    [trackerReportButton setTitle:MTBLocalizedString(@"TRACKER_REPORT")];
    [checkForUpdatesButton setTitle:MTBLocalizedString(@"UPDATE_CHECK")];
    [websiteButton setTitle:MTBLocalizedString(@"WEBSITE")];
    [licensesButton setTitle:MTBLocalizedString(@"LICENSES")];
    [helpButton setTitle:MTBLocalizedString(@"HELP")];
    [aboutButton setTitle:[NSString stringWithFormat:MTBLocalizedString(@"VERSION"), [MTBMailBundle bundleVersion]]];
}

@end
