//
//  NSManagedObjectContext+Merge.h
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2021/05/15.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (Merge)
-(void)executeAndMergeChangesUsing:(NSBatchDeleteRequest*)NSBatchDeleteRequest error:(NSError**)error;
@end
