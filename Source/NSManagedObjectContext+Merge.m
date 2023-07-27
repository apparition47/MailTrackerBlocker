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
    NSBatchDeleteResult *bur = [self executeRequest:batchDeleteRequest error:&deleteError];
    if (bur && bur.resultType == NSUpdatedObjectIDsResultType){
        NSArray <NSManagedObjectID*> *arr = bur.result;
        if ([arr isKindOfClass:NSArray.class] && arr.count > 0) {
            [NSManagedObjectContext mergeChangesFromRemoteContextSave:@{NSUpdatedObjectsKey:arr} intoContexts:@[self]];
        }
    }
}
@end
