//
//  NSManagedObjectContext+Merge.m
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2021/05/15.
//

#import "NSManagedObjectContext+Merge.h"

@implementation NSManagedObjectContext (Merge)
-(void)executeAndMergeChangesUsing:(NSBatchDeleteRequest*)batchDeleteRequest error:(NSError**)error {
    batchDeleteRequest.resultType = NSBatchDeleteResultTypeObjectIDs;
    NSError *deleteError = nil;
    id result = [self executeRequest:batchDeleteRequest error:&deleteError];
    NSDictionary *changes = @{NSDeletedObjectsKey: !result ? result : @[]};
    [NSManagedObjectContext mergeChangesFromRemoteContextSave:changes intoContexts:@[self]];
}
@end
