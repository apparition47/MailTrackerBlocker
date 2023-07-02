//
//  MTBReportViewModel.m
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2021/05/12.
//

#import "MTBMailBundle.h"
#import "MTBReportViewModel.h"
#import <CoreData/CoreData.h>
#import "MTBCoreDataManager.h"
#import "MTBReportingManager.h"

@interface MTBReportViewModel() <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSArray<Tracker *> *reports;

@end

@implementation MTBReportViewModel

@synthesize managedObjectContext, fetchedResultsController = _fetchedResultsController;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.reports = @[];
        NSManagedObjectContext *context = [[MTBCoreDataManager sharedInstance] managedObjectContext];
        [self setManagedObjectContext:context];
    }
    return self;
}

- (void)getTrackersWithSuccess:(void (^)(NSArray<Tracker*> *reports, NSString *mostFreqTracker, NSInteger noTrackersPrevented))successCompletion error:(void (^)(NSError *error))errorCompletion {
    [managedObjectContext refreshAllObjects];

    __weak typeof(self) weakSelf = self;
    [managedObjectContext performBlock:^{
        __strong typeof(self) strongSelf = weakSelf;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tracker"
                                                  inManagedObjectContext:[self managedObjectContext]];
        [fetchRequest setEntity:entity];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                       ascending:YES];
        NSArray *sortDescriptors = @[sortDescriptor];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setFetchBatchSize:1000];
        
        
        NSError *error = nil;
        strongSelf.reports = [strongSelf.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        NSString *mostFreqTrackerName = @"";
        NSUInteger maxTrackerCount = 0;
        for (Tracker *tracker in strongSelf.reports) {
            if (tracker.reports.count > maxTrackerCount) {
                mostFreqTrackerName = tracker.name;
                maxTrackerCount = tracker.reports.count;
            }
        }
        
        if (error) {
            errorCompletion(error);
        } else {
            NSString *mostFreqText = [NSString stringWithFormat:MTBLocalizedString(@"TRACKER_PREVENTED_INSTANCES_STAT"), mostFreqTrackerName, maxTrackerCount];
            successCompletion(weakSelf.reports, !maxTrackerCount ? @"-" : mostFreqText, weakSelf.reports.count);
        }
    }];
}

- (void)getTrackerRatioWithSuccess:(void (^)(NSString *percentage))successCompletion error:(void (^)(NSError *error))errorCompletion {
    __weak typeof(self) weakSelf = self;
    [managedObjectContext performBlock:^{
        __strong typeof(self) strongSelf = weakSelf;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Email"
                                                  inManagedObjectContext:[self managedObjectContext]];
        [fetchRequest setEntity:entity];
        
        NSError *error = nil;
        NSArray<Email *> *emails = [strongSelf.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        NSInteger trackedEmails = 0;
        for (Email *email in emails) {
            trackedEmails += email.tracker != nil ? 1 : 0;
        }
        if (error) {
            errorCompletion(error);
        } else {
            if (!emails.count) {
                successCompletion(@"0%");
            } else {
                successCompletion([NSString stringWithFormat:@"%lu%%", 100*trackedEmails/emails.count]);
            }
        }
    }];
}

-(NSInteger)numberOfChildrenOfItem:(id)item {
    if (!item) {
        return _reports.count;
    }
    return ((Tracker *)item).reports.count;
}

-(id)modelAtChild:(NSInteger)index ofItem:(id)item {
    if (!item) {
        return _reports[index];
    }
    return ((Tracker *)item).reports.allObjects[index];
}

-(BOOL)isItemExpandable:(id)item {
    return [item isKindOfClass:[Tracker class]];
}
@end
