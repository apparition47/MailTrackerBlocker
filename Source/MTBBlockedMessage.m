//
//  MTBBlockedMessage.m
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2020/07/12.
//

#import "MTBBlockedMessage.h"
#import "NSString+RegEx.h"
#import "HTMLParser.h"

@interface MTBBlockedMessage ()
@property (nonatomic, copy) NSString *sanitizedHtml;
@property (nonatomic, retain) NSMutableSet *trackingSourceResults;
@property (nonatomic, weak) id <MTBBlockedMessageDelegate> delegate;
@end

@implementation MTBBlockedMessage

NSString *kGenericSpyPixel = @"_Generic Spy Pixel";

@synthesize trackingSourceResults, delegate;

- (id)initWithHtml:(NSString*)html {
    self = [self init];
    if (!self) {
        return nil;
    }
    trackingSourceResults = [[NSMutableSet alloc] init];
    _sanitizedHtml = [self sanitizedHtmlFromHtml: html];
    return self;
}

- (NSString *)detectedTracker {
    for (NSString *key in trackingSourceResults) {
        if ([key isEqualToString:kGenericSpyPixel]) {
            continue;
        }
        return key;
    }
    return nil;
}

- (enum BLOCKING_RESULT_CERTAINTY)certainty {
    if ([trackingSourceResults count] == 0) {
        return BLOCKING_RESULT_CERTAINTY_LOW_NO_MATCHES;
    } else if ([trackingSourceResults count] == 1 && [trackingSourceResults containsObject:kGenericSpyPixel]) {
        return BLOCKING_RESULT_CERTAINTY_MODERATE_HEURISTIC;
    }
    return BLOCKING_RESULT_CERTAINTY_CONFIDENT_HARD_MATCH;
}

- (NSString*)sanitizedHtml {
    return _sanitizedHtml;
}

#pragma mark - Helpers
- (NSString*)sanitizedHtmlFromHtml:(NSString*)html {
    NSError * error = nil;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:html error:&error];
    if (error != nil) {
        return html;
    }
    
    HTMLNode *document = [parser doc];
    NSDictionary *trackingDict = [self getTrackerDict];
    
    for (HTMLNode *inputNode in [document findChildTags:@"img"]) {
        for (id trackingSourceKey in trackingDict) {
            for (NSString *regexStr in [trackingDict objectForKey:trackingSourceKey]) {
                if ([[inputNode getAttributeNamed:@"src"] hasMatchFromPattern:regexStr]) {
                    setAttributeNamed(inputNode->_node, "src", "localhost");
                    [trackingSourceResults addObject:trackingSourceKey];
                } else if (([[inputNode getAttributeNamed:@"width"] isEqualToString:@"1"] && [[inputNode getAttributeNamed:@"height"] isEqualToString:@"1"]) || [[inputNode getAttributeNamed:@"style"] isEqualToString:@"1px"]) {
                    setAttributeNamed(inputNode->_node, "src", "localhost");
                    [trackingSourceResults addObject:kGenericSpyPixel];
                }
            }
        }
    }
    
    return document.rawContents;
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
        @"Zendesk Sell": @[@"futuresimple.com/api/v1/sprite.png"]

//        kGenericSpyPixel: @[@"<img[^>]+(1px|\"1\"|'1')+[^>]*>"]
    };
}
@end
