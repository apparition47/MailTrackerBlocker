//
//  MTBReportingManager.m
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2021/04/28.
//

#import "MTBReportingManager.h"
#import "Reports+CoreDataModel.h"
#import "MTBCoreDataManager.h"
#import "NSManagedObjectContext+Merge.h"
#import "MTBBlockedMessage.h"

@implementation MTBReportingManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static MTBReportingManager *_instance;
    dispatch_once(&onceToken, ^{
        _instance = [[MTBReportingManager alloc] init];
    });
    return _instance;
}

-(void)markEmailRead:(MTBBlockedMessage*)blkMsg {
    NSManagedObjectContext *context = [[MTBCoreDataManager sharedInstance] managedObjectContext];

    [context performBlock:^{
        // save/update email
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"deeplink == %@", blkMsg.deeplinkField];
        fetchRequest.fetchLimit = 1;
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Email"
                                                  inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        
        NSError *error = nil;
        NSArray<Email *> *fetchResults = [context executeFetchRequest:fetchRequest error:&error];
        if (error != nil) {
            return;
        }
        Email *email;
        if (fetchResults.count > 0 && ![fetchResults.firstObject.tracker.name isEqualToString:blkMsg.detectedTracker]) {
            // if tracker has assoc with tracker rule that since changed
            [context deleteObject:fetchResults.firstObject];
            
            email = [NSEntityDescription insertNewObjectForEntityForName:@"Email" inManagedObjectContext:context];
            [email setSubject:blkMsg.subjectField];
            [email setDeeplink:blkMsg.deeplinkField];
            [email setTo:blkMsg.toField];
            [email setRead_timestamp:[NSDate date]];
        } else if (fetchResults.count > 0) {
            // id'd tracker exists and is same as previous record
            email = fetchResults.firstObject;
        } else {
            email = [NSEntityDescription insertNewObjectForEntityForName:@"Email" inManagedObjectContext:context];
            [email setSubject:blkMsg.subjectField];
            [email setDeeplink:blkMsg.deeplinkField];
            [email setTo:blkMsg.toField];
            [email setRead_timestamp:[NSDate date]];
        }
        
        // check if tracker has been prev saved
        if (blkMsg.detectedTracker != nil) {
            fetchRequest = [[NSFetchRequest alloc] init];
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name == %@", blkMsg.detectedTracker];
            fetchRequest.fetchLimit = 1;
            entity = [NSEntityDescription entityForName:@"Tracker"
                                                      inManagedObjectContext:context];
            [fetchRequest setEntity:entity];
            
            error = nil;
            NSArray<Tracker *> *trackerFetchResults = [context executeFetchRequest:fetchRequest error:&error];
            if (error != nil) {
                return;
            }
            
            // update tracker with email added
            if (trackerFetchResults.count > 0) {
                [[trackerFetchResults.firstObject mutableSetValueForKey:@"reports"] addObject:email];
            } else {
                // create new tracker
                Tracker *tracker = [NSEntityDescription insertNewObjectForEntityForName:@"Tracker" inManagedObjectContext:context];
                [tracker setName:blkMsg.detectedTracker];
                [tracker setReports:[NSSet setWithArray:@[email]]];
            }
        }

        [[MTBCoreDataManager sharedInstance] saveContext];
    }];
}

-(void)purgeReports30DaysOrOlder {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Email"];

    NSDate *past30Days = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:-30 toDate:[NSDate date] options:0];
    request.predicate = [NSPredicate predicateWithFormat:@"read_timestamp < %@", past30Days];
    NSBatchDeleteRequest *delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];

    NSManagedObjectContext *context = [[MTBCoreDataManager sharedInstance] managedObjectContext];
    [context performBlock:^{
        NSError *deleteError = nil;
        [context executeAndMergeChangesUsing:delete error:&deleteError];
    }];
}

@end
