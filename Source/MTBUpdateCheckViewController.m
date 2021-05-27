//
//  MTBUpdateCheckViewController.m
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2021/05/19.
//

#import "MTBUpdateCheckViewController.h"
#import "MTBMailBundle.h"
#import "MTBPreferences.h"

typedef enum VIEW_STATE: NSUInteger {
    V_S_CHECKING,
    V_S_READY_TO_INSTALL,
    V_S_NOT_NEEDED,
    V_S_ERROR
} VIEW_STATE;

@interface MTBUpdateCheckViewController ()
@property (weak) IBOutlet NSProgressIndicator *downloadProgress;
@property (weak) IBOutlet NSTextField *updateStatusLabel;
@property (weak) IBOutlet NSButton *autoUpdateCheckButton;
@property (weak) IBOutlet NSButton *installButton;
@property (weak) IBOutlet NSButton *closeButton;
@property (weak) IBOutlet NSButton *changelogButton;
@property (nonatomic,strong) NSURL *preloadedUpdateURL;
@property (nonatomic,strong) NSURL *downloadedUpdatePath;
@property (weak) MTBUpdateManager *updater;
@end

@implementation MTBUpdateCheckViewController

@synthesize preloadedUpdateURL, updater, updateStatusLabel, changelogButton, installButton, closeButton, downloadedUpdatePath, downloadProgress;

-(instancetype)initWithNibWithUpdateURL:(nullable NSURL*)updateURL updater:(MTBUpdateManager*)updatr {
    if (self = [self initWithNibName:@"MTBUpdateCheckViewController" bundle:[MTBMailBundle bundle]]) {
        self.updater = updatr;
        self.preloadedUpdateURL = updateURL;
    }
    return self;
}

#pragma mark - NSViewController lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self startCheck];
}

#pragma mark - IBAction

- (IBAction)changelogPressed:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/apparition47/MailTrackerBlocker/releases/latest"]];
    [[[self view] window] close];
}

- (IBAction)installPressed:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:downloadedUpdatePath];
    [[[self view] window] close];
}

- (IBAction)closePressed:(id)sender {
    [[[self view] window] close];
}

- (IBAction)autoUpdatePressed:(NSButton *)sender {
    NSNumber *isChecked = sender.state == NSOnState ? @YES : @NO;
    [MTBPreferences save:kMTBIsAutoUpdateCheckAllowedKey value:isChecked];
}

#pragma mark - Private

-(void)setupView {
    changelogButton.stringValue = MTBLocalizedString(@"RELEASE_NOTES");
    installButton.stringValue = MTBLocalizedString(@"UPDATE_INSTALL");
    closeButton.stringValue = MTBLocalizedString(@"UPDATE_CANCEL");
    [_autoUpdateCheckButton setState:[MTBPreferences valueForKey:kMTBIsAutoUpdateCheckAllowedKey] ? NSOnState : NSOffState];
}

-(void)startCheck {
    [self updateViewWithState:V_S_CHECKING error:nil];
    
    // if we know there's an update
    if (preloadedUpdateURL) {
        [self downloadUpdate];
    } else {
        __weak typeof(self) weakSelf = self;
        [updater checkBundleUpdateAvailableWith:^(NSURL *latestDownloadURL) {
            __strong typeof(self) strongSelf = weakSelf;
            
            strongSelf.preloadedUpdateURL = latestDownloadURL;
            if (!latestDownloadURL) {
                [strongSelf updateViewWithState:V_S_NOT_NEEDED error:nil];
                return;
            }
            
            [strongSelf downloadUpdate];
        }];
    }
}

-(void)downloadUpdate {
    __weak typeof(self) weakSelf = self;
    [updater downloadFromRemote:preloadedUpdateURL completion:^(NSURL *pkgLocalURL, NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        if (error) {
            [strongSelf updateViewWithState:V_S_ERROR error:error];
            return;
        }
        strongSelf.downloadedUpdatePath = pkgLocalURL;
        [strongSelf updateViewWithState:V_S_READY_TO_INSTALL error:nil];
    }];
}

-(void)updateViewWithState:(enum VIEW_STATE)state error:(nullable NSError*)error {
    switch (state) {
        case V_S_CHECKING:
            [downloadProgress startAnimation:nil];
            updateStatusLabel.stringValue = MTBLocalizedString(@"UPDATE_CHECKING");
            [installButton setEnabled:NO];
            break;
        case V_S_READY_TO_INSTALL:
            [downloadProgress stopAnimation:nil];
            updateStatusLabel.stringValue = MTBLocalizedString(@"UPDATE_READY");
            [installButton setEnabled:YES];
            break;
        case V_S_NOT_NEEDED:
            [downloadProgress stopAnimation:nil];
            updateStatusLabel.stringValue = [NSString stringWithFormat:MTBLocalizedString(@"UPDATE_NOT_NEEDED"), [MTBMailBundle bundleVersion]];
            [installButton setEnabled:NO];
            break;
        case V_S_ERROR:
            [downloadProgress stopAnimation:nil];
            updateStatusLabel.stringValue = [NSString stringWithFormat:@"An error has occured: %@", error.localizedDescription];
            [installButton setEnabled:NO];
            break;
    }
}
@end
