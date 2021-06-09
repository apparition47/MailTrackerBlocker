//
//  MTBLicensesViewController.m
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2021/06/09.
//

#import "MTBLicensesViewController.h"
#import "MTBMailBundle.h"

@interface MTBLicensesViewController ()
@property (strong) IBOutlet NSTextView *textView;
@end

@implementation MTBLicensesViewController

@synthesize preferredContentSize, textView;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

#pragma mark - Private

-(void)setupView {
    preferredContentSize = CGRectMake(0, 0, 569, 600).size; // prevent window resize
    
    __weak MTBLicensesViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURL *licenseURL = [[MTBMailBundle bundle] URLForResource:@"ACKNOWLEDGEMENTS" withExtension:nil];
        weakSelf.textView.string = [NSString stringWithContentsOfURL:licenseURL encoding:NSUTF8StringEncoding error:nil];
    });
}

@end
