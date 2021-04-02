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
@property (nonatomic, retain) NSMutableSet *trackers;
@property BOOL matchedGeneric;
@property (nonatomic, weak) id <MTBBlockedMessageDelegate> delegate;
@end

@implementation MTBBlockedMessage

NSString * const kGenericSpyPixelRegex = @"<img[^>]+(width\\s*=[\"'\\s]*[01]p?x?[\"'\\s]|width:\\s*[01]px)+[^>]*>";

@synthesize trackers, delegate;

- (id)initWithHtml:(NSString*)html {
    self = [self init];
    if (!self) {
        return nil;
    }
    trackers = [[NSMutableSet alloc] init];
    _sanitizedHtml = [self sanitizedHtmlFromHtml: html];
    return self;
}

- (NSString *)detectedTracker {
    return [trackers anyObject];
}

- (enum BLOCKING_RESULT_CERTAINTY)certainty {
    if ([trackers count] > 0) {
        return BLOCKING_RESULT_CERTAINTY_CONFIDENT_HARD_MATCH;
    } else if (_matchedGeneric) {
        return BLOCKING_RESULT_CERTAINTY_MODERATE_HEURISTIC;
    } else {
        return BLOCKING_RESULT_CERTAINTY_LOW_NO_MATCHES;
    }
}

- (NSString*)sanitizedHtml {
    return _sanitizedHtml;
}

#pragma mark - Helpers
- (NSString*)sanitizedHtmlFromHtml:(NSString*)html {
    if (!html) {
        return nil;
    }
    
    NSString *result = html;
    NSDictionary *trackingDict = [self getTrackerDict];
    for (id trackingSourceKey in trackingDict) {
        for (NSString *regexStr in [trackingDict objectForKey:trackingSourceKey]) {
            NSRange matchedRange = [result rangeFromPattern:regexStr];
            if (matchedRange.location != NSNotFound) {
                [trackers addObject:trackingSourceKey];
                result = [result stringByReplacingCharactersInRange:matchedRange withString:@""];
            }
        }
    }
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:kGenericSpyPixelRegex options:NSRegularExpressionCaseInsensitive error:NULL];
    NSRange range = NSMakeRange(0, result.length);
    NSString *replaced = [regex stringByReplacingMatchesInString:result options:0 range:range withTemplate:@""];
    if (![replaced isEqualToString:result]) {
        _matchedGeneric = YES;
        result = replaced;
    }

    return result;
}

- (NSDictionary*)getTrackerDict {
    return @{
        @"365offers.trade": @[@"trk.365offers.trade"],
        @"Absolute Software": @[@"click.absolutesoftware-email.com/open.aspx"],
        @"ActionKit": @[@"track.sp.actionkit.com/q/"],
        @"Active": @[@"click.email.active.com/q"],
        @"ActiveCampaign": @[@"/lt.php(.*)\\?l=open/"],
        @"Acoustic": @[
            @"open.mkt\\d{2,3}.net/open/log/",
            @"mkt\\d{3,4,5}.com/open"
        ],
        @"Adobe": @[
            @"demdex.net",
            @"t.info.adobesystems.com",
            @"toutapp.com",
//            @"/trk\\?t=",
        ],
        @"AgileCRM": @[@"agle2.me/open"],
        @"Air Miles": @[@"email.airmiles.ca/O"],
        @"Alaska Airlines": @[
            @"click.points-mail.com/open",
            @"sjv.io/i/",
            @"gqco.net/i/",
        ],
        @"Amazon SES": @[
            @".r.(us-east-2|us-east-1|us-west-2|ap-south-1|ap-northeast-2|ap-southeast-1|ap-southeast-2|ap-northeast-1|ca-central-1|eu-central-1|eu-west-1|eu-west-2|sa-east-1|us-gov-west-1).awstrack.me/I0/[a-zA-Z0-9-]*/[a-zA-Z0-9-]*",
            @"aws-track-email-open",
            @"/gp/r.html",
            @"/gp/forum/email/tracking",
            @"amazonappservices.com/trk",
            @"amazonappservices.com/r/",
            @"awscloud.com/trk"
        ],
        @"Apple": @[
          @"apple.com/report/2/its_mail_sf",
          @"apple_email_link/spacer",
        ],
        @"Appriver": @[@"appriver.com/e1t/o/"],
        @"Apptivo": @[@"apptivo.com"],
        @"Artegic": @[@"elaine-asp.de"],
        @"ASUSTeK": @[@"emditpison.asus.com"],
        @"Atlassian": @[@"bitbucket.org/account/notifications/mark-read/"],
        @"AWeber": @[@"openrate.aweber.com"],
        @"Axios": @[@"link.axios.com/img/.*.gif"],
        @"Bananatag": @[@"bl-1.com"],
        @"Blueshift.com": @[
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
        @"Clockwise": @[@"x.getclockwise.com/q/"],
        @"Close": @[@"close.(io|com)/email_opened", @"dripemail2"],
        @"cloudHQ": @[@"cloudhq.io/mail_track", @"cloudhq-mkt(d).net/mail_track"],
        @"CNN": @[
            @"li.cnn.com/imp\\?", // live intent
            @"e.newsletters.cnn.com/open/" // zeta global
        ],
        @"Coda": @[@"coda.io/logging/ping"],
        @"CodePen": @[@"mailer.codepen.io/q"],
        @"ConneQuityMailer": @[@"connequitymailer.com/open/"],
        @"Constant Contact": @[@"rs6.net/on.jsp"],
        @"ContactMonkey": @[@"contactmonkey.com/api/v1/tracker"],
        @"ConvertKit": @[
            @"convertkit-mail.com/o/",
            @"open.convertkit-mail2.com/[a-z0-9]{20}"
        ],
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
        @"EmailTracker.website": @[@"my-email-signature.link"],
        @"Emarsys": @[@"emarsys.com/e2t/o/"],
        @"EmberPoint MailPublisher": @[@"rec.mpse.jp/(.*)/rw/beacon_"],
        @"Etransmail": @[@"ftrans03.com/linktrack/"],
        @"EventBrite": @[@"eventbrite.com/emails/action"],
        @"EventsInYourArea": @[@"eventsinyourarea.com/track/"],
        @"EveryAction": @[@"click.everyaction.com/j/"],
        @"Evite": @[@"pippio.com/api/sync", @"nli.evite.com/imp"],
        @"Expedia": @[@"link.expediamail.com/o/"],
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
        @"FrontApp": @[
            @"app.frontapp.com/(.*)?/seen",
            @"web.frontapp.com/api"
        ],
        @"GearBest": @[@"appinthestore.com/marketing/mail-user-deal/open"],
        @"Gem": @[@"zen.sr/o"],
        @"GetBase": @[@"getbase.com/e1t/o/"],
        @"GetMailSpring": @[@"getmailspring.com/open"],
        @"GetNotify": @[@"email81.com/case"],
        @"GetResponse": @[@"/open.html\\?x="],
        @"GitHub": @[@"github.com/notifications/beacon/"],
        @"Glassdoor": @[@"mail.glassdoor.com/pub/as"],
        @"Gmass": @[
            @"ec2-52-26-194-35.us-west-2.compute.amazonaws.com",
            @"link.gmreg\\d.net",
            @"gmreg\\d.net",
            @"gmtrack.net",
        ],
        @"Gmelius": @[@"gml.email"],
        @"Google": @[
            @"ad.doubleclick.net/ddm/ad",
            @"google-analytics.com/collect",
            @"google.com/appserve/mkt/img/",
            @"notifications.google.com/g/img/(.*).gif",
        ],
        @"Grammarly": @[@"grammarly.com/open"],
        @"Granicus": @[@"govdelivery.com(:d+)?/track"],
        @"GreenMail": @[@"greenmail.co.in"],
        @"GrowthDot": @[@"growthdot.com/api/mail-tracking"],
        @"FreshMail": @[@"//o/(\\w){10,}/(\\w){10,}/"],
        @"Homeaway": @[@"trk.homeaway.com"],
        @"Hubspot": @[
            @"t.(hubspotemail|hubspotfree|signaux|senal|signale|sidekickopen|sigopn|hsmsdd)",
            @"t.strk\\d{2}.email",
            @"track.getsidekick.com",
            @"/e2t/(o|c|to)/",
        ],
        @"Hunter.io": @[@"mltrk.io/pixel"],
        @"iContact": @[@"click.icptrack.com/icp"],
        @"Infusionsoft": @[@"infusionsoft.com/app/emailOpened"],
        @"Insightly": @[@"insgly.net/api/trk"],
        @"Intercom": @[@"via.intercom.io/o", @"intercom-mail[a-zA-Z0-9-.]*.com/(via/)?(o|q)"],
        @"Is-tracking-pixel-api-prod.appspot.com": @[@"is-tracking-pixel-api-prod.appspot.com"],
//        @"JangoMail": @["/[a-z].z\\?[a-z]="],
        @"LaunchBit": @[@"launchbit.com/taz-pixel"],
        @"Lidl": @[@"servicemails.lidl.de/d/d.gif"],
        @"LinkedIn": @[@"linkedin.com/emimp/"],
        @"Litmus": @[@"emltrk.com"],
        @"LogDNA": @[@"ping.answerbook.com"],
        @"Keychron": @[@"keychron.com/_t/open/"],
        @"Klaviyo": @[@"trk.klaviyomail.com"],
        @"Magento": @[
            @"magento.com/trk",
            @"go.rjmetrics.com"
        ],
        @"Mailbutler": @[@"bowtie.mailbutler.io/tracking/hit/(.*)/t.gif"],
        @"Mailcastr": @[@"mailcastr.com/image/"],
        @"Mailchimp": @[@"list-manage.com/track/open.php"],
        @"MailCoral": @[@"mailcoral.com/open"],
        @"Mandrill": @[
            @"mandrill.\\S+/track/open.php",
            @"mandrillapp.com/track"
        ],
        @"Mailgun": @[@"mail.(mailgun|mg).com/o/",],
        @"MailInifinity": @[@"mailinifinity.com/ptrack"],
        @"Mailjet": @[@"mjt.lu/oo", @"links.[a-zA-Z0-9-.]+/oo/"],
        @"Mailspring": @[@"getmailspring.com/open"],
        @"MailTag": @[@"mailtag.io/email-event"],
        @"MailTrack": @[@"mailtrack.io/trace", @"mltrk.io/pixel"],
        @"Mandrill": @[@"mandrill.S+/track/open.php"],
        @"Mailzter": @[@"mailzter.in/ltrack"],
        @"Marketo": @[@"resources.marketo.com/trk"/*, @"/trk\\?t="*/],
        @"Medallia": @[@"survey.medallia.[A-Za-z]{2,3}/\\?(.*)&invite-opened=yes"],
        @"Mention": @[@"mention.com/e/o/"],
        @"MetaData": @[@"metadata.io/e1t/o/"],
        @"MixMax": @[
            @"(email|track).mixmax.com",
            @"mixmax.com/api/track/",
            @"mixmax.com/e/o"
        ],
        @"Mixpanel": @[@"api.mixpanel.com/(trk|track)"],
        @"MyEmma": @[@"e2ma.net/track", @"t.e2ma.net"],
        @"Nation Builder": @[@"nationbuilder.com/r/o"],
        @"NeteCart": @[@"netecart.com/ltrack"],
        @"Netflix": @[@"beaconimages.netflix.net/img/"],
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
            @"[a-zA-Z0-9-.]/e/FooterImages/FooterImage"
        ],
        @"Outreach": @[
            @"app.outreach.io",
            @"outrch.com/api/mailings/opened",
            @"getoutreach.com/api/mailings/opened",
        ],
        @"Patreon": @[@"email.mailgun.patreon.com/o/"],
        @"PayBack": @[@"email.payback.in/a/", @"mail.payback.in/tr/"],
        @"PayPal": @[@"paypal-communication.com/O/", @"t.paypal.com/ts\\?"],
        @"Paytm": @[@"trk.paytmemail.com"],
        @"Peach Aviation": @[
            @"mlapp.flypeach.com/mail/prod/receipt/read.php\\?id=",
            @"mag.flypeach.com/c/.*.gif"
        ],
        @"phpList": @[@"phplist.com/lists/ut.php"],
        @"PipeDrive": @[@"api.nylas.com/open"],
        @"Playdom": @[@"playdom.com/g"],
        @"Polymail": @[@"polymail.io"],
        @"Postmark": @[@"pstmrk.it"],
        @"Product Hunt": @[@"links.producthunt.com/oo/"],
        @"ProlificMail": @[@"prolificmail.com/ltrack"],
        @"Questrade": @[@"email.questrade.com/trk\\?t"],
        @"Quora": @[@"quora.com/qemail/mark_read"],
        @"Rakuten": @[@"r.rakuten.co.jp/(.*).gif\\?mpe=(\\d+)&mpn=(\\d+)", @"cl.rakuten-bank.co.jp/rw/beacon_(.*).gif"],
        @"ReplyCal": @[@"replycal.com/home/index/\\?token"],
        @"ReplyMsg": @[@"replymsg.com"],
        @"Responder.co.il": @[@"opens.responder.co.il"],
        @"Return Path": @[@"returnpath.net/pixel.gif"],
        @"Rewe": @[@"epost.rewe.de/action/view/"],
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
        @"Selligent": @[@"strongview.com/t"],
        @"SendInBlue": @[@"sendibtd.com", @"sendibw{2}.com/track/"],
        @"SendGrid": @[
            @"sendgrid.(net|com)/wf/open",
            @"sendgrid.(net|com)/trk",
            @"sendgrid.(net|com)/mpss/o",
            @"sendgrid.(net|com)/ss/o",
            @"/wf/open\\?upn="
        ],
        @"SendPulse": @[@"stat-pulse.com"],
        @"Sendy": @[@"/sendy/t/"],
        @"Skillsoft": @[@"skillsoft.com/trk"],
        @"Signal": @[@"signl.live/tracker"],
        @"SparkPost": @[
            @"sparkpost.com/q/",
            @"sparkpostmail2.com",
        ],
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
        @"Uber": @[@"click.uber.com/q/"],
        @"Unsplash": @[@"email.unsplash.com/o/"],
        @"Upwork": @[@"email.mg.upwork.com/o/"],
        @"Vcommission": @[@"tracking.vcommission.com"],
        @"Vrbo": @[@"sp.trk.homeaway.com/q/"],
        @"Vtiger": @[@"od2.vtiger.com/shorturl.php"],
        @"Webtrekk": @[@"webtrekk.net"],
        @"WildApricot": @[
            @"wildapricot.com/o/",
            @"wildapricot.org/emailtracker"
        ],
        @"Wish": @[@"wish.com/email-beacon.png"],
        @"Wix": @[@"shoutout.wix.com/.*/pixel"],
        @"WordPress": @[@"pixel.wp.com/t.gif"],
        @"Workona": @[@"workona.com/mk/op/"],
        @"YAMM": @[@"yamm-track.appspot"],
        @"Yesware": @[@"yesware.com/trk", @"yesware.com/t/", @"t.yesware.com"],
        @"Zapier": @[@"opens.zapier.com/q/(.*)/(.*)/(.*)~~"],
        @"Zendesk": @[@"futuresimple.com/api/v1/sprite.png"],
    };
}
@end
