//
//  NSString+MailTrackerBlocker.m
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2020/07/05.
//

#import <RegexKit/RegexKit.h>
#import <Foundation/Foundation.h>
#import "NSString+MailTrackerBlocker.h"
#import "MTBMailBundle.h"

@implementation NSString (MTBMail)

- (NSString*)trackerSanitized {
    NSString *result = self;
    NSDictionary *trackingDict = [self getTrackerDict];
    for (id trackingSourceKey in trackingDict) {
        for (NSString *regexStr in [trackingDict objectForKey:trackingSourceKey]) {
            NSRange matchedRange = [self rangeFromString:result pattern:regexStr];
            if (matchedRange.location != NSNotFound) {
                result = [result stringByReplacingCharactersInRange:matchedRange withString:@"localhost"];
            }
        }
    }
    return result;
}

#pragma mark - Helpers

- (NSRange)rangeFromString:(NSString*)html pattern:(NSString*)pattern {
    NSString *signatureRegex = [NSString stringWithFormat:@"%@",
                                pattern];
    NSRange match = NSMakeRange(NSNotFound, 0);
    if([html length] == 0)
        return match;
    @try {
        RKRegex *sigRKRegex = [RKRegex regexWithRegexString:signatureRegex options:RKCompileNoOptions];
        NSRange range = NSMakeRange(0, html.length);
        match = [html rangeOfRegex:sigRKRegex inRange:range capture:0];
    }
    @catch (NSException *exception) {
        // Ignore...
    }
    
    return match;
}

// source: https://gist.github.com/dhh/360f4dc7ddbce786f8e82b97cdad9d20
- (NSDictionary*)getTrackerDict {
    return @{
        @"ActiveCampaign": @[@"/lt.php(.*)?l=open/"],
        @"AWeber": @[@"openrate.aweber.com"],
        @"Bananatag": @[@"bl-1.com"],
        @"Boomerang": @[@"mailstat.us/tr"],
        @"Campaign Monitor": @[@"/cmail(\\d+).com/t//"],
        @"Cirrus Insight": @[@"tracking.cirrusinsight.com"],
        @"Close": @[@"close.com/email_opened"],
        @"Constant Contact": @[@"rs6.net/on.jsp"],
        @"ContactMonkey": @[@"contactmonkey.com/api/v1/tracker"],
        @"ConvertKit": @[@"convertkit-mail.com/o"],
        @"Critical Impact": @[@"portal.criticalimpact.com/c2/"],
        @"Emarsys": @[@"emarsys.com/e2t/o/"],
        @"Gem": @[@"zen.sr/o"],
        @"Getnotify": @[@"email81.com/case"],
        @"GetResponse": @[@"getresponse.com/open.html"],
        @"GrowthDot": @[@"growthdot.com/api/mail-tracking"],
        @"FreshMail": @[@"/\\/o\\/(\\w){10,}\\/(\\w){10,}/"],
        @"Hubspot": @[@"/t.(hubspotemail|hubspotfree|signaux|senal|sidekickopen|sigopn)/"],
        @"iContact": @[@"click.icptrack.com/icp"],
        @"Intercom": @[@"via.intercom.io/o", @"intercom-mail.com/via/o"],
        @"Litmus": @[@"emltrk.com"],
        @"Mailchimp": @[@"list-manage.com/track"],
        @"Mailgun": @[@"/email.(mailgun|mg)(.*)?/o/"],
        @"Mailjet": @[@"mjt.lu/oo"],
        @"Mailspring": @[@"getmailspring.com/open"],
        @"MailTrack": @[@"mailtrack.io/trace", @"mltrk.io/pixel"],
        @"Mandrill": @[@"mandrillapp.com/track"],
        @"Marketo": @[@"resources.marketo.com/trk"],
        @"MixMax": @[@"/(email|track).mixmax.com/"],
        @"Mixpanel": @[@"api.mixpanel.com/track"],
        @"NetHunt": @[@"/nethunt.co(.*)?/pixel.gif/"],
        @"Outreach": @[@"app.outreach.io"],
        @"phpList": @[@"phplist.com/lists/ut.php"],
        @"Polymail": @[@"polymail.io"],
        @"Postmark": @[@"pstmrk.it/open"],
        @"Return Path": @[@"returnpath.net/pixel.gif"],
        @"Sailthru": @[@"sailthru.com/trk"],
        @"Salesforce": @[@"nova.collect.igodigital.com"],
        @"SendGrid": @[@"wf/open?upn"],
        @"Sendy": @[@"/sendy/t/"],
        @"Streak": @[@"mailfoogae.appspot.com"],
        @"Superhuman": @[@"r.superhuman.com"],
        @"Thunderhead": @[@"na5.thunderhead.com"],
        @"Tinyletter": @[@"/tinyletterapp.com.*?open.gif/"],
        @"YAMM": @[@"yamm-track.appspot"],
        @"Yesware": @[@"t.yesware.com"],
        @"Zendesk Sell": @[@"futuresimple.com/api/v1/sprite.png"],
    };
}

@end
