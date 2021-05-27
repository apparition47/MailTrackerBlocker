//
//  MTBPackageValidator.h
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2021/05/27.
//

#import <Foundation/Foundation.h>

@interface MTBPackageValidator : NSObject
// checks a .pkg created and signed with productbuild/productsign
+(BOOL)isPkgSignatureValidAtURL:(NSURL *)url;
@end
