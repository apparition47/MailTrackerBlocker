//
//  MTBCoreDataManager.h
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2021/05/15.
//

#import <CoreData/CoreData.h>

@interface MTBCoreDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

-(void)saveContext;
+(instancetype)sharedInstance;

@end
