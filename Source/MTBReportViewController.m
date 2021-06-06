//
//  MTBReportViewController.m
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2021/04/18.
//

#import "MTBMailBundle.h"
#import "MTBReportViewController.h"
#import <AppKit/AppKit.h>
#import "Reports+CoreDataModel.h"
#import "MTBReportViewModel.h"
#import "MTBReportingManager.h"

@interface MTBReportViewController ()
#pragma mark - IBOutlet
@property (weak) IBOutlet NSStackView *helpStackView;
@property (weak) IBOutlet NSButton *showMoreHelp;
@property (weak) IBOutlet NSView *trackersPreventedView;
@property (weak) IBOutlet NSTextField *trackersPreventedHeaderLabel;
@property (weak) IBOutlet NSTextField *trackersPreventedLabel;
@property (weak) IBOutlet NSView *emailRatioView;
@property (weak) IBOutlet NSTextField *emailRatioHeaderLabel;
@property (weak) IBOutlet NSTextField *emailRatioLabel;
@property (weak) IBOutlet NSView *mostFreqTrackerView;
@property (weak) IBOutlet NSTextField *mostFreqTrackerHeaderLabel;
@property (weak) IBOutlet NSTextField *mostFreqTrackerLabel;
@property (weak) IBOutlet NSTextField *taglineHeaderLabel;
@property (weak) IBOutlet NSButton *faqShowButton;
@property (weak) IBOutlet NSTextField *faqHeaderLabel;
@property (weak) IBOutlet NSTextField *faqDescLabel;
@property (weak) IBOutlet NSOutlineView *trackerOutlineView;

@property (nonatomic, strong) MTBReportViewModel *viewModel;
@end

@implementation MTBReportViewController

@synthesize trackersPreventedView, emailRatioView, mostFreqTrackerView, viewModel, title, preferredContentSize;

- (id)init {
    if (self = [super init]) {
        self.viewModel = [[MTBReportViewModel alloc] init];
    }
    
    return self;
}

-(instancetype)initWithNibName:(NSNibName)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.viewModel = [[MTBReportViewModel alloc] init];
    }
    
    return self;
}

#pragma mark - NSViewController lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self fetchData];
}

-(void)viewDidAppear {
    [super viewDidAppear];
    [self addObserver:self forKeyPath:@"view.effectiveAppearance" options:0 context:nil];
}

-(void)viewDidDisappear {
    [super viewDidDisappear];
    [self removeObserver:self forKeyPath:@"view.effectiveAppearance"];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context {
    if ([keyPath isEqualToString:@"view.effectiveAppearance"]) {
        [self themeDidChange];
    }
}
    
#pragma mark - Private

-(void)themeDidChange {
    [self setStatTileStyleFor:trackersPreventedView];
    [self setStatTileStyleFor:emailRatioView];
    [self setStatTileStyleFor:mostFreqTrackerView];
}

-(void)setupView {
    _taglineHeaderLabel.stringValue = MTBLocalizedString(@"TAGLINE");
    [_faqShowButton setTitle:!_helpStackView.isHidden ? MTBLocalizedString(@"SHOW_LESS_DETAIL") : MTBLocalizedString(@"SHOW_MORE_DETAIL")];
    _emailRatioHeaderLabel.stringValue = MTBLocalizedString(@"TRACKED_EMAILS_RATIO_STAT");
    _emailRatioLabel.stringValue = @"0";
    _trackersPreventedHeaderLabel.stringValue = MTBLocalizedString(@"TRACKERS_PREVENTED_STAT");
    _trackersPreventedLabel.stringValue = @"0%";
    _mostFreqTrackerHeaderLabel.stringValue = MTBLocalizedString(@"MOST_FREQUENT_TRACKER_STAT");
    _mostFreqTrackerLabel.stringValue = @"-";
    _faqHeaderLabel.stringValue = MTBLocalizedString(@"WHAT_ARE_TRACKERS");
    _faqDescLabel.stringValue = MTBLocalizedString(@"WHAT_ARE_TRACKERS_DESC");
    
    preferredContentSize = CGRectMake(0, 0, 656, 838).size; // prevent window resize

    [self showMoreHelpPressed:nil];
    [self themeDidChange];

    [_trackerOutlineView setDelegate:self];
    [_trackerOutlineView setDataSource:self];
}

-(void)fetchData {
    __weak MTBReportViewController *weakSelf = self;
    [viewModel getTrackersWithSuccess:^(NSArray<Tracker *> * _Nonnull reports, NSString * _Nonnull mostFreqTracker, NSInteger noTrackersPrevented) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.trackerOutlineView reloadData];
            weakSelf.trackersPreventedLabel.stringValue = [NSString stringWithFormat:@"%lu", noTrackersPrevented];
            weakSelf.mostFreqTrackerLabel.stringValue = mostFreqTracker;
        });
    } error:^(NSError * _Nonnull error) {
        
    }];

    [viewModel getTrackerRatioWithSuccess:^(NSString * _Nonnull percentage) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.emailRatioLabel.stringValue = percentage;
        });
    } error:^(NSError * _Nonnull error) {
        
    }];
}

#pragma mark - IBAction

- (IBAction)showMoreHelpPressed:(NSButton *)sender {
    [_helpStackView setHidden:!_helpStackView.isHidden];
    [_showMoreHelp setTitle:!_helpStackView.isHidden ? MTBLocalizedString(@"SHOW_LESS_DETAIL") : MTBLocalizedString(@"SHOW_MORE_DETAIL")];
}

- (IBAction)onOutlineDoubleAction:(id)sender {
    id item = [_trackerOutlineView itemAtRow:_trackerOutlineView.selectedRow];
    if ([item isKindOfClass:[Email class]]) {
        NSURL *deeplink = [NSURL URLWithString:[(Email*)item deeplink]];
        [[NSWorkspace sharedWorkspace] openURL:deeplink];
    } else {
        if ([_trackerOutlineView isItemExpanded:item]) {
            [_trackerOutlineView collapseItem:item];
        } else {
            [_trackerOutlineView expandItem:item];
        }
    }
    [_trackerOutlineView deselectRow:_trackerOutlineView.selectedRow];
}

#pragma mark - Private

-(BOOL)isAppearanceDark {
    NSAppearance * appearance = self.view.effectiveAppearance;
    if (@available(macOS 10.14, *)) {
        NSAppearanceName basicAppearance = [appearance bestMatchFromAppearancesWithNames:@[
            NSAppearanceNameAqua,
            NSAppearanceNameDarkAqua
        ]];
        return [basicAppearance isEqualToString:NSAppearanceNameDarkAqua];
    } else {
        return NO;
    }
}

-(NSColor*)statCellBackground {
    if ([self isAppearanceDark]) {
        return [NSColor colorWithRed: 0.18 green: 0.19 blue: 0.20 alpha: 1.00];
    }
    return [NSColor colorWithRed: 0.95 green: 0.95 blue: 0.95 alpha: 1.00];
}

-(void)setStatTileStyleFor:(NSView*)view {
    view.wantsLayer = YES;
    view.layer.cornerRadius = 8.0;
    view.layer.backgroundColor = [[self statCellBackground] CGColor];
}

#pragma mark - NSOutlineViewDelegate

-(NSView*)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    NSUserInterfaceItemIdentifier colId = tableColumn.identifier;
    if (!tableColumn || !colId) {
        return nil;
    }
    
    if ([colId isEqualToString:@"col1"]) {
        tableColumn.title = MTBLocalizedString(@"TRACKER_COLUMN");
        NSUserInterfaceItemIdentifier cellId = @"cell1";
        NSTableCellView *cell = [outlineView makeViewWithIdentifier:cellId owner:nil];
        if (![cell isKindOfClass:[NSTableCellView class]]) {
            return nil;
        }
        if ([item isKindOfClass:[Tracker class]]) {
            Tracker *tracker = (Tracker *)item;
            cell.textField.stringValue = tracker.name;
        } else {
            Email *email = (Email *)item;
            cell.textField.stringValue = email.subject;
        }
        return cell;
    } else {
        NSUserInterfaceItemIdentifier cellId = @"cell2";
        tableColumn.title = MTBLocalizedString(@"NUMBER_TIMES_TRACKER_SEEN_COLUMN");
        NSTableCellView *cell = [outlineView makeViewWithIdentifier:cellId owner:nil];
        if (![cell isKindOfClass:[NSTableCellView class]]) {
            return nil;
        }
        if ([item isKindOfClass:[Tracker class]]) {
            Tracker *tracker = (Tracker *)item;
            cell.textField.stringValue = [NSString stringWithFormat:@"%lu", tracker.reports.count];
        } else {
            cell.textField.stringValue = @"";
        }
        return cell;
    }
}

#pragma mark - NSOutlineViewDataSource

- (NSInteger)outlineView:(NSOutlineView *)outlineView
  numberOfChildrenOfItem:(id)item {
    return [viewModel numberOfChildrenOfItem:item];
}

- (id)outlineView:(NSOutlineView *)outlineView
            child:(NSInteger)index
           ofItem:(id)item {
    return [viewModel modelAtChild:index ofItem:item];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
   isItemExpandable:(id)item {
    return [viewModel isItemExpandable:item];
}
@end
