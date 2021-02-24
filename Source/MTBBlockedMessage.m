//
//  MTBBlockedMessage.m
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2020/07/12.
//

#import "MTBBlockedMessage.h"
#import "NSString+RegEx.h"

@interface MTBBlockedMessage ()
@property (nonatomic, copy) NSString *sanitizedHtml;
@property (nonatomic, retain) NSMutableDictionary *results;
@property (nonatomic, weak) id <MTBBlockedMessageDelegate> delegate;
@end

@implementation MTBBlockedMessage

NSString *kGenericSpyPixel = @"_Generic Spy Pixel";

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

- (NSString *)detectedTracker {
    for (NSString *key in results) {
        if ([key isEqualToString:kGenericSpyPixel]) {
            continue;
        }
        return key;
    }
    return nil;
}

- (enum BLOCKING_RESULT_CERTAINTY)certainty {
    if ([results count] == 0) {
        return BLOCKING_RESULT_CERTAINTY_LOW_NO_MATCHES;
    } else if ([results count] == 1 && [results objectForKey:kGenericSpyPixel]) {
        return BLOCKING_RESULT_CERTAINTY_MODERATE_HEURISTIC;
    }
    return BLOCKING_RESULT_CERTAINTY_CONFIDENT_HARD_MATCH;
}

- (NSString*)sanitizedHtml {
    return _sanitizedHtml;
}

#pragma mark - Helpers
- (NSString*)sanitizedHtmlFromHtml:(NSString*)html {
    NSString *result = html;
    NSDictionary *trackingDict = [self getTrackerDict];
    for (id trackingSourceKey in trackingDict) {
        for (NSString *regexStr in [trackingDict objectForKey:trackingSourceKey]) {
            NSRange matchedRange = [result rangeFromPattern:regexStr];
            if (matchedRange.location != NSNotFound) {
                results[trackingSourceKey] = result;
                result = [result stringByReplacingCharactersInRange:matchedRange withString:@""];
            }
        }
    }
    return result;
}

- (NSDictionary*)getTrackerDict {
    return @{
        @"ActionKit": @[@"track.sp.actionkit.com/q/"],
        @"Active": @[@"click.email.active.com/q"],
        @"ActiveCampaign": @[@"/lt.php(.*)\\?l=open/"],
        @"Adobe": @[
            @"demdex.net",
            @"t.info.adobesystems.com",
            @"toutapp.com",
//            @"/trk\\?t=",
            @"sparkpostmail2.com",
        ],
        @"AgileCRM": @[@"agle2.me/open"],
        @"Airbnb": @[@"email.airbnb.com/wf/open"],
        @"AirMiles": @[@"email.airmiles.ca/O"],
        @"Alaska Airlines": @[
            @"click.points-mail.com/open",
            @"sjv.io/i/",
            @"gqco.net/i/",
        ],
        @"Amazon SES": @[
            @".r.(us-east-2|us-east-1|us-west-2|ap-south-1|ap-northeast-2|ap-southeast-1|ap-southeast-2|ap-northeast-1|ca-central-1|eu-central-1|eu-west-1|eu-west-2|sa-east-1|us-gov-west-1).awstrack.me/[A-Z][0-9]/[0-9]",
            @"awstrack.me",
            @"aws-track-email-open",
            @"/gp/r.html",
            @"/gp/forum/email/tracking",
            @"amazonappservices.com/trk",
            @"amazonappservices.com/r/",
            @"awscloud.com/trk"
        ],
        @"Appriver": @[@"appriver.com/e1t/o/"],
        @"Apptivo": @[@"apptivo.com"],
        @"Asus": @[@"emditpison.asus.com"],
        @"AWeber": @[@"openrate.aweber.com"],
        @"Axios": @[@"link.axios.com/img/.*.gif"],
        @"Bananatag": @[@"bl-1.com"],
        @"Blueshift.com": @[
            @"blueshiftmail.com/wf/open",
            @"getblueshift.com/track"
        ],
        @"Bombcom": @[@"bixel.io"],
        @"Boomerang": @[@"mailstat.us/tr"],
        @"Boots": @[@"boots.com/rts/open.aspx"],
        @"Boxbe": @[@"boxbe.com/stfopen"],
        @"Browserstack": @[@"browserstack.com/images/mail/track-open"],
        @"BuzzStream": @[@"tx.buzzstream.com"],
        @"Campaign Monitor": @[@"/cmail(\\d+).com/t//"],
        @"CanaryMail": @[@"canarymail.io(:d+)?/track", @"pardot.com/r/"],
        @"CircleCI": @[@"https://email.circleci.com/o/"],
        @"Cirrus Insight": @[@"tracking.cirrusinsight.com"],
        @"Clio": @[@"market.clio.com/trk"],
        @"Close": @[@"close.(io|com)/email_opened", @"dripemail2"],
        @"cloudHQ": @[@"cloudhq.io/mail_track", @"cloudhq-mkt(d).net/mail_track"],
        @"Coda": @[@"coda.io/logging/ping"],
        @"CodePen": @[@"mailer.codepen.io/q"],
        @"ConneQuityMailer": @[@"connequitymailer.com/open/"],
        @"Constant Contact": @[@"rs6.net/on.jsp"],
        @"ContactMonkey": @[@"contactmonkey.com/api/v1/tracker"],
        @"ConvertKit": @[@"convertkit-mail.com/o/"],
        @"Copper": @[@"prosperworks.com/tp/t"],
        @"Cprpt": @[@"/o.aspx?t="],
        @"Creditmantri.com": @[@"mailer.creditmantri.com/t/"],
        @"Critical Impact": @[@"portal.criticalimpact.com/c2/"],
        @"Customer.io": @[
            @"customeriomail.com/e/o",
            @"track.customer.io/e/o",
            @"/e/o/[a-zA-Z0-9]{63}",
        ],
        @"Dell": @[@"ind.dell.com"],
        @"DidTheyReadIt": @[@"xpostmail.com"],
        @"DotDigital": @[@"trackedlink.net", @"dmtrk.net"],
        @"Driftem": @[@"driftem.com/ltrack"],
        @"Dropbox": @[@"dropbox.com/l/"],
        @"DZone": @[@"mailer.dzone.com/open.php"],
        @"Ebsta": @[@"console.ebsta.com", @"ebsta.gif", @"ebsta.com/r/"],
        @"EdgeSuite": @[@"epidm.edgesuite.net"],
        @"Egocdn": @[@"egocdn.com/syn/mail_s.php"],
        @"EmailTracker.website": @[@"my-email-signature.link"],
        @"Emarsys": @[@"emarsys.com/e2t/o/"],
        @"Etransmail": @[@"ftrans03.com/linktrack/"],
        @"EventBrite": @[@"eventbrite.com/emails/action"],
        @"EventsInYourArea": @[@"eventsinyourarea.com/track/"],
        @"EveryAction": @[@"click.everyaction.com/j/"],
        @"Evite": @[@"pippio.com/api/sync", @"nli.evite.com/imp"],
        @"Facebook": @[
            @"facebook.com/email_open_log_pic.php",
            @"facebookdevelopers.com/trk",
            @"fb.com/trk",
        ],
        @"Flipkart": @[@"flipkart.com/t/open"],
        @"ForMirror": @[@"formirror.com/open/"],
        @"FreeLancer": @[@"freelancer.com/1px.gif"],
        @"FreshMail": @[
            @"mail.[a-zA-Z0-9-.]+.pl/o/",
            @"/o/(w){10,}/(w){10,}",
        ],
        @"FrontApp": @[@"web.frontapp.com/api"],
        @"FullContact": @[@"fullcontact.com/wf/open"],
        @"GearBest": @[@"appinthestore.com/marketing/mail-user-deal/open"],
        @"Gem": @[@"zen.sr/o"],
        @"GetBase": @[@"getbase.com/e1t/o/"],
        @"GetMailSpring": @[@"getmailspring.com/open"],
        @"Getnotify": @[@"email81.com/case"],
        @"GetPocket": @[@"email.getpocket.com/wf/open"],
        @"GetResponse": @[@"getresponse.com/open.html"],
        @"GitHub": @[@"github.com/notifications/beacon/"],
        @"Glassdoor": @[@"mail.glassdoor.com/pub/as"],
        @"Gmass": @[@"ec2-52-26-194-35.us-west-2.compute.amazonaws.com"],
        @"Gmelius": @[@"gml.email"],
        @"Google": @[
            @"ad.doubleclick.net/ddm/ad",
            @"google-analytics.com/collect",
            @"google.com/appserve/mkt/img/",
        ],
        @"Grammarly": @[@"grammarly.com/open"],
        @"Granicus": @[@"govdelivery.com(:d+)?/track"],
        @"GreenMailInc": @[@"greenmail.co.in"],
        @"GrowthDot": @[@"growthdot.com/api/mail-tracking"],
        @"FreshMail": @[@"//o/(\\w){10,}/(\\w){10,}/"],
        @"Hubspot": @[@"t.(hubspotemail|hubspotfree|signaux|senal|sidekickopen|sigopn)"],
        @"Hunter.io": @[@"mltrk.io/pixel"],
        @"iContact": @[@"click.icptrack.com/icp"],
        @"Infusionsoft": @[@"infusionsoft.com/app/emailOpened"],
        @"Insightly": @[@"insgly.net/api/trk"],
        @"Intercom": @[@"via.intercom.io/o", @"intercom-mail[a-zA-Z0-9-.]*.com/(via/)?(o|q)"],
        @"Is-tracking-pixel-api-prod.appspot.com": @[@"is-tracking-pixel-api-prod.appspot.com"],
//        @"JangoMail": @["/[a-z].z\\?[a-z]="],
        @"LaunchBit": @[@"launchbit.com/taz-pixel"],
        @"LinkedIn": @[@"linkedin.com/emimp/"],
        @"Litmus": @[@"emltrk.com"],
        @"Klaviyo": @[@"trk.klaviyomail.com"],
        @"Magento": @[
            @"magento.com/trk",
            @"magento.com/wf/open",
            @"go.rjmetrics.com"
        ],
        @"Mailbutler": @[@"bowtie.mailbutler.io/tracking/hit/(.*)/t.gif"],
        @"Mailchimp": @[@"list-manage.com/track"],
        @"MailCoral": @[@"mailcoral.com/open"],
        @"Mailgun": @[@"/email.(mailgun|mg)(.*)\\?/o/"],
        @"MailInifinity": @[@"mailinifinity.com/ptrack"],
        @"Mailjet": @[@"mjt.lu/oo", @"links.[a-zA-Z0-9-.]+/oo/"],
        @"Mailspring": @[@"getmailspring.com/open"],
        @"MailTag": @[@"mailtag.io/email-event"],
        @"MailTrack": @[@"mailtrack.io/trace", @"mltrk.io/pixel"],
        @"Mandrill": @[@"mandrill.S+/track/open.php"],
        @"Mailzter": @[@"mailzter.in/ltrack"],
        @"Marketo": @[@"resources.marketo.com/trk"/*, @"/trk\\?t="*/],
        @"Mention": @[@"mention.com/e/o/"],
        @"MetaData": @[@"metadata.io/e1t/o/"],
        @"MixMax": @[
            @"(email|track).mixmax.com",
            @"mixmax.com/api/track/",
            @"mixmax.com/e/o"
        ],
        @"Mixpanel": @[@"api.mixpanel.com/(trk|track)"],
        @"MyEmma": @[@"e2ma.net/track", @"t.e2ma.net"],
        @"Nation Builder": @[
            @"nationbuilder.com/r/o",
            @"nationbuilder.com/wf/open"
        ],
        @"NeteCart": @[@"netecart.com/ltrack"],
        @"NetHunt": @[
            @"nethunt.com/api/v1/track/email/",
            @"nethunt.co(.*)\\?/pixel.gif"
        ],
        @"NewtonHQ": @[@"tr.cloudmagic.com"],
        @"OpenBracket": @[@"openbracket.co/track"],
        @"Opicle": @[@"track.opicle.com"],
        @"Oracle": @[
            @"tags.bluekai.com/site",
            @"en25.com/e/",
            @"dynect.net/trk.php",
            @"bm5150.com/t/",
            @"bm23.com/t/",
            @"[a-zA-Z0-9-.]+/e/FooterImages/FooterImage"
        ],
        @"Outreach": @[
            @"app.outreach.io",
            @"outrch.com/api/mailings/opened",
            @"getoutreach.com/api/mailings/opened",
        ],
        @"PayBack": @[@"email.payback.in/a/", @"mail.payback.in/tr/"],
        @"PayPal": @[@"paypal-communication.com/O/"],
        @"Paytm": @[@"email.paytm.com/wf/open", @"trk.paytmemail.com"],
        @"phpList": @[@"phplist.com/lists/ut.php"],
        @"PipeDrive": @[@"pipedrive.com/wf/open", @"api.nylas.com/open"],
        @"Playdom": @[@"playdom.com/g"],
        @"Polymail": @[@"polymail.io"],
        @"Postmark": @[@"pstmrk.it"],
        @"Product Hunt": @[@"links.producthunt.com/oo/"],
        @"ProlificMail": @[@"prolificmail.com/ltrack"],
        @"Questrade": @[@"email.questrade.com/trk\\?t"],
        @"Quora": @[@"quora.com/qemail/mark_read"],
        @"ReplyCal": @[@"replycal.com/home/index/\\?token"],
        @"ReplyMsg": @[@"replymsg.com"],
        @"Responder.co.il": @[@"opens.responder.co.il"],
        @"Return Path": @[@"returnpath.net/pixel.gif"],
        @"Rocketbolt": @[@"email.rocketbolt.com/o/"],
        @"Runtastic": @[@"runtastic.com/mo/"],
        @"Sailthru": @[@"sailthru.com/trk"],
        @"Salesforce": @[
            @"salesforceiq.com/t.png",
            @"beacon.krxd.net",
            @"app.relateiq.com/t.png",
            @"nova.collect.igodigital.com",
            @"exct.net/open.aspx"
        ],
        @"SalesHandy": @[@"saleshandy.com/web/email/countopened"],
        @"SalesLoft": @[@"salesloft.com/email_trackers"],
        @"Segment": @[@"email.segment.com/e/o/"],
        @"SendInBlue": @[@"sendibtd.com", @"sendibw{2}.com/track/"],
        @"Sendgrid": @[
            @"sendgrid.(net|com)/wf/open",
            @"sendgrid.(net|com)/trk",
            @"sendgrid.(net|com)/mpss/o",
            @"sendgrid.(net|com)/ss/o"
//            @"wf/open\\?upn"
        ],
        @"SendPulse": @[@"stat-pulse.com"],
        @"Sendy": @[@"/sendy/t/"],
        @"Skillsoft": @[@"skillsoft.com/trk"],
        @"Streak": @[@"mailfoogae.appspot.com"],
        @"Substack": @[@"substack.com/o/"],
        @"Superhuman": @[@"r.superhuman.com"],
        @"TataDocomoBusiness": @[@"tatadocomobusiness.com/rts/"],
        @"Techgig": @[@"tj_mailer_opened_count_all.php"],
        @"The Atlantic": @[@"links.e.theatlantic.com/open/log/"],
        @"TheTopInbox": @[@"thetopinbox.com/track/"],
        @"Thunderhead": @[@"na5.thunderhead.com"],
        @"Tinyletter": @[@"tinyletterapp.com.*\\?open.gif/"],
        @"ToutApp": @[@"go.toutapp.com"],
        @"Track": @[
            @"trackapp.io/(b|r)/",
            @"trackapp.io/static/img/track.gif"
        ],
        @"Transferwise": @[@"links.transferwise.com/track/"],
        @"Trello": @[@"sptrack.trello.com/q/", @"i.trellomail.com/e/eo"],
        @"Udacity": @[@"udacity.com/wf/open"],
        @"Unsplash": @[@"email.unsplash.com/o/"],
        @"Upwork": @[@"email.mg.upwork.com/o/"],
        @"Vcommission": @[@"tracking.vcommission.com"],
        @"Vrbo": @[@"sp.trk.homeaway.com/q/"],
        @"Vtiger": @[@"od2.vtiger.com/shorturl.php"],
        @"WildApricot": @[
            @"wildapricot.com/o/",
            @"wildapricot.org/emailtracker"
        ],
        @"Wix": @[@"shoutout.wix.com/.*/pixel"],
        @"Workona": @[@"workona.com/mk/op/"],
        @"YAMM": @[@"yamm-track.appspot"],
        @"Yesware": @[@"yesware.com/trk", @"yesware.com/t/", @"t.yesware.com"],
        @"Zendesk": @[@"futuresimple.com/api/v1/sprite.png"],

        kGenericSpyPixel: @[@"<img[^>]+(1px|\"1\"|'1')+[^>]*>"]
    };
}
@end
