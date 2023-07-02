//
//  MTBReportViewController.h
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2021/04/18.
//

#import <Appkit/Appkit.h>

@interface MTBReportViewController : NSViewController <NSOutlineViewDelegate, NSOutlineViewDataSource>
-(void)fetchData;
@end
