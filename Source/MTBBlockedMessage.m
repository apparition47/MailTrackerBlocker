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
@property (nonatomic, retain) NSSet *trackers;
@property BOOL matchedGeneric;
@property (nonatomic, weak) id <MTBBlockedMessageDelegate> delegate;
+ (NSRegularExpression*)imgTagRegex;
+ (NSRegularExpression*)genericPixelRegex;
+ (NSRegularExpression*)cssRegex;
@end

@implementation MTBBlockedMessage

NSString * const kGenericSpyPixelRegex = @"<img[^>]+(width\\s*=[\"'\\s]*[01]p?x?[\"'\\s]|[^-]width:\\s*[01]px)+[^>]*>";
NSString * const kImgTagTemplateRegex = @"<img[^>]*>";
NSString * const kCSSTemplateRegex = @"(background-image|content):\\s?url\\([\'\"]?[\\w:&./\?=~-]+[\'\"]?\\)";

@synthesize trackers, delegate;

- (id)init {
    if( self = [super init]) {
        trackers = [[NSSet alloc] init];
        _isBlockingEnabled = YES;
        _knownTrackerCount = 0;
    }
    return self;
}

- (id)initWithHtml:(NSString*)html {
    self = [self init];
    if (!self) {
        return nil;
    }
    _originalHtml = html;
    _sanitizedHtml = [self sanitizedHtmlFromHtml: html];
    return self;
}

- (id)initWithHtml:(NSString*)html to:(NSString*)to from:(NSString*)from subject:(NSString*)subject deeplink:(NSString*)deeplink {
    self = [self init];
    if (!self) {
        return nil;
    }
    _originalHtml = html;
    _sanitizedHtml = [self sanitizedHtmlFromHtml: html];
    _deeplinkField = deeplink;
    _toField = to;
    _fromField = from;
    _subjectField = subject;
    return self;
}

- (NSString *)detectedTracker {
    return [trackers anyObject];
}

- (NSSet *)detectedTrackers {
    return trackers;
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

#pragma mark - Cache
+ (NSRegularExpression*)imgTagRegex {
    static NSRegularExpression *regex = nil;
    if (regex == nil) {
        regex = [NSRegularExpression regularExpressionWithPattern:kImgTagTemplateRegex options:NSRegularExpressionCaseInsensitive error:nil];
    }
    return regex;
}

+ (NSRegularExpression*)genericPixelRegex {
    static NSRegularExpression *regex = nil;
    if (regex == nil) {
        regex = [NSRegularExpression
                 regularExpressionWithPattern:kGenericSpyPixelRegex
                 options:NSRegularExpressionCaseInsensitive
                 error:nil];
    }
    return regex;
}

+ (NSRegularExpression*)cssRegex {
    static NSRegularExpression *regex = nil;
    if (regex == nil) {
        regex = [NSRegularExpression regularExpressionWithPattern:kCSSTemplateRegex options:NSRegularExpressionCaseInsensitive error:nil];
    }
    return regex;
}

#pragma mark - Helpers
- (NSString*)sanitizedHtmlFromHtml:(NSString*)html {
    if (!html) {
        return nil;
    }
    
    // img tags
    NSString *result = html;
    NSMutableArray *trackerTemp = [@[] mutableCopy];
    NSDictionary *trackingDict = [[self class] getTrackerDict];

    NSArray *tcResults = [[[self class] imgTagRegex] matchesInString:result options:0 range:NSMakeRange(0, result.length)];
    for (NSTextCheckingResult *tcResult in [tcResults reverseObjectEnumerator]) {
        bool hasParsedTag = false;
        if (tcResult.range.location == NSNotFound) {
            continue;
        }
        // named trackers
        for (id vendor in trackingDict) {
            for (NSString *rule in [trackingDict objectForKey:vendor]) {
                NSRange matchedRange = [result matchedRange:tcResult.range from:rule];
                if (matchedRange.location != NSNotFound) {
                    [trackerTemp addObject:vendor];
                    result = [result stringByReplacingCharactersInRange:tcResult.range withString:@""];
                    _knownTrackerCount++;
                    hasParsedTag = true;
                    goto outer;
                }
            }
        }
        outer:
        if (hasParsedTag) {
            continue;
        }
        
        // generic trackers
        for (NSTextCheckingResult *genericResult in [[[self class] genericPixelRegex] matchesInString:html options:0 range:tcResult.range]) {
            if (genericResult.range.location != NSNotFound) {
                
                // avoid false-positive spacer images
                NSString *spacersRegexStr = @"cid:|spacer|attachments.office.net/owa/|fedex_collective_logo_|apple_logo_web|sidebar-gradient|transparent.gif";
                NSRange matchedRange = [result matchedRange:tcResult.range from:spacersRegexStr];
                if (matchedRange.location == NSNotFound) {
                    _knownTrackerCount++;
                    _matchedGeneric = true;
                    result = [result stringByReplacingCharactersInRange:genericResult.range withString:@""];
                }
                hasParsedTag = true;
            }
        }
        if (hasParsedTag) {
            continue;
        }
        
        #ifndef CONTENT_BLOCKER
        // strip non-tracking static ad content
        NSArray *staticContentDict = @[
            @"/branding/recommend/short.png", // Jeeng
            @"nl-static1.komando.com/wp-content/uploads/ad-"
        ];
        for (NSString *staticRegexStr in staticContentDict) {
            NSRange matchedRange = [result matchedRange:tcResult.range from:staticRegexStr];
            if (matchedRange.location != NSNotFound) {
                result = [result stringByReplacingCharactersInRange:matchedRange withString:@""];
                hasParsedTag = true;
            }
        }
        #endif
    }
    trackers = [NSSet setWithArray: trackerTemp];
    
    #ifndef CONTENT_BLOCKER
    // strip additional CSS tracker
    // doesn't add to trackers since it picked up as img above
    NSArray *cssTrackingDict = @[
        [[trackingDict valueForKey:@"Email on Acid"] firstObject],
        [[trackingDict valueForKey:@"Litmus"] firstObject],
        [[trackingDict valueForKey:@"Escalent"] firstObject],
        [[trackingDict valueForKey:@"G-Lock Analytics"] firstObject]
    ];
    tcResults = [[[self class] cssRegex] matchesInString:result options:0 range:NSMakeRange(0, result.length)];
    for (NSTextCheckingResult *tcResult in [tcResults reverseObjectEnumerator]) {
        if (tcResult.range.location == NSNotFound) {
            continue;
        }
        for (NSString *rule in cssTrackingDict) {
            NSRange matchedRange = [result matchedRange:tcResult.range from:rule];
            if (matchedRange.location != NSNotFound) {
                result = [result stringByReplacingCharactersInRange:tcResult.range withString:@""];
                _knownTrackerCount++;
                break;
            }
        }
    }
    #endif

    return result;
}

// Safari Content Blocker-style regex rules
// To validate, check Console.app for these errors:
// Error occured while compiling rule list for identifier:<bundle id> error:Error Domain=WKErrorDomain Code=6 "(null)" UserInfo={NSHelpAnchor=Rule list compilation failed: Invalid or unsupported regular expression.}
// Rule list identifier:<bundle id> was not added to active the rule list
+ (NSDictionary*)getTrackerDict {
    return @{
        @"1&1": @[
            @"simg.1und1.de",
            @"oc.ionos.com/\\?utm_rid=",
            @"t.ionos.com/oms_p/"
        ],
        @"365offers.trade": @[@"trk.365offers.trade"],
        @"3hands": @[@"mi.pbz.jp/"],
        @"4Cite": @[@"/\\?sv_cid="],
        @"ActiveCampaign": @[
            @"/lt.php\\?",
            @"/Prod/link-tracker\\?nl="
        ],
        @"Act-On": @[@"actonsoftware.com"],
        @"activecore": @[@"h-cast.jp/mail_open"],
        @"Acoustic": @[
            @"/open/log/",
            @"mkt[0-9]+.com/open",
            @"/eos/v1/[a-z0-9_]+",
        ],
        @"ADAC": @[@"mailing.adac.de/tr/"],
        @"AdComplete": @[@"/banman.asp\\?"],
        @"Adtriba": @[@"d.adtriba.com"],
        @"Adobe": @[
            @"/trk\\?t=1&mid=", // Marketo
            @"/r/\\?id=[a-z0-9_]+,[a-z0-9_]+,1",
            @"demdex.net",
            @"t.info.adobesystems.com",
            @"toutapp.com",
            @"112.2o7.net",
            @"/ee/v1/open", // adobe experience cloud
            @"postoffice.adobe.com/po-server/link/open"
        ],
        @"AgileCRM": @[@"agle2.me/open"],
        @"Agoda": @[@"xml.agoda.com/EmailTracking/api/emailtracking/Open"],
        @"Air Miles": @[@"email.airmiles.ca/O"],
        @"Aislelabs": @[@"app.aislelabs.com/o/emailv3/emailv3onepixel.jsp"],
        @"Alaska Airlines": @[
            @"click.points-mail.com/open",
            @"sjv.io/i/",
            @"gqco.net/i/",
        ],
        @"Alibaba": @[@"ae.mmstat.com/ae.edm.edm_open"],
        @"Alida": @[@".png1"], // formerly Vision Critical
        @"All Nippon Airways": @[@"amc.ana.co.jp/bin/checker"],
        @"Amazon": @[@"sellercentral(-europe)?(-japan)?.amazon.+/nms/img/"],
        @"Amazon SES": @[
            @".awstrack.me/I0/",
            @"aws-track-email-open",
            @"/gp/r.html",
            @"/gp/forum/email/tracking",
            @"amazonappservices.com/trk",
            @"amazonappservices.com/r/",
            @"awscloud.com/trk",
            @"/CI0/.+/.+=[0-9][0-9][0-9]"
        ],
        @"Amobee": @[@"d.turn.com/r/"],
        @"Apo.com": @[@"info.apo.com/op/"],
        @"Apple": @[
          @"apple.com/report/2/its_mail_sf",
          @"apple_email_link/spacer",
        ],
        @"Appriver": @[@"appriver.com/e1t/o/"],
        @"Apptivo": @[@"apptivo.com"],
        @"Artegic": @[@"elaine-asp.de"],
        @"Asana": @[@"app.asana.com/-/open"],
        @"Ashby": @[@"app.ashbyhq.com/api/beacon/email-read/"],
        @"ASUSTeK": @[@"emditpison.asus.com"],
        @"Atlassian": @[
            @"i.trellomail.com/e/eo",
            @"bitbucket.org/account/notifications/mark-read/"
        ],
        @"AT&T": @[@"clicks.att.com/OCT/eTrac\\?EMAIL_ID="],
        @"AutoAlert": @[
            @"dealer.autoalert.com/email/tracking/open",
            @"fzlnk.com/AutoAlertEmailHandler.ashx"
        ],
        @"Aurea": @[ // Lyris
            @"/1.gif",
        ],
        @"Autopilot": @[@"autopilotmail[0-9]?.io"],
        @"AWeber": @[@"openrate.aweber.com"],
        @"Backpack Internet": @[
            @"app.bentonow.com/ahoy/messages/",
            @"track.bentonow.com/tracking/emails/"
        ],
        @"Bananatag": @[@"bl-1.com"],
        @"Bazaarvoice": @[@"bazaarvoice.com/a.gif"],
        @"Bison": @[@"clicks.bisonapp.com"],
        @"Bandsintown": @[@"px1.bandsintown.com"],
        @"beehiiv": @[@"/ss/o/[a-zA-Z0-9_.]+/[a-z0-9][a-z0-9][a-z0-9]/[a-zA-Z0-9_.-]+/ho.gif"],
        @"Benchmark Email": @[@"bmetrack.com/c/o"],
        @"Blackbaud": @[
            @"support.planetary.org/site/PixelServer",
            @"/smtp.mailopen\\?id=" // not 100% sure
        ],
        @"Bloomreach": @[@"cdn.us1.exponea.com/.+/open"],
        @"Blueshift.com": @[
            @"getblueshift.com/track"
        ],
        @"British Airways": @[@"britishairways.com/cms/global/assets/images/global/email_images/structural/primary1px.gif"],
        @"Bombcom": @[@"bixel.io"],
        @"Boomerang": @[@"mailstat.us/tr"],
        @"Boots": @[@"boots.com/rts/open.aspx"],
        @"Boxbe": @[@"boxbe.com/stfopen"],
        @"Browserstack": @[@"browserstack.com/images/mail/track-open"],
        @"BuzzStream": @[@"tx.buzzstream.com"],
        @"Campaign Monitor": @[
            @"cmail[0-9][0-9]?.com/t/",
            @"createsend[0-9]+.com"
        ],
        @"Campaigner": @[@"trk.cp20.com/open/"],
        @"CanaryMail": @[@"receipts.canarymail.io(:[0-9]+)?/track/"],
        @"Cheetah Digital": @[@"/rts/open.aspx\\?tp="],
        @"ChurnZero": @[@"t.churnzero.net/ss/o/"],
        @"CircleCI": @[@"email.circleci.com/o/"],
        @"Cirrus Insight": @[@"tracking.cirrusinsight.com"],
        @"Clarivate": @[@"/email/track\\?a="],
        @"CLICKBOTPROTECTION": @[@"inthemoon.com/r2.php"],
        @"ClickMeter": @[@"pixel.watch/"],
        @"Clio": @[@"app.clio.com/tracking_pixel"],
        @"Close": @[@"close.io/email_opened", @"close.com/email_opened", @"dripemail2"],
        @"cloudHQ": @[@"cloudhq.io/mail_track", @"cloudhq-mkt[0-9].net/mail_track"],
        @"Coda": @[@"coda.io/logging/ping"],
        @"CommissionSoup": @[@"cstrk.net/imp.aspx\\?l="],
        @"ConneQuityMailer": @[@"connequitymailer.com/open/"],
        @"Conrad": @[@"aktuell.conrad.de/g.html"],
        @"Constant Contact": @[@"rs6.net/on.jsp"],
        @"ContactMonkey": @[@"contactmonkey.com/api/v1/tracker"],
        @"Copernica": @[
            @"/image/[0-9][0-9][0-9][0-9]/[a-z0-9_]+/image.gif\\?cdmiv=",
            @"/images/pixel2.gif\\?pomiv="
        ],
        @"ConvertKit": @[
            @"convertkit-mail.com/o/",
            @"open.convertkit-mail2.com/"
        ],
        @"Copper": @[@"prosperworks.com/tp/t"],
        @"Cordial": @[@"/o/p/[0-9][0-9][0-9][0-9]:"],
        @"Cprpt": @[@"/o.aspx\\?t="],
        @"Creditmantri.com": @[@"mailer.creditmantri.com/t/"],
        @"Critical Impact": @[@"portal.criticalimpact.com/c2/"],
        @"Cuenote": @[@"cuenote.jp/c/"],
        @"Curumeru": @[@"crmf.jp"],
        @"Customer.io": @[
            @"customeriomail.com/e/o",
            @"track.customer.io/e/o",
            @"/e/o/.+",
        ],
        @"Cyberimpact": @[@"app.cyberimpact.com/footer-image"],
        @"Data Axle": @[@"ympxl.com/log.gif"],
        @"dataX": @[@"openedlog.bdash-cloud.com/opened", @"openedlog.smart-bdash.com/opened"],
        @"Dating Profits": @[@"click.xnxxinc.com/campaign/track-email/"],
        @"Deployteq": @[
            @"click.centraalbeheer.nl",
            @"e.wehkamp.nl",
            @"e.bax-shop.nl"
        ],
        @"DidTheyReadIt": @[@"xpostmail.com"],
        @"Discord": @[@"discord.com/api/science/"],
        @"Disney": @[@"clk.messaging.go.com/c/[0-9][0-9]/bcasts/[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]/view"],
        @"DocuMatix": @[@"enews.itcu.org/op\\?m="],
        @"Doorkeeper": @[@"r.doorkeeper.jp/.+.png"],
        @"DotDigital": @[@"trackedlink.net", @"dmtrk.net", @"email.syntricate.com.au"],
        @"Driftem": @[@"driftem.com/ltrack"],
        @"Drop": @[@"pixel.massdrop.com/open/pixel.gif"],
        @"Dropbox": @[@"dropbox.com/l/"],
        @"Dyson": @[@"tracking.dyson.com/t/"], //.*?k=.*&m=.*&c=
        @"eBay": @[@"ebayadservices.com/marketingtracking/v1/impression"],
        @"Ebsta": @[@"console.ebsta.com", @"ebsta.gif", @"ebsta.com/r/"],
        @"EdgeSuite": @[@"epidm.edgesuite.net"],
        @"eGain": @[@"notify.egain.cloud/egain/notify/"],
        @"Email on Acid": @[@"eoapxl.com"],
        @"EmailTracker.website": @[@"my-email-signature.link"],
        @"Emarsys": @[
            @"/mo/.+.gif",
            @"emarsys.com/e2t/o/"
        ],
        @"EmberPoint": @[@"mpse.jp"],
        @"Envoke": @[@"envoke.com/o/"],
        @"Epic Games": @[@"accts.epicgames.com/O/"],
        @"Epsilon": @[
            @"login.dotomi.com/ucm/UCMController",
            @"/O/[a-z0-9_]+/[a-z0-9_]+",
//            @"/O/[a-z0-9_-]+",
            @"ind.dell.com"
        ],
        @"Escalent": @[@"email-analytics.morpace.com"],
        @"eSputnik": @[@"esputnik.com/repository/applications/commons/hidden.png"],
        @"Etransmail": @[@"ftrans03.com/linktrack/"],
        @"EventBrite": @[@"eventbrite.com/emails/action"],
        @"EventsInYourArea": @[@"eventsinyourarea.com/track/"],
        @"EveryAction": @[@"click.everyaction.com/j/"],
        @"Evite": @[@"pippio.com/api/sync", @"nli.evite.com/imp"],
        @"ezyVet": @[@"ezyvet.com/email_open_log.php"],
        @"Fastic": @[@"/e/eo\\?_t="],
        @"Flatastic": @[@"api.flatastic-app.com/index.php/img"],
        @"Flipkart": @[@"flipkart.com/t/open"],
        @"ForMirror": @[@"formirror.com/open/"],
        @"FreeLancer": @[@"freelancer.com/1px.gif"],
        @"FreshMail": @[
            @"mail..+.pl/o/",
//            @"/o/(w){10,}/(w){10,}",
        ],
        @"FrontApp": @[
            @"app.frontapp.com",
            @"web.frontapp.com/api"
        ],
        @"GearBest": @[@"appinthestore.com/marketing/mail-user-deal/open"],
        @"Gem": @[@"zen.sr/o"],
        @"GetBase": @[@"getbase.com/e1t/o/"],
        @"GetNotify": @[@"email81.com/case"],
        @"GetResponse": @[@"/open.html\\?x="],
        @"GitHub": @[@"github.com/notifications/beacon/"],
        @"G-Lock Analytics": @[@"fssdev.com/t/\\?[po]"],
        @"Gmass": @[
            @"ec2-52-26-194-35.us-west-2.compute.amazonaws.com",
            @"link.gmreg[0-9].net",
            @"gmreg[0-9].net",
            @"gmtrack.net",
        ],
        @"Gmelius": @[@"gml.email"],
        @"GoDaddy": @[@"email.cloud.secureclick.net/view\\?"],
        @"gogcli": @[@"gog-email-tracker-"],
        @"Google": @[
            @"ad.doubleclick.net/ddm/ad",
            @"google-analytics.com/collect",
            @"google.com/appserve/mkt/img/",
            @"notifications.google.com/g/img/",
            @"youtube.com/gen_204",
            @"notifications.googleapis.com/email/t",
            @"youtube.com/attribution_link"
        ],
        @"Grammarly": @[@"grammarly.com/open"],
        @"Granicus": @[
            @"govdelivery.com(:[0-9]+)?/track",
            @"links.ssa.gov/track"
        ],
        @"GreenMail": @[@"greenmail.co.in"],
        @"Groupon": @[@"groupon.com/analytic/track.gif\\?"],
        @"GrowthDot": @[@"growthdot.com/api/mail-tracking"],
        @"Higher Logic": @[@"informz.net/z/[a-z0-9_]+/image.gif"],
        @"Hiretual": @[@"api.hiretual.com/webhooks/tracking/open/"],
        @"Homeaway": @[@"trk.homeaway.com"],
        @"HubSpot": @[
            @"t.hubspotemail",
            @"t.hubspotfree",
            @"t.signaux",
            @"t.senal",
            @"t.signale",
            @"t.sidekickopen",
            @"t.sigopn",
            @"t.hsmsdd",
            @"t.strk[0-9][0-9].email",
            @"track.getsidekick.com",
            @"/e2t/o/",
            @"/e2t/c/",
            @"/e2t/to/",
            @"hubspotlinks.com/[bc]to/",
            @"/e3t/[bc]to/"
        ],
        @"Hunter.io": @[@"mltrk.io/pixel"],
        @"Hyper Hyper": @[@"hyperhub.com.au/newhub/api/email/track"],
        @"iContact": @[@"click.icptrack.com/icp"],
        @"Indeed": @[@"subscriptions.indeed.com/imgping"],
        @"Inflection": @[@"tracking.inflection.io"],
        @"Infobip": @[@"/tracking/1/open/"],
        @"Infusion Software": @[
            @"infusionsoft.com/app/emailOpened",
            @"keap-link[0-9][0-9][0-9].com/v2/render/"
        ],
        @"Integral Ad Science": @[@"pixel.adsafeprotected.com"],
        @"Intercom": @[@"via.intercom.io/o", @"intercom-mail.+.com/(via/)?[oq]"],
        @"Intuit": @[
            @"list-manage.com/track/open.php",
            @"us[0-9]+.mailchimp.com/mctx/opens",
            @"/track/open.php\\?u=",
        ],
        @"Inxmail": @[@"/d/d.gif\\?"],
        @"Is-tracking-pixel-api-prod.appspot.com": @[@"is-tracking-pixel-api-prod.appspot.com"],
        @"Iterable": @[@"/s/eo/[a-zA-Z0-9_-]+/[a-zA-Z0-9]+/[0-9][0-9]"],
//        @"JangoMail": @["/[a-z].z\\?[a-z]="],
        @"Japan Railway": @[@"expy.jp/c/"],
        @"Jeeng": @[@"/stripe/image\\?cs_"],
        @"LaunchBit": @[@"launchbit.com/taz-pixel"],
        @"Lidl": @[@"servicemails.lidl.de/d/d.gif"],
        @"LinkedIn": @[@"linkedin.com/emimp/", @"help.linkedin.com/rd/"],
        @"Litmus": @[@"emltrk.com"],
        @"Liveclicker": @[@"em.realtime.email/service/rte\\?kind=duration"],
        @"LiveIntent": @[@"/imp\\?s=[0-9][0-9][0-9][0-9][0-9][0-9]"], // imp?s=&li=&e=&p=&stpe= // imp?s=&li=&m=&p= // imp?s=&e=&p=&stpe
        @"Locaweb": @[@".br/accounts/[0-9][0-9][0-9][0-9]/messages/[0-9][0-9][0-9]/openings/[0-9][0-9][0-9][0-9][0-9]\\?envelope_id="],
        @"LogDNA": @[@"ping.answerbook.com"],
        @"Keychron": @[@"keychron.com/_t/open/"],
        @"Klaviyo": @[@"trk.klaviyomail.com", @"ctrk.klclick[123]?.com/o/"],
        @"Magento": @[
            @"magento.com/trk",
            @"go.rjmetrics.com"
        ],
        @"Mailbird": @[@"tracking.getmailbird.com/OpenTrackingPixel/"],
        @"Mailbutler": @[@"bowtie.mailbutler.io/tracking/hit/"],
        @"Mailcampaigns": @[@"interface.mailcampaigns.nl/v[0-9]/t/"],
        @"Mailcastr": @[@"mailcastr.com/image/"],
        @"MailCoral": @[@"mailcoral.com/open"],
        @"MailerLite": @[@"/link/o/", @"clicks.mlsend.com"],
        @"Mailgun": @[@"/o/eJ"],
        @"MailInifinity": @[@"mailinifinity.com/ptrack"],
        @"Mailjet": @[@"/oo/[a-z0-9]+/[a-z0-9][a-z0-9][a-z0-9][a-z0-9][a-z0-9][a-z0-9][a-z0-9][a-z0-9]/e.gif"],
        @"Mailshake": @[@"w1.mslai.net/prod/open/", @"w1.msstnu.com/prod/open/"],
        @"Mailspring": @[@"getmailspring.com/open",
                         @"img.secureserver.net/bbimage.aspx"
        ],
        @"MailTag": @[@"mailtag.io/email-event"],
        @"MailTrack": @[@"mailtrack.io/trace", @"mltrk.io/pixel"],
        @"Mailzter": @[@"mailzter.in/ltrack"],
        @"Mapp": @[
            @"/tr/p.gif\\?",
            @"enews.zdnet.com/imagelibrary/"
        ],
        @"Maropost": @[@"/a/[0-9][0-9][0-9][0-9]/open/[0-9][0-9][0-9][0-9]/[0-9][0-9][0-9][0-9][0-9][0-9][0-9]?/"],
        @"MDirector": @[@"track.mdrctr.com/track/open/key/"],
        @"Medallia": @[@"survey[0-9]?.medallia.+/\\?[a-z0-9_]+&invite-opened=yes"],
        @"Mercari": @[@"bmo.mercari.jp"],
        @"MessageGears": @[@"/o/4/eyJhaSI6"],
        @"Meta": @[
            @"facebook.com/aymt/aa/",
            @"facebook.com/r/v/",
            @"facebook.com/email_open_log_pic.php",
            @"facebookdevelopers.com/trk",
            @"fb.com/trk",
        ],
        @"MetaData": @[@"metadata.io/e1t/o/"],
        @"Microsoft": @[
            @"svc.dynamics.com/t/i/", // Dynamics 365
            @"mucp.api.account.microsoft.com",
            @"gridinbound.blob.core.windows.net",
            @"dist.nam.formspro.microsoft.com/api/invite/outbound/"
        ],
        @"MixMax": @[
            @"email.mixmax.com",
            @"track.mixmax.com",
            @"mixmax.com/api/track/"
        ],
        @"Mixpanel": @[@"api.mixpanel.com/tr"],
        @"Moneyforward": @[@"tm.moneyforward.com/I/"],
        @"Movable Ink": @[
//            @"/p/rp/\\w{16}.png", // exception for useful info, call-to-action or ad banners
            @"/p/[cu]p/.+/o.gif"
        ],
        @"Mumara": @[@"/campaign/track-email/[0-9][0-9][0-9][0-9][0-9][0-9]__[0-9][0-9][0-9]__[0-9][0-9][0-9][0-9][0-9][0-9][0-9]__[0-9][0-9][0-9]"],
        @"MyEmma": @[@"e2ma.net/track", @"t.e2ma.net"],
        @"Nation Builder": @[@"nationbuilder.com/r/o"],
        @"NeteCart": @[@"netecart.com/ltrack"],
        @"Netflix": @[@"beaconimages.netflix.net/img/"],
        @"NetHunt": @[
            @"nethunt.com/api/v1/track/email/"
//            @"nethunt.co(.*)\\?/pixel.gif"
        ],
        @"Neustar": @[@"/emailprefs/images/[a-z0-9_]+/[0-9]+/"],
        @"Newegg": @[@"newegg.com/mr/.+.gif"],
        @"NewtonHQ": @[@"tr.cloudmagic.com"],
        @"NTT": @[@"club-ntt-west.com/cn-w/cmn/img/1.png"],
        @"Omnisend": @[@"/transactional/track/.+\\?signature="],
        @"Ongage": @[@"/\\?x[ou]l=.+&(amp;)?eih="],
        @"OpenBracket": @[@"openbracket.co/track"],
        @"OpenWork": @[@"openwork.jp/log_mail_open_com"],
        @"Opicle": @[@"track.opicle.com"],
        @"Optimove": @[@"/ss/o/[a-zA-Z0-9_.-]+/[a-z0-9][a-z0-9][a-z0-9]/[a-zA-Z0-9_]+/ho.gif"],
        @"Oracle": @[
            @"tags.bluekai.com/site", // Bluekai
            @"en25.com/e/",
            @"dynect.net/trk.php",
            @"lifelock.custhelp.com/rd/",
            @"bm5150.com/t/",
            @"bm23.com/t/",
            @"/t/o\\?", // bronto
            @"/pub/as\\?_ri_=", // Responsys
            @"/e/FooterImages/FooterImage"
        ],
        @"OutMaster": @[@"outmaster.co/mailer/index.php/campaigns/"],
        @"Outreach": @[
            @"app.outreach.io",
            @"outrch.com/api/mailings/opened",
            @"getoutreach.com/api/mailings/opened",
            @"a.science-recruiting.com/api/mailings/opened"
        ],
        @"Paved": @[@"vpdae.com/open/[0-9][0-9][0-9][0-9].gif"],
        @"PayBack": @[@"email.payback.in/a/", @"mail.payback.in/tr/"],
        @"PayPal": @[@"paypal-communication.com/O/", @"t.paypal.com/ts\\?"],
        @"Paystone": @[@"link.datacandy.com/i/"],
        @"Paytm": @[@"trk.paytmemail.com"],
        @"Peach Aviation": @[
            @"mlapp.flypeach.com/mail/prod/receipt/read.php\\?id=",
            @"mag.flypeach.com/c/" // Cuenote
        ],
        @"Pepipost": @[@"[A-Z][A-Z][A-Z][A-Z][A-Z][A-Z][A-Z][A-Z][A-Z]\\?id="],
        @"PersistIQ": @[@"infinite-stream-5194.herokuapp.com/pixel"],
        @"phpList": @[@"/ut.php\\?u="],
        @"PipeDrive": @[@"api.nylas.com/open"],
        @"Playdom": @[@"playdom.com/g"],
        @"Plusgrade": @[@"upgrade.plusgrade.com/offer/"],
        @"Polymail": @[@"polymail.io/v2/z/", @"share.polymail.io"],
        @"Postmark": @[@"pstmrk.it"],
        @"Press Ganey": @[@"email.patients.pgsurveying.com"],
        @"ProlificMail": @[@"prolificmail.com/ltrack"],
        @"Qualtrics": @[@"/WRQualtricsContacts/Watermark.php"],
        @"Quora": @[@"quora.com/qemail/mark_read"],
        @"Rabobank": @[@"mail.rabobank.nl/public/o/"],
        @"Rakuten": @[
            @"img.travel.rakuten.co.jp/share/mail/img/open/",
            @"r.rakuten.co.jp",
            @"cl.rakuten-bank.co.jp/rw/beacon_",
            @"cmb.rakuten-sec.co.jp/bin/checker"
        ],
        @"ReachMail": @[@"/open/.+/image.gif"],
        @"ReplyCal": @[@"replycal.com/home/index/\\?token"],
        @"ReplyMsg": @[@"replymsg.com"],
        @"Responder.co.il": @[@"opens.responder.co.il"],
        @"Rewe": @[@"epost.rewe.de/action/view/"],
        @"Rocketbolt": @[@"email.rocketbolt.com/o/"],
        @"Rule": @[@"app.rule.io/track/image"],
        @"Sailthru": @[
            @"sailthru.com/trk",
            @"/img/[a-z0-9_.]+/[a-z0-9_][a-z0-9_][a-z0-9_][a-z0-9_][a-z0-9_][a-z0-9_][a-z0-9_][a-z0-9_].gif"
        ],
        @"Salesforce": @[ // ExactTarget
            @"salesforceiq.com/t.png",
            @"beacon.krxd.net",
            @"app.relateiq.com/t.png",
            @"nova.collect.igodigital.com",
//            @"exct.net/open.aspx",
            @"/open.aspx\\?",
            @"pixel.inbox.exacttarget.com/pixel.gif",
            // Pardot
            @"welcome.michaelcassel.com/r/.+/open/1",
            @"pardot.com/r/"
        ],
        @"SalesHandy": @[@"saleshandy.com/web/email/countopened"],
        @"SalesLoft": @[@"salesloft.com/email_trackers"],
        @"Selligent": @[
            @"/optiext/optiextension.dll",
            @"strongview.com/t",
            @"emsecure.net",
            @"selligent.com",
            @"slgnt.eu",
            @"slgnt.us"
        ],
        @"Sendinblue": @[
            @"sendibtd.com",
            @"sendibw.com/track/",
            @"amxe.net", // formerly Newsletter2Go
            @"/[a-z][a-z]/op/",
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
            @"sendgrid.net/wf/open",
            @"sendgrid.net/trk",
            @"sendgrid.net/mpss/o",
            @"sendgrid.net/ss/o",
            @"sendgrid.com/wf/open",
            @"sendgrid.com/trk",
            @"sendgrid.com/mpss/o",
            @"sendgrid.com/ss/o",
            @"/wf/open\\?upn="
        ],
        @"SendPulse": @[@"stat-pulse.com"],
        @"Sendy": @[@"/t/[a-zA-Z0-9_]+/[a-zA-Z0-9_]"],
        @"Shopify": @[@"/tools/emails/open/"],
        @"Signal": @[@"signl.live/tracker"],
        @"Smore": @[@"smore.com/app/reporting/pixel/"],
        @"Snov.io": @[@"/track/open/v2-"],
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
            @"/q/.+~~/",
        ],
        @"Splio": @[@"trk-2.net/ouv"],
        @"Sprinklr": @[@"tracking-prod.sprinklr.com"],
        @"Staples": @[@"/ctt/mktOpen\\?"],
        @"Steam": @[@"store.steampowered.com/emi/"],
        @"Step Coupon": @[@"step-coupon.com/review_mail_read_status.html"],
        @"Streak": @[@"mailfoogae.appspot.com"],
        @"SMTP.com": @[@"track.smtpsendmail.com/[0-9][0-9][0-9][0-9][0-9][0-9]?[0-9]?/o"],
        @"Squarespace": @[@"engage.squarespace-mail.com/v2/a.gif"],
        @"Substack": @[@"substack.com/o/"],
        @"Superhuman": @[@"r.superhuman.com"],
        @"Taguchi": @[@"taguchimail.com/i/app"],
        @"TataDocomoBusiness": @[@"tatadocomobusiness.com/rts/"],
        @"Techgig": @[@"tj_mailer_opened_count_all.php"],
        @"Telstra": @[@"tapi.telstra.com/presentation/v1/notification-mngmt/delivery-status-tracker"],
        @"The Atlantic": @[
            @"data-cdn.theatlantic.com/email.gif"
        ],
        @"The Chronicle of Higher Education": @[@"d2uowlhdj52lqx.cloudfront.net/emailbeacon.png"],
        @"TheTopInbox": @[@"thetopinbox.com/track/"],
        @"The Washington Post": @[
            @"palomaimages.washingtonpost.com/pr2/.+-beacon-[0-9]-[0-9]-[0-9][0-9]?-[0-9]",
            @"s2.washingtonpost.com/beacon/"
        ],
        @"Thunderhead": @[@"na5.thunderhead.com"],
        @"Tinyletter": @[@"tinyletterapp.com"],
        @"ToutApp": @[@"go.toutapp.com"],
        @"Track": @[
            @"trackapp.io/[br]/",
            @"trackapp.io/static/img/track.gif"
        ],
        @"Traverse": @[
            @"/v1/.+/[0-9].gif\\?emailMd5Lower=",
            @"getpic.php\\?l="
        ],
        @"Tripolis": @[@"/public/o/.+/t.gif"],
        @"Trustyou": @[@"analytics.trustyou.com/surveys/api/mailing/events/invitation/opened"],
        @"Twilio": @[@"api.segment.io/v1/pixel/track"],
        @"Twitch": @[@"spade.twitch.tv/track"],
        @"Twitter": @[@"twitter.com/scribe/ibis"],
        @"UNiDAYS": @[@"links[0-9]?.m.myunidays.com"],
        @"Unsplash": @[@"email.unsplash.com/o/"],
        @"Upland PostUp": @[@"efeedbacktrk.com"],
        @"US Bancorp": @[@"post-images.com/amy/open.action"],
        @"User.com": @[@".user.com/emails/open/"],
        @"Validity": @[
            @".returnpath.net/pixel.gif",
//            @"/ea/.+/\\?e=" // everestengagement.com
        ],
        @"Varibase": @[@"e.varibase.com/mail/MOS"],
        @"Vcommission": @[@"tracking.vcommission.com"],
        @"Verizon": @[@"verizon.com/econtact/ecrm/EmailTracking.serv"],
        @"VinSolutions": @[@"vinlens.com/email.ashx\\?c="],
        @"Vinted": @[@"vinted.[a-z][a-z]/crm/email_track\\?crm_email_id="],
        @"Vtiger": @[@"od2.vtiger.com/shorturl.php"],
        @"Walmart": @[@"w-mt.co/g/rptrcks/comm-smart-app/services/tracking/openTracker"],
        @"WhatCounts": @[@"/t\\?c=[0-9][0-9][0-9][0-9]&r=[0-9][0-9][0-9][0-9]&l=[0-9][0-9][0-9]?&t=[0-9][0-9]&e="],
        @"We Are Web": @[@"tracking.weareweb.in/index.php/campaigns/"],
        @"Webtrekk": @[@"webtrekk.net"],
        @"Windscribe": @[@"windscribe.com/pixel"],
        @"WildApricot": @[
            @"wildapricot.com/o/",
            @"wildapricot.org/emailtracker",
            @"/EmailTracker/EmailTracker.ashx"
        ],
        @"Wise": @[@"links.transferwise.com/track/", @"api.transferwise.com"],
        @"Wish": @[@"wish.com/email-beacon.png"],
        @"Wix": @[@"shoutout.wix.com"],
        @"WordPress": @[@"pixel.wp.com/t.gif"],
        @"Yahoo!": @[@"a.analytics.yahoo.com/p.pl"],
        @"Yahoo! Japan": @[@"dsb.yahoo.co.jp/api/v1/clear.gif"],
        @"YAMM": @[@"yamm-track.appspot"],
        @"Yardi": @[@"/t/teo\\?ref="],
        @"Yesware": @[@"yesware.com/trk", @"yesware.com/t/", @"t.yesware.com"],
        @"Zendesk": @[@"futuresimple.com/api/v1/sprite.png"],
        @"Zeta Global": @[
            @"e.newsletters.cnn.com/open/",
            @"e.email.consumerreports.org/open/"
        ],
        @"Zoho": @[
            @"maillist-manage.com/clicks/",
            @"/open.gif",
            @"sender[0-9].zohoinsights-crm.com/ocimage/"
        ],
    };
}
@end
