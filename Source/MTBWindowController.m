//
//  MTBWindowController.m
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2021/07/17.
//

#import "MTBWindowController.h"

#pragma mark - MTBWindowManager

@interface MTBWindowManager: NSViewController
@property(strong) NSMutableDictionary *refs;
@end

@implementation MTBWindowManager

@synthesize refs;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static MTBWindowManager *_instance;
    dispatch_once(&onceToken, ^{
        _instance = [[MTBWindowManager alloc] init];
    });
    return _instance;
}

- (id)init {
    if(self = [super init]) {
        self.refs = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

-(void)addRef:(NSWindowController*)winController {
    NSString *key = [NSString stringWithFormat:@"%@", @(winController.hash)];
    [refs setObject:winController forKey: key];
}

-(void)removeRef:(NSWindowController*)winController {
    NSString *key = [NSString stringWithFormat:@"%@", @(winController.hash)];
    [refs removeObjectForKey:key];
}
@end

#pragma mark - MTBWindowController

@interface MTBWindowController ()

@end

@implementation MTBWindowController

- (id)initWithWindow:(NSWindow *)window {
    if (self = [super initWithWindow:window]) {
        [window setDelegate:self];
        [[MTBWindowManager sharedInstance] addRef:self];
    }
    return self;
}

#pragma mark - NSWindowDelegate

-(void)windowWillClose:(NSNotification *)notification {
    [[MTBWindowManager sharedInstance] removeRef:self];
}

@end
