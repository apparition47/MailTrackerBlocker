//
//  MTBBlockedMessage.m
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2020/07/12.
//

#import <RegexKit/RegexKit.h>
#import "MTBBlockedMessage.h"

@interface MTBBlockedMessage ()
@property (nonatomic, copy) NSString *sanitizedHtml;
@property (nonatomic, retain) NSMutableDictionary *results;
@property (nonatomic, weak) id <MTBBlockedMessageDelegate> delegate;
@end

@implementation MTBBlockedMessage

@synthesize results, delegate;

- (id)initWithHtml:(NSString*)html {
    self = [self init];
    if (!self) {
        return nil;
    }
    results = [[NSMutableDictionary alloc] init];
    _sanitizedHtml = [self sanitizedHtmlFromHtml: html];
    return self;
}

- (NSUInteger)blockedCount {
    return results.count;
}

- (NSString*)sanitizedHtml {
    return _sanitizedHtml;
}

- (NSString *)description {
    NSString *desc = @"";
    for (id key in results) {
        desc = [desc stringByAppendingFormat:@"%@\n", key];
    }
    return desc;
}

#pragma mark - Helpers
- (NSString*)sanitizedHtmlFromHtml:(NSString*)html {
    NSString *result = html;
    NSDictionary *trackingDict = [self getTrackerDict];
    for (id trackingSourceKey in trackingDict) {
        for (NSString *regexStr in [trackingDict objectForKey:trackingSourceKey]) {
            NSRange matchedRange = [self rangeFromString:result pattern:regexStr];
            if (matchedRange.location != NSNotFound) {
                results[trackingSourceKey] = result;
                result = [result stringByReplacingCharactersInRange:matchedRange withString:@""];
            }
        }
    }
    return result;
}

#pragma mark - Helpers

- (NSRange)rangeFromString:(NSString*)html pattern:(NSString*)pattern {
    NSRange match = NSMakeRange(NSNotFound, 0);
    if([html length] == 0)
        return match;
    @try {
        RKRegex *sigRKRegex = [RKRegex regexWithRegexString:pattern options:RKCompileNoOptions];
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
        @"ActiveCampaign": @[@"/lt.php(.*)\\?l=open/"],
        @"Amazon SES": @[@".r.(us-east-2|us-east-1|us-west-2|ap-south-1|ap-northeast-2|ap-southeast-1|ap-southeast-2|ap-northeast-1|ca-central-1|eu-central-1|eu-west-1|eu-west-2|sa-east-1|us-gov-west-1).awstrack.me/[A-Z][0-9]/[0-9]"],
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
        @"GitHub": @[@"github.com/notifications/beacon/"],
        @"GrowthDot": @[@"growthdot.com/api/mail-tracking"],
        @"FreshMail": @[@"/\\/o\\/(\\w){10,}\\/(\\w){10,}/"],
        @"Hubspot": @[@"t.(hubspotemail|hubspotfree|signaux|senal|sidekickopen|sigopn)"],
        @"iContact": @[@"click.icptrack.com/icp"],
        @"Intercom": @[@"via.intercom.io/o", @"intercom-mail.com/via/o"],
        @"Litmus": @[@"emltrk.com"],
        @"Mailchimp": @[@"list-manage.com/track"],
        @"Mailgun": @[@"/email.(mailgun|mg)(.*)\\?/o/"],
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
        @"SendGrid": @[@"wf/open\\?upn"],
        @"Sendy": @[@"/sendy/t/"],
        @"Streak": @[@"mailfoogae.appspot.com"],
        @"Superhuman": @[@"r.superhuman.com"],
        @"Thunderhead": @[@"na5.thunderhead.com"],
        @"Tinyletter": @[@"/tinyletterapp.com.*\\?open.gif/"],
        @"Wix": @[@"shoutout.wix.com/.*/pixel"],
        @"YAMM": @[@"yamm-track.appspot"],
        @"Yesware": @[@"t.yesware.com"],
        @"Zendesk Sell": @[@"futuresimple.com/api/v1/sprite.png"],
        
        @"_Generic Spy Pixel": @[@"<img[^>]+(1px|\"1\"|'1')+[^>]*>"]
    };
}
@end
