//
//  MTBReportViewModel.h
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2021/05/12.
//

#import <AppKit/AppKit.h>
#import "Reports+CoreDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MTBReportViewModel : NSObject
- (void)getTrackersWithSuccess:(void (^)(NSArray<Tracker*> *reports, NSString *mostFreqTracker, NSInteger noTrackersPrevented))successCompletion error:(void (^)(NSError *error))errorCompletion;
- (void)getTrackerRatioWithSuccess:(void (^)(NSString *percentage))successCompletion error:(void (^)(NSError *error))errorCompletion;
//- (NSUInteger)numberOfItems;
//- (NSUInteger)numberOfSections;
//- (nullable Tracker *)itemAtIndexPath:(NSIndexPath *)indexPath;

-(NSInteger)numberOfChildrenOfItem:(id)item;
-(id)modelAtChild:(NSInteger)index ofItem:(id)item;
-(BOOL)isItemExpandable:(id)item;
@end

NS_ASSUME_NONNULL_END
