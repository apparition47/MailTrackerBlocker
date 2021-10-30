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

NSString * const kGenericSpyPixelRegex = @"<img[^>]+(width\\s*=[\"'\\s]*[01]p?x?[\"'\\s]|[^-]width:\\s*[01]px)+[^>]*>";
NSString * const kImgTagTemplateRegex = @"<img[^>]+%@+[^>]*>";

@synthesize trackers, delegate;

- (id)init {
    if( self = [super init]) {
        trackers = [[NSMutableSet alloc] init];
    }
    return self;
}

- (id)initWithHtml:(NSString*)html {
    self = [self init];
    if (!self) {
        return nil;
    }
    
    _sanitizedHtml = [self sanitizedHtmlFromHtml: html];
    return self;
}

- (id)initWithHtml:(NSString*)html from:(NSString*)from subject:(NSString*)subject deeplink:(NSString*)deeplink {
    self = [self init];
    if (!self) {
        return nil;
    }
    _sanitizedHtml = [self sanitizedHtmlFromHtml: html];
    _deeplinkField = deeplink;
    _fromField = from;
    _subjectField = subject;
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
    
    // img tags
    NSString *result = html;
    NSDictionary *trackingDict = [self getTrackerDict];
    for (id trackingSourceKey in trackingDict) {
        for (NSString *trkRegexStr in [trackingDict objectForKey:trackingSourceKey]) {
            NSString *regexStr = [NSString stringWithFormat:kImgTagTemplateRegex, trkRegexStr];
            NSRange matchedRange = [result rangeFromPattern:regexStr];
            if (matchedRange.location != NSNotFound) {
                [trackers addObject:trackingSourceKey];
                result = [result stringByReplacingCharactersInRange:matchedRange withString:@""];
            }
        }
    }
    
    // strip additional CSS tracker
    NSString * const kCSSTemplateRegex = @"background-image:\\s?url\\([\'\"][\\w:./]*%@[\\w:./\\?=]*[\'\"]\\)";
    NSString *regexStr = [NSString stringWithFormat:kCSSTemplateRegex, [[trackingDict valueForKey:@"Email on Acid"] firstObject]];
    NSRange matchedRange = [result rangeFromPattern:regexStr];
    while (matchedRange.location != NSNotFound) {
        result = [result stringByReplacingCharactersInRange:matchedRange withString:@""];
        matchedRange = [result rangeFromPattern:regexStr];
    }
    
    // strip generic pixels
    NSUInteger originalLength = [result length];
    result = [self replacedGenericPixelsFrom:result];
    _matchedGeneric = originalLength != [result length];

    return result;
}

// replaces generic pixels but skips spacers
// https://stackoverflow.com/questions/6222115/how-do-you-use-nsregularexpressions-replacementstringforresultinstringoffset
- (NSString*)replacedGenericPixelsFrom:(NSString*)html {
    NSError* error = NULL;
    NSRegularExpression* regex = [NSRegularExpression
                                  regularExpressionWithPattern:kGenericSpyPixelRegex
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&error];

    NSMutableString *mutableString = [html mutableCopy];
    NSInteger offset = 0;
    for (NSTextCheckingResult* result in [regex matchesInString:html
                                                        options:0
                                                          range:NSMakeRange(0, [html length])]) {

        NSRange resultRange = [result range];
        resultRange.location += offset;

        // template $0 is replaced by the match
        NSString* match = [regex replacementStringForResult:result
                                                   inString:mutableString
                                                     offset:offset
                                                   template:@"$0"];
        
        NSString* replacement;
        if ([match containsString:@"spacer.gif"]) {
            continue; // no replacement
        } else {
            replacement = @"";
        }

        [mutableString replaceCharactersInRange:resultRange withString:replacement];
        offset += ([replacement length] - resultRange.length);
    }

    // return original reference if nothing changed
    if ([mutableString length] == [html length] && [mutableString isEqualToString:html]) {
        return html;
    }
    
    return mutableString;
}

- (NSDictionary*)getTrackerDict {
    return @{
        @"1&1": @[@"simg.1und1.de"],
        @"365offers.trade": @[@"trk.365offers.trade"],
        @"3hands": @[@"mi.pbz.jp/"],
        @"4Cite": @[@"/\\?sv_cid=\\d+_\\d+&sv_emopen=true&sv_sveme=\\w+"],
        @"ActiveCampaign": @[@"/lt.php\\?.*l=open"],
        @"Act-On": @[@"actonsoftware.com"],
        @"Acoustic": @[
            @"open.mkt\\d{2,3}.net/open/log/",
            @"mkt\\d{3,4,5}.com/open",
            @"/eos/v1/\\w{232}",
        ],
        @"ADAC": @[@"mailing.adac.de/tr/"],
        @"AdComplete": @[@"/banman.asp\\?"],
        @"Adtriba": @[@"d.adtriba.com"],
        @"Adobe": @[
            @"/trk\\?t=1&mid=", // Marketo
            @"/r/\\?id=\\w+,\\w+,1",
            @"demdex.net",
            @"t.info.adobesystems.com",
            @"toutapp.com",
            @"112.2o7.net",
            @"postoffice.adobe.com/po-server/link/open"
        ],
        @"AgileCRM": @[@"agle2.me/open"],
        @"Air Miles": @[@"email.airmiles.ca/O"],
        @"Aislelabs": @[@"app.aislelabs.com/o/emailv3/emailv3onepixel.jsp"],
        @"Alaska Airlines": @[
            @"click.points-mail.com/open",
            @"sjv.io/i/",
            @"gqco.net/i/",
        ],
        @"Alida": @[@"www.aaacrossroads.com/c/static_images/.*.png1"], // formerly Vision Critical
        @"Amazon": @[@"sellercentral(-europe|-japan|)?.amazon.(com|co.uk|com.au|sg|in|com.tr|ae|com.br)/nms/img/"],
        @"Amazon SES": @[
            @".r.(us-east-2|us-east-1|us-west-2|ap-south-1|ap-northeast-2|ap-southeast-1|ap-southeast-2|ap-northeast-1|ca-central-1|eu-central-1|eu-west-1|eu-west-2|sa-east-1|us-gov-west-1).awstrack.me/I0/\\w{16}-\\w{8}-\\w{4}",
            @"aws-track-email-open",
            @"/gp/r.html",
            @"/gp/forum/email/tracking",
            @"amazonappservices.com/trk",
            @"amazonappservices.com/r/",
            @"awscloud.com/trk",
            @"/CI0/(\\w|-){60}/(\\w|-){43}=\\d{3}"
        ],
        @"Amobee": @[@"d.turn.com/r/"],
        @"Apo.com": @[@"info.apo.com/op/\\d+/.+.gif"],
        @"Apple": @[
          @"apple.com/report/2/its_mail_sf",
          @"apple_email_link/spacer",
        ],
        @"Appriver": @[@"appriver.com/e1t/o/"],
        @"Apptivo": @[@"apptivo.com"],
        @"Artegic": @[@"elaine-asp.de"],
        @"Asana": @[@"app.asana.com/-/open"],
        @"ASUSTeK": @[@"emditpison.asus.com"],
        @"Atlassian": @[
            @"i.trellomail.com/e/eo",
            @"bitbucket.org/account/notifications/mark-read/"
        ],
        @"AT&T": @[@"clicks.att.com/OCT/eTrac\\?EMAIL_ID=\\d+&amp;src="],
        @"Aurea": @[ // Lyris
            @"/db/.*/.*/1.gif",
        ],
        @"Autopilot": @[@"autopilotmail\\d?.io"],
        @"AWeber": @[@"openrate.aweber.com"],
        @"Bananatag": @[@"bl-1.com"],
        @"Bison": @[@"clicks.bisonapp.com"],
        @"Bandsintown": @[@"px1.bandsintown.com/.+.gif"],
        @"Blackbaud": @[@"support.planetary.org/site/PixelServer"],
        @"Blueshift.com": @[
            @"getblueshift.com/track"
        ],
        @"Bombcom": @[@"bixel.io"],
        @"Boomerang": @[@"mailstat.us/tr"],
        @"Boots": @[@"boots.com/rts/open.aspx"],
        @"Boxbe": @[@"boxbe.com/stfopen"],
        @"Browserstack": @[@"browserstack.com/images/mail/track-open"],
        @"BuzzStream": @[@"tx.buzzstream.com"],
        @"Campaign Monitor": @[
            @"cmail\\d{1,2}.com/t/.+.gif",
            @"createsend\\d+.com/.+.gif"
        ],
        @"CanaryMail": @[@"canarymail.io(:\\d+)?/track", @"pardot.com/r/"],
        @"Cheetah Digital": @[@"/rts/open.aspx\\?tp="],
        @"CircleCI": @[@"https://email.circleci.com/o/"],
        @"Cirrus Insight": @[@"tracking.cirrusinsight.com"],
        @"ClickMeter": @[@"pixel.watch/"],
        @"Clio": @[@"app.clio.com/tracking_pixel"],
        @"Close": @[@"close.(io|com)/email_opened", @"dripemail2"],
        @"cloudHQ": @[@"cloudhq.io/mail_track", @"cloudhq-mkt(d).net/mail_track"],
        @"Coda": @[@"coda.io/logging/ping"],
        @"ConneQuityMailer": @[@"connequitymailer.com/open/"],
        @"Conrad": @[@"aktuell.conrad.de/g.html"],
        @"Constant Contact": @[@"rs6.net/on.jsp"],
        @"ContactMonkey": @[@"contactmonkey.com/api/v1/tracker"],
        @"ConvertKit": @[
            @"convertkit-mail.com/o/",
            @"open.convertkit-mail2.com/[a-z0-9]{20}"
        ],
        @"Copper": @[@"prosperworks.com/tp/t"],
        @"Cprpt": @[@"/o.aspx\\?t="],
        @"Creditmantri.com": @[@"mailer.creditmantri.com/t/"],
        @"Critical Impact": @[@"portal.criticalimpact.com/c2/"],
        @"Customer.io": @[
            @"customeriomail.com/e/o",
            @"track.customer.io/e/o",
            @"/e/o/[a-zA-Z0-9]{63}",
        ],
        @"Dating Profits": @[@"click.xnxxinc.com/campaign/track-email/"],
        @"DidTheyReadIt": @[@"xpostmail.com"],
        @"DocuMatix": @[@"enews.itcu.org/op\\?m="],
        @"DotDigital": @[@"trackedlink.net", @"dmtrk.net", @"email.syntricate.com.au"],
        @"Driftem": @[@"driftem.com/ltrack"],
        @"Drop": @[@"pixel.massdrop.com/open/pixel.gif"],
        @"Dropbox": @[@"dropbox.com/l/"],
        @"Dyson": @[@"tracking.dyson.com/t/"], //.*?k=.*&m=.*&c=
        @"Ebsta": @[@"console.ebsta.com", @"ebsta.gif", @"ebsta.com/r/"],
        @"EdgeSuite": @[@"epidm.edgesuite.net"],
        @"Email on Acid": @[@"eoapxl.com"],
        @"EmailTracker.website": @[@"my-email-signature.link"],
        @"Emarsys": @[@"emarsys.com/e2t/o/"],
        @"EmberPoint MailPublisher": @[@"rec.mpse.jp/(.*)/rw/beacon_"],
        @"Epic Games": @[@"accts.epicgames.com/O/"],
        @"Epsilon Interactive": @[
            @"epslocalmail.com/O/",
            @"ind.dell.com"
        ],
        @"eSputnik": @[@"esputnik.com/repository/applications/commons/hidden.png"],
        @"Etransmail": @[@"ftrans03.com/linktrack/"],
        @"EventBrite": @[@"eventbrite.com/emails/action"],
        @"EventsInYourArea": @[@"eventsinyourarea.com/track/"],
        @"EveryAction": @[@"click.everyaction.com/j/"],
        @"Evite": @[@"pippio.com/api/sync", @"nli.evite.com/imp"],
        @"Expedia": @[@"link.expediamail.com/o/"],
        @"Facebook": @[
            @"facebook.com/aymt/aa/",
            @"facebook.com/email_open_log_pic.php",
            @"facebookdevelopers.com/trk",
            @"fb.com/trk",
        ],
        @"Fastic": @[@"/e/eo\\?_t=[^>]+_m=[^>]+_e="],
        @"Flatastic": @[@"api.flatastic-app.com/index.php/img"],
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
        @"Gmass": @[
            @"ec2-52-26-194-35.us-west-2.compute.amazonaws.com",
            @"link.gmreg\\d.net",
            @"gmreg\\d.net",
            @"gmtrack.net",
        ],
        @"Gmelius": @[@"gml.email"],
        @"GoDaddy": @[@"email.cloud.secureclick.net/view\\?"],
        @"Google": @[
            @"ad.doubleclick.net/ddm/ad",
            @"google-analytics.com/collect",
            @"google.com/appserve/mkt/img/",
            @"notifications.google.com/g/img/(.*).gif",
        ],
        @"Grammarly": @[@"grammarly.com/open"],
        @"Granicus": @[@"govdelivery.com(:\\d+)?/track"],
        @"GreenMail": @[@"greenmail.co.in"],
        @"Groupon": @[@"groupon.com/analytic/track.gif\\?"],
        @"GrowthDot": @[@"growthdot.com/api/mail-tracking"],
        @"Higher Logic": @[@"arrl.informz.net/z/\\w+/image.gif"],
        @"Homeaway": @[@"trk.homeaway.com"],
        @"HubSpot": @[
            @"t.(hubspotemail|hubspotfree|signaux|senal|signale|sidekickopen|sigopn|hsmsdd)",
            @"t.strk\\d{2}.email",
            @"track.getsidekick.com",
            @"/e2t/(o|c|to)/",
            @"/e3t/Bto/"
        ],
        @"Hunter.io": @[@"mltrk.io/pixel"],
        @"iContact": @[@"click.icptrack.com/icp"],
        @"Infusionsoft": @[@"infusionsoft.com/app/emailOpened"],
        @"Integral Ad Science": @[@"pixel.adsafeprotected.com"],
        @"Intercom": @[@"via.intercom.io/o", @"intercom-mail[a-zA-Z0-9-.]*.com/(via/)?(o|q)"],
        @"Is-tracking-pixel-api-prod.appspot.com": @[@"is-tracking-pixel-api-prod.appspot.com"],
//        @"JangoMail": @["/[a-z].z\\?[a-z]="],
        @"LaunchBit": @[@"launchbit.com/taz-pixel"],
        @"Lidl": @[@"servicemails.lidl.de/d/d.gif"],
        @"LinkedIn": @[@"linkedin.com/emimp/", @"help.linkedin.com/rd/"],
        @"Litmus": @[@"emltrk.com"],
        @"LiveIntent": @[@"/imp\\?s=\\d{6}&li="], // imp?s=&li=&e=&p=&stpe= // imp?s=&li=&m=&p=
        @"LogDNA": @[@"ping.answerbook.com"],
        @"Keychron": @[@"keychron.com/_t/open/"],
        @"Klaviyo": @[@"trk.klaviyomail.com"],
        @"Magento": @[
            @"magento.com/trk",
            @"go.rjmetrics.com"
        ],
        @"Mailbird": @[@"tracking.getmailbird.com/OpenTrackingPixel/"],
        @"Mailbutler": @[@"bowtie.mailbutler.io/tracking/hit/(.*)/t.gif"],
        @"Mailcastr": @[@"mailcastr.com/image/"],
        @"Mailchimp": @[
            @"list-manage.com/track/open.php",
            @"us\\d+.mailchimp.com/mctx/opens",
            @"/track/open.php\\?u=",
        ],
        @"MailCoral": @[@"mailcoral.com/open"],
        @"MailerLite": @[@"click.mlsend.com/link/o/"],
        @"Mailgun": @[@"/o/eJ"],
        @"MailInifinity": @[@"mailinifinity.com/ptrack"],
        @"Mailjet": @[@"mjt.lu/oo", @"links.[a-zA-Z0-9-.]+/oo/"],
        @"Mailspring": @[@"getmailspring.com/open"],
        @"MailTag": @[@"mailtag.io/email-event"],
        @"MailTrack": @[@"mailtrack.io/trace", @"mltrk.io/pixel"],
        @"Mailzter": @[@"mailzter.in/ltrack"],
        @"Maropost": @[@"links.myrideshop.com/a/"],
        @"Medallia": @[@"survey\\d?.medallia.[A-Za-z]{2,3}/\\?\\w+&invite-opened=yes"],
        @"Mention": @[@"mention.com/e/o/"],
        @"MetaData": @[@"metadata.io/e1t/o/"],
        @"Microsoft": @[
            @"svc.dynamics.com/t/i/", // Dynamics 365
            @"mucp.api.account.microsoft.com",
            @"gridinbound.blob.core.windows.net"
        ],
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
        @"Neustar": @[@"/emailprefs/images/\\w+/\\d+/\\d"],
        @"Newegg": @[@"newegg.com/mr/\\w{32}/\\w{96}.gif"],
        @"NewtonHQ": @[@"tr.cloudmagic.com"],
        @"NTT": @[@"club-ntt-west.com/cn-w/cmn/img/1.png"],
        @"Omnisend": @[@"/track/.*/.*\\?signature="],
        @"OpenBracket": @[@"openbracket.co/track"],
        @"Opicle": @[@"track.opicle.com"],
        @"Oracle": @[
            @"tags.bluekai.com/site", // Bluekai
            @"en25.com/e/",
            @"dynect.net/trk.php",
            @"bm5150.com/t/",
            @"bm23.com/t/",
            @"/pub/as\\?_ri_=.*&_ei_=", // Responsys
            @"[a-zA-Z0-9-.]/e/FooterImages/FooterImage"
        ],
        @"OutMaster": @[@"outmaster.co/mailer/index.php/campaigns/"],
        @"Outreach": @[
            @"app.outreach.io",
            @"outrch.com/api/mailings/opened",
            @"getoutreach.com/api/mailings/opened",
            @"a.science-recruiting.com/api/mailings/opened"
        ],
        @"PayBack": @[@"email.payback.in/a/", @"mail.payback.in/tr/"],
        @"PayPal": @[@"paypal-communication.com/O/", @"t.paypal.com/ts\\?"],
        @"Paytm": @[@"trk.paytmemail.com"],
        @"Peach Aviation": @[
            @"mlapp.flypeach.com/mail/prod/receipt/read.php\\?id=",
            @"mag.flypeach.com/c/.*.gif" // Cuenote
        ],
        @"PersistIQ": @[@"infinite-stream-5194.herokuapp.com/pixel"],
        @"phpList": @[@"phplist.com/lists/ut.php"],
        @"PipeDrive": @[@"api.nylas.com/open"],
        @"Playdom": @[@"playdom.com/g"],
        @"Polymail": @[@"polymail.io/v2/z/|share.polymail.io"],
        @"Postmark": @[@"pstmrk.it"],
        @"Product Hunt": @[@"links.producthunt.com/oo/"],
        @"ProlificMail": @[@"prolificmail.com/ltrack"],
        @"Qualtrics": @[@"/WRQualtricsContacts/Watermark.php"],
        @"Quora": @[@"quora.com/qemail/mark_read"],
        @"Rakuten": @[
            @"r.rakuten.co.jp/(.*).gif\\?mpe=(\\d+)",
            @"cl.rakuten-bank.co.jp/rw/beacon_(.*).gif"
        ],
        @"ReplyCal": @[@"replycal.com/home/index/\\?token"],
        @"ReplyMsg": @[@"replymsg.com"],
        @"Responder.co.il": @[@"opens.responder.co.il"],
        @"Return Path": @[@"returnpath.net/pixel.gif"],
        @"Rewe": @[@"epost.rewe.de/action/view/"],
        @"Rocketbolt": @[@"email.rocketbolt.com/o/"],
        @"Runtastic": @[@"runtastic.com/mo/"],
        @"Sailthru": @[
            @"sailthru.com/trk",
            @"link.axios.com/img/.*.gif"
        ],
        @"Salesforce": @[ // ExactTarget
            @"salesforceiq.com/t.png",
            @"beacon.krxd.net",
            @"app.relateiq.com/t.png",
            @"nova.collect.igodigital.com",
            @"exct.net/open.aspx",
            @"click.*./open.aspx\\?"
        ],
        @"SalesHandy": @[@"saleshandy.com/web/email/countopened"],
        @"SalesLoft": @[@"salesloft.com/email_trackers"],
        @"Segment": @[ // Twilio
            @"api.segment.io/v1/pixel/track",
            @"email.segment.com/e/o/"
        ],
        @"Selligent": @[
            @"strongview.com/t",
            @"emsecure.net",
            @"selligent.com",
            @"slgnt.(eu|us)"
        ],
        @"Sendinblue": @[
            @"sendibtd.com",
            @"sendibw{2}.com/track/",
            @"amxe.net/\\S+.gif", // formerly Newsletter2Go
            @"/[a-z]{2}/op/",
        ],
        @"SendGrid": @[
//            @"ablink.hello.wyze.com/ss/o/",
//            @"ablink.marketing.li.me", @"ablink.rider.li.me",
//            @"ablink.mail.free-now.com",
//            @"ablink.email.etsy.com",
//            @"ablink.comms.trainline.com",
//            @"ablink.emails.just-eat.co.uk",
//            @"ablink.mail.delosdestinations.com",
//            @"ablink.m1.cratejoy.com",
            @"/ss/o/.*.gif",
            @"sendgrid.(net|com)/wf/open",
            @"sendgrid.(net|com)/trk",
            @"sendgrid.(net|com)/mpss/o",
            @"sendgrid.(net|com)/ss/o",
            @"/wf/open\\?upn="
        ],
        @"SendPulse": @[@"stat-pulse.com"],
        @"Sendy": @[@"/sendy/t/"],
        @"Shopify": @[@"/tools/emails/open/"],
        @"Signal": @[@"signl.live/tracker"],
        @"Smore": @[@"smore.com/app/reporting/pixel/"],
        @"SparkPost": @[
//            @"mailer.codepen.io/q",
//            @"sptrack.trello.com/q/",
//            @"track.sp.actionkit.com/q/",
//            @"click.email.active.com/q/",
//            @"x.getclockwise.com/q/",
//            @"t.drop.com/q/",
//            @"sp.trk.homeaway.com/q/",
//            @"click.uber.com/q/",
//            @"opens.zapier.com/q/",
//            @"sparkpost.com/q/",
//            @"go.sparkpostmail.com/q/"
//            @"post.spmailtechno.com/q/",
            @"sparkpostmail2.com",
            @"/q/.*~~/.*~/",
        ],
        @"Streak": @[@"mailfoogae.appspot.com"],
        @"Substack": @[@"substack.com/o/"],
        @"Superhuman": @[@"r.superhuman.com"],
        @"TataDocomoBusiness": @[@"tatadocomobusiness.com/rts/"],
        @"Techgig": @[@"tj_mailer_opened_count_all.php"],
        @"The Atlantic": @[
            @"links.e.theatlantic.com/open/log/",
            @"data-cdn.theatlantic.com/email.gif"
        ],
        @"The Chronicle of Higher Education": @[@"d2uowlhdj52lqx.cloudfront.net/emailbeacon.png"],
        @"TheTopInbox": @[@"thetopinbox.com/track/"],
        @"The Washington Post": @[@"palomaimages.washingtonpost.com/pr2/\\w{32}-beacon-\\d-\\d-\\d{1,2}-\\d"],
        @"Thunderhead": @[@"na5.thunderhead.com"],
        @"Tinyletter": @[@"tinyletterapp.com.*\\?open.gif/"],
        @"ToutApp": @[@"go.toutapp.com"],
        @"Track": @[
            @"trackapp.io/(b|r)/",
            @"trackapp.io/static/img/track.gif"
        ],
        @"Transferwise": @[@"links.transferwise.com/track/"],
        @"Twitch": @[@"spade.twitch.tv/track"],
        @"Twitter": @[@"twitter.com/scribe/ibis"],
        @"UNiDAYS": @[@"links\\d?.m.myunidays.com"],
        @"Unsplash": @[@"email.unsplash.com/o/"],
        @"Upland PostUp": @[@"efeedbacktrk.com/.*.gif"],
        @"Validity": @[@"pixel.app.returnpath.net/pixel.gif"],
        @"Vcommission": @[@"tracking.vcommission.com"],
        @"Verizon": @[@"verizon.com/econtact/ecrm/EmailTracking.serv"],
        @"Vice Media": @[@"rs-stripe.refinery29.com/stripe/image"],
        @"Vtiger": @[@"od2.vtiger.com/shorturl.php"],
        @"WhatCounts": @[@"whatcounts.com/t"],
        @"We Are Web": @[@"tracking.weareweb.in/index.php/campaigns/"],
        @"Webtrekk": @[@"webtrekk.net"],
        @"WildApricot": @[
            @"wildapricot.com/o/",
            @"wildapricot.org/emailtracker"
        ],
        @"Wish": @[@"wish.com/email-beacon.png"],
        @"Wix": @[@"shoutout.wix.com/.*/pixel"],
        @"WordPress": @[@"pixel.wp.com/t.gif"],
        @"Yahoo!": @[@"a.analytics.yahoo.com/p.pl"],
        @"Yahoo! Japan": @[@"dsb.yahoo.co.jp/api/v1/clear.gif"],
        @"YAMM": @[@"yamm-track.appspot"],
        @"Yesware": @[@"yesware.com/trk", @"yesware.com/t/", @"t.yesware.com"],
        @"Zendesk": @[@"futuresimple.com/api/v1/sprite.png"],
        @"Zeta Global": @[@"e.newsletters.cnn.com/open/"],
        @"Zoho": @[
            @"/clicks/.*/.*/open.gif",
            @"sender\\d.zohoinsights-crm.com/ocimage/"
        ],
    };
}
@end
