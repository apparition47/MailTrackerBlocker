//
//  MTBBlockedMessageTest.m
//  Unit Tests
//
//  Created by Daniel Dickison on 2021-02-27.
//

#import <XCTest/XCTest.h>
#import "MTBBlockedMessage.h"

@interface MTBBlockedMessageTest : XCTestCase
@end

@implementation MTBBlockedMessageTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testCleanHtml {
    NSString *cleanHTML = @"<p>This is an email without any trackers <img src='https://example.com/foo.png' width=\"32\" height=\"32\" style=\"color:red\"> blah <div>hello</div></p>";
    XCTAssertEqualObjects([[MTBBlockedMessage alloc] initWithHtml:cleanHTML].sanitizedHtml,
                   cleanHTML);
    XCTAssertEqual([[MTBBlockedMessage alloc] initWithHtml:cleanHTML].sanitizedHtml,
                   cleanHTML,
                   @"Original string should be referenced directly for clean HTML");
    
    MTBBlockedMessage *dataAttr = [[MTBBlockedMessage alloc] initWithHtml:@"<p>No tracker but img with data attributes<img border=\"0\" style=\"max-width: 100%; height: auto; margin-bottom: 12px;\" data-attachment-id=\"49174\" data-permalink=\"https://example.com/sample/\" data-orig-file=\"https://example.com/2021/03/sample.jpg\" data-orig-size=\"1034,1600\" data-comments-opened=\"1\" data-image-meta=3D'{\"aperture\":\"0\",\"credit\":\",\"camera\":\",\"caption\":\",\"created_timestamp\":\"0\",\"copyright\":\",\"focal_length\":\"0\",\"iso\":\"0\",\"shutter_speed\":\"0\",\"title\":\",\"orientation\":\"0\"}' data-image-title=\"sample\" data-image-description=\" data-medium-file=\"https://example.com/2021/03/sample.jpg?w=3D194\" data-large-file=\"https://example.com/2021/03/sample.jpg?w=3D662\" class=\"size-full wp-image-49174\" src=\"https://example.com/2021/03/sample.jpg?w=3D560\" alt=\"sample\" srcset=\"https://example.com/2021/03/sample.jpg?w=3D560 750w, https://example.com/2021/03/sample.jpg?w=3D97 97w, https://example.com/2021/03/sample.jpg?w=3D194 194w, https://example.com/2021/03/sample.jpg?w=3D768 768w, https://example.com/2021/03/sample.jpg?w=3D662 662w, https://example.com/2021/03/sample.jpg 1034w\" sizes=\"(max-width: 750px) 100vw, 750px\"></p>"];
    XCTAssertEqualObjects(dataAttr.sanitizedHtml,
                          @"<p>No tracker but img with data attributes<img border=\"0\" style=\"max-width: 100%; height: auto; margin-bottom: 12px;\" data-attachment-id=\"49174\" data-permalink=\"https://example.com/sample/\" data-orig-file=\"https://example.com/2021/03/sample.jpg\" data-orig-size=\"1034,1600\" data-comments-opened=\"1\" data-image-meta=3D'{\"aperture\":\"0\",\"credit\":\",\"camera\":\",\"caption\":\",\"created_timestamp\":\"0\",\"copyright\":\",\"focal_length\":\"0\",\"iso\":\"0\",\"shutter_speed\":\"0\",\"title\":\",\"orientation\":\"0\"}' data-image-title=\"sample\" data-image-description=\" data-medium-file=\"https://example.com/2021/03/sample.jpg?w=3D194\" data-large-file=\"https://example.com/2021/03/sample.jpg?w=3D662\" class=\"size-full wp-image-49174\" src=\"https://example.com/2021/03/sample.jpg?w=3D560\" alt=\"sample\" srcset=\"https://example.com/2021/03/sample.jpg?w=3D560 750w, https://example.com/2021/03/sample.jpg?w=3D97 97w, https://example.com/2021/03/sample.jpg?w=3D194 194w, https://example.com/2021/03/sample.jpg?w=3D768 768w, https://example.com/2021/03/sample.jpg?w=3D662 662w, https://example.com/2021/03/sample.jpg 1034w\" sizes=\"(max-width: 750px) 100vw, 750px\"></p>");
    XCTAssertEqual(dataAttr.certainty, BLOCKING_RESULT_CERTAINTY_LOW_NO_MATCHES, @"Should not filter img with data-attribute");
}

- (void)test1pxBorder {
    NSString *cleanHTML = @"<p>This is an email without any trackers <img src='https://example.com/foo.png' width='32' height='16' style='width: 32px; height: 16px; border: 1px solid gray;'> blah </p>";
    XCTAssertEqualObjects([[MTBBlockedMessage alloc] initWithHtml:cleanHTML].sanitizedHtml,
                   cleanHTML);
    XCTAssertEqual([[MTBBlockedMessage alloc] initWithHtml:cleanHTML].sanitizedHtml,
                   cleanHTML,
                   @"1px bordered img shouldn't be removed");
    
    NSString *borderWidth = @"<img src=\"https://www.example.co.jp/mediapermalink/NI_banner_20210825\" alt=\"This week new items\" width=\"1000\" style=\"display:block; border-style: solid;border-width: 1px 1px; border-color: #000000;\" />";
    XCTAssertEqualObjects([[MTBBlockedMessage alloc] initWithHtml:borderWidth].sanitizedHtml,
                          borderWidth);
    XCTAssertEqual([[MTBBlockedMessage alloc] initWithHtml:borderWidth].sanitizedHtml,
                   borderWidth,
                   @"1px bordered img shouldn't be removed");
}

- (void)testDropboxHyperlinks {
    MTBBlockedMessage *msg = [[MTBBlockedMessage alloc] initWithHtml:@"<a href=\"https://www.dropbox.com/l/AAAhW7m5KgieXUt96YPVxQAikIuP2k0jBzQ/deleted_files\"><img height=\"1\" src=\"https://www.dropbox.com/l/AADXCtjPO6z7f4q38mMZzFj33E0hL2iRjTE\" width=\"1\" /><a href=\"https://www.dropbox.com/l/AAApjR2Uembfm6p3zhWNf_5g0HGUNrTTE2E\">Unsubscribe</a>"];
    XCTAssertEqualObjects(msg.sanitizedHtml,
                          @"<a href=\"https://www.dropbox.com/l/AAAhW7m5KgieXUt96YPVxQAikIuP2k0jBzQ/deleted_files\"><a href=\"https://www.dropbox.com/l/AAApjR2Uembfm6p3zhWNf_5g0HGUNrTTE2E\">Unsubscribe</a>");
    XCTAssertEqualObjects(msg.detectedTracker, @"Dropbox");
    XCTAssertEqual(msg.certainty, BLOCKING_RESULT_CERTAINTY_CONFIDENT_HARD_MATCH);
}

- (void)testGoogleAnalytics {
    MTBBlockedMessage *msg = [[MTBBlockedMessage alloc] initWithHtml:@"<p>This is an email with a google tracker <img alt="" height=1 width=3 src=https://notifications.google.com/g/img/AD-FnEzt8doYQCTNQv1w6jsjHDU6Kh6lId34t0STSV3ydKTDIw.gif></p>"];
    XCTAssertEqualObjects(msg.sanitizedHtml,
                          @"<p>This is an email with a google tracker </p>");
    XCTAssertEqualObjects(msg.detectedTracker, @"Google");
    XCTAssertEqual(msg.certainty, BLOCKING_RESULT_CERTAINTY_CONFIDENT_HARD_MATCH);
}

- (void)testSES {
    // awstrack pattern
    MTBBlockedMessage *msg = [[MTBBlockedMessage alloc] initWithHtml:@"<p><a class=\"cta-btn\" href=\"http://qpvvmjwx.r.us-east-1.awstrack.me/L0/http:%2F%2Fmastercardidps.idprotectiononline.com%2Falerts%2Fhistory.html%3Flang=3Den_US%26utm_source=3Demail%26utm_medium=3Demail%26utm_campaign=3Didp_standard_emails%26utm_content=3D44a%2509Identity%2520Monitoring%2520Alert/1/01000178626eb1e0-f1b813fc-c0a8-4ba5-90af-b39d859905cf-000000/27r5oe9sP7Z0DFVB_WeA7aWcx2Y=3D206\">VIEW MY ALERT</a> <img alt=\"\" src=\"http://qpvvmjwx.r.us-east-1.awstrack.me/I0/01000178626eb1e0-f1b813fc-c0a8-4ba5-90af-b39d859905cf-000000/2FKwVZSzpKPUSLDQmdmviCr5aC0206\" style=\"display: none; width: 1px; height: 1px;\"></p>"];
    XCTAssertEqualObjects(msg.sanitizedHtml,
                          @"<p><a class=\"cta-btn\" href=\"http://qpvvmjwx.r.us-east-1.awstrack.me/L0/http:%2F%2Fmastercardidps.idprotectiononline.com%2Falerts%2Fhistory.html%3Flang=3Den_US%26utm_source=3Demail%26utm_medium=3Demail%26utm_campaign=3Didp_standard_emails%26utm_content=3D44a%2509Identity%2520Monitoring%2520Alert/1/01000178626eb1e0-f1b813fc-c0a8-4ba5-90af-b39d859905cf-000000/27r5oe9sP7Z0DFVB_WeA7aWcx2Y=3D206\">VIEW MY ALERT</a> </p>");
    XCTAssertEqualObjects(msg.detectedTracker, @"Amazon SES");
    XCTAssertEqual(msg.certainty, BLOCKING_RESULT_CERTAINTY_CONFIDENT_HARD_MATCH);
    
    MTBBlockedMessage *msg6 = [[MTBBlockedMessage alloc] initWithHtml:@"<img alt=\"\" src=\"http://ql9whnmm.r.us-east-1.awstrack.me/I0/01000174cf3fdcab-ecc7d369-5fb0-44f3-8399-6d801e7cbb70-000000/FQQ6fmRGPj_Eb_dkOISswGPZgLY=181\" style=\"display: none; width: 1px; height: 1px;\">"];
    XCTAssertEqualObjects(msg6.sanitizedHtml,
                          @"");
    XCTAssertEqualObjects(msg6.detectedTracker, @"Amazon SES");
    XCTAssertEqual(msg6.certainty, BLOCKING_RESULT_CERTAINTY_CONFIDENT_HARD_MATCH);
    
    // custom domain pattern
    MTBBlockedMessage *msg2 = [[MTBBlockedMessage alloc] initWithHtml:@"<img alt=\"\" src=\"http://click.em.nike.com/CI0/0100017caa0a4138-89d1c903-b840-471e-ad1a-0cbc0997641a-000000/Q6hkyQLinbRp9WRkl0o8ZJlBZ-elr1g-yPs6poQou-o=220\" style=\"display: none; width: 1px; height: 1px;\">"];
    XCTAssertEqualObjects(msg2.sanitizedHtml,
                          @"");
    XCTAssertEqualObjects(msg2.detectedTracker, @"Amazon SES");
    XCTAssertEqual(msg2.certainty, BLOCKING_RESULT_CERTAINTY_CONFIDENT_HARD_MATCH);
    
    MTBBlockedMessage *msg3 = [[MTBBlockedMessage alloc] initWithHtml:@"<img alt=\"\" src=\"http://59.email.stripe.com/CI0/0101017a18a2c884-275c7052-5962-46c6-9f24-38b9c237837d-000000/EQegK2PpXW-rBnfB_Vcavg3BZn7XuZm-Izjx1ypvG3U=196\" style=\"display: none; width: 1px; height: 1px;\">"];
    XCTAssertEqualObjects(msg3.sanitizedHtml,
                          @"");
    XCTAssertEqualObjects(msg3.detectedTracker, @"Amazon SES");
    XCTAssertEqual(msg3.certainty, BLOCKING_RESULT_CERTAINTY_CONFIDENT_HARD_MATCH);
    
    MTBBlockedMessage *msg4 = [[MTBBlockedMessage alloc] initWithHtml:@"<img alt=\"\" src=\"http://r.g-omedia.com/CI0/0100017b655e9634-e9db3649-077c-4eb3-bc18-d712a8f04278-000000/9A0iiORY_AD4aLf2hhsOMBi_Nz7EPp3ERensOLcwYno=211\" style=\"display: none; width: 1px; height: 1px;\">"];
    XCTAssertEqualObjects(msg4.sanitizedHtml,
                          @"");
    XCTAssertEqualObjects(msg4.detectedTracker, @"Amazon SES");
    XCTAssertEqual(msg4.certainty, BLOCKING_RESULT_CERTAINTY_CONFIDENT_HARD_MATCH);
    
    MTBBlockedMessage *msg5 = [[MTBBlockedMessage alloc] initWithHtml:@"<img alt=\"\" src=\"http://click.redditmail.com/CI0/0100017c014860ac-0625adf4-797e-4e18-9aaf-6e3ee131936e-000000/Po3PKjEXpdWDIPTCQoCMB_gkYAx_6ebEOgAeKSqyA-g=215\" style=\"display: none; width: 1px; height: 1px;\">"];
    XCTAssertEqualObjects(msg5.sanitizedHtml,
                          @"");
    XCTAssertEqualObjects(msg5.detectedTracker, @"Amazon SES");
    XCTAssertEqual(msg5.certainty, BLOCKING_RESULT_CERTAINTY_CONFIDENT_HARD_MATCH);
}

- (void)testAdobe {
    MTBBlockedMessage *msg = [[MTBBlockedMessage alloc] initWithHtml:@"<img height='0' width='0' alt='' src='http://t.newsletter.maisonmargiela.com/r/?id=h43bbc67c,11de365c,1'/>"];
    MTBBlockedMessage *msg2 = [[MTBBlockedMessage alloc] initWithHtml:@"<img height='0' width='0' alt='' src='http://t.c.mcdonalds.com/r/?id=h199899af1,1ccea045,1'/>"];
    XCTAssertEqualObjects(msg.sanitizedHtml, @"");
    XCTAssertEqualObjects(msg2.sanitizedHtml, @"");
    XCTAssertEqualObjects(msg.detectedTracker, msg2.detectedTracker);
    XCTAssertEqual(msg.certainty, BLOCKING_RESULT_CERTAINTY_CONFIDENT_HARD_MATCH);
    XCTAssertEqual(msg2.certainty, BLOCKING_RESULT_CERTAINTY_CONFIDENT_HARD_MATCH);
}

- (void)testSendgrid {
    MTBBlockedMessage *msg = [[MTBBlockedMessage alloc] initWithHtml:@"<p>This is an email with a sendgrid tracker <img src='https://sendgrid.com/trk/123ef89329817898/3248932743' width='1' height='1' style='width: 1px; height: 1px;'></p>"];
    XCTAssertEqualObjects(msg.sanitizedHtml,
                          @"<p>This is an email with a sendgrid tracker </p>");
    XCTAssertEqualObjects(msg.detectedTracker, @"SendGrid");
    XCTAssertEqual(msg.certainty, BLOCKING_RESULT_CERTAINTY_CONFIDENT_HARD_MATCH);
}

- (void)testWhatCounts {
    MTBBlockedMessage *msg = [[MTBBlockedMessage alloc] initWithHtml:@"<!--STARTTTAG-->\\n<img src=\"http://marketing.yourcentre.com.au/t?c=1109&r=6455&l=445&t=10&e=BD6A538E5E55F07F21769496C4BAD3DF0CD83620A56156C8\" width=1 height=1 border=0>\\n<!--ENDTTAG-->"];
    XCTAssertEqualObjects(msg.sanitizedHtml,
                          @"<!--STARTTTAG-->\\n\\n<!--ENDTTAG-->");
    XCTAssertEqualObjects(msg.detectedTracker, @"WhatCounts");
    XCTAssertEqual(msg.certainty, BLOCKING_RESULT_CERTAINTY_CONFIDENT_HARD_MATCH);

    MTBBlockedMessage *msg2 = [[MTBBlockedMessage alloc] initWithHtml:@"<!--STARTTTAG-->\\n<img src=\"https://tracking.whatcounts.com/t?c=1286&r=6049&l=72&t=10&e=0217D218A1DD2DFBDB56273B045B6272E479F7D10B9C8731\" width=1 height=1 border=0>\\n<!--ENDTTAG-->"];
    XCTAssertEqualObjects(msg2.sanitizedHtml,
                          @"<!--STARTTTAG-->\\n\\n<!--ENDTTAG-->");
    XCTAssertEqualObjects(msg2.detectedTracker, @"WhatCounts");
    XCTAssertEqual(msg2.certainty, BLOCKING_RESULT_CERTAINTY_CONFIDENT_HARD_MATCH);
}

- (void)testMailgun {
    MTBBlockedMessage *mail1 = [[MTBBlockedMessage alloc] initWithHtml:@"<img width=\"1px\" height=\"1px\" alt=\" src=\"http://email.mgdynamic1.webpt.com/o/eJwtz81uhCAUQOGnqZtJCCoOsmA3D9Ck3ZvL5aqMIArqaJ--P-n-LM5nNZUCAItEgGMHuLk468c1Q3BYOH0vq0bKsq7b1qqOKsOlqFtRGsFrUatKKXgTXIlKSd4CIa9YAOeLUZfSyAbR3qWVgpteNQrQ1tgbsrw4pqDfsAuUMwzUOauf8_6cDrOveFrCYXiNF17opxXD7vGK59CfYcoegj1SXjyuRdImmp-BtOccWd5262KxpHg4S6mLaYDZfcGf6WNL7qDb-3hlh-Bvn4yxf3WmdFDSSwrsRWbZGMbwDa8dYfg\">"];
    XCTAssertEqualObjects(mail1.sanitizedHtml, @"");
    XCTAssertEqualObjects(mail1.detectedTracker, @"Mailgun");
    XCTAssertEqual(mail1.certainty, BLOCKING_RESULT_CERTAINTY_CONFIDENT_HARD_MATCH);
    
    MTBBlockedMessage *mail2 = [[MTBBlockedMessage alloc] initWithHtml:@"<img width=\"1px\" height=\"1px\" alt=\" src=\"https://email.unsplash.com/o/eJydkDFThDAQhX_N0TDHJCThSEHheaNj49hYM0uycHEgwRDO4d8L6CnXWNgl-96-7yUKuh5MY3fi6FGZ3qANpXYdmHl0KpzFGkJjPNQ1Jsp1kfpdwNnVlsNYvaEKi_vVDn0Lwzk2Q1yhsU0M6n00HnVcTfEjhjDFTx00OES64JRBvo27gDcQjFvB984G79rIFClJKWGMEiKIkAlNCCMZFzw_UiEe7k5ix8n4DV4bngsQkKu0onDgNKMSU8w0PUiOFIREVFvq_-r7AsDPTTn584d675bw0kKHN4QX7_Solsdu7WHqV9szfgztjEN_o2I4Lwf8SduK12Np9CLlguVMRqG4oHf7r9tepizj1-EnXGmq-Q\">"];
    XCTAssertEqualObjects(mail2.sanitizedHtml, @"");
    XCTAssertEqualObjects(mail2.detectedTracker, @"Mailgun");
    XCTAssertEqual(mail2.certainty, BLOCKING_RESULT_CERTAINTY_CONFIDENT_HARD_MATCH);
    
    MTBBlockedMessage *mail3 = [[MTBBlockedMessage alloc] initWithHtml:@"<img width=\"1px\" height=\"1px\" alt=\" src=\"email.mailgun.patreon.com/o/eJwdj0uOwzAMQ08z2TlQZPmjRRZFD1Iolt0Gkx9Sd9HbjzM7kiAeSB0zOOLYVXn_PmYdaUCLCmxsUTUUlM2kxZoYfJ6QC7AL3TwiDAyEjE047IeefLjdbwMFQHsPzv8QrDIvz8_WH1LPvG992teu5vVYpObHJmsej42Z0_dzaEuu1r69L3B3jiLNNMa-5SL1OZ9SSv4nvEZo05xaJUAkKS7awIKelJPjZGM3SU2v64ykBNZyMgliNOR1MkIQTBFs24fM6uEPmrNNVA\">"];
    XCTAssertEqualObjects(mail3.sanitizedHtml, @"");
    XCTAssertEqualObjects(mail3.detectedTracker, @"Mailgun");
    XCTAssertEqual(mail3.certainty, BLOCKING_RESULT_CERTAINTY_CONFIDENT_HARD_MATCH);
    
    MTBBlockedMessage *mail4 = [[MTBBlockedMessage alloc] initWithHtml:@"<img width=\"1px\" height=\"1px\" alt=\" src=\"http://email.mail.gitguardian.com/o/eJxtUctuGzEM_BrvJbBBPVa7OuwhqZtLgB6a3BeUSNlCvA9oZRf--zJ10VMJiZghAWo0pAGsVaHBNX_yfTzn0_kitzKN13IZzrWu28487_SrnFOu52s4xGUSguuKJde8zLYT-v7j_cjTIkjaU64COifRQ1DOGibykl2MgkJIyjMYz8rart1pQzmlPacYTYuxZxsCE1itnVecDIRIoOmn0k0eNGiAXnkFrYX2oA7uu26Px_5FgVPf3LHbWZgwXw6i9nTFQhnnL8lN5Wm9YOVxxomHf2wt03jTDd94riN9VdJSJqxiwZ-39tDvlf9QIDbYXlLrd_oFJBq8cKljpgESGfB9DylCjK3qlHaYOnBOc3KcSLukLAefOo3UkifwLXTW-w6d7rApA2JZZpG-zJywnnLBlPihe1jLQiOGm7JC6q8s2spYl0-eNyl9PArNefBBeQvojFUQ2HBrewJKhmwEq9g0xJVjXcpIeZPf3x9W_B3w9CzL2banN75vTeF1eXT_v-ffeoW1Xw\">"];
    XCTAssertEqualObjects(mail4.sanitizedHtml, @"");
    XCTAssertEqualObjects(mail4.detectedTracker, @"Mailgun");
    XCTAssertEqual(mail4.certainty, BLOCKING_RESULT_CERTAINTY_CONFIDENT_HARD_MATCH);
}

- (void)testGenericPixel {
    MTBBlockedMessage *attrAndStyle = [[MTBBlockedMessage alloc] initWithHtml:@"<p>Generic tracker with 1x1 width/height attr and 1x1 style <img src='https://example.com/foo/123ef89329817898/3248932743' width='1' height='1' style='width: 1px; height: 1px;'></p>"];
    XCTAssertEqualObjects(attrAndStyle.sanitizedHtml,
                          @"<p>Generic tracker with 1x1 width/height attr and 1x1 style </p>");
    XCTAssertEqual(attrAndStyle.certainty, BLOCKING_RESULT_CERTAINTY_MODERATE_HEURISTIC);
    
    MTBBlockedMessage *noStyle = [[MTBBlockedMessage alloc] initWithHtml:@"<p>Generic tracker with 1x1 width/height <img width=\"1px\" height=\"1px\" alt=\"\" src=\"https://example.com/eJwVjEsOgyAUAE8jSwI8sLpgYWx7DcPnEWlQDGJse_razSQzi_FaceNUIFELJjgD3v3JBOUUnt0Ij7EfYBBK3GUj2YrnnrBWLHTJNqb4RXrsZNYtOBCOBeNtf5NWMI7OMC6kahUABFL0C3300cxTyO9rZUs-V4r-IFWfuSTfwLCV7C_FxcQ01c-GV5P9DxElMgM\"></p>"];
    XCTAssertEqualObjects(noStyle.sanitizedHtml,
                          @"<p>Generic tracker with 1x1 width/height </p>");
    XCTAssertEqual(noStyle.certainty, BLOCKING_RESULT_CERTAINTY_MODERATE_HEURISTIC);
    
    MTBBlockedMessage *style = [[MTBBlockedMessage alloc] initWithHtml:@"<p>Generic tracker with 1x1 style <img style='width: 1px; height: 1px;' src=\"https://example.com/track.gif\"></p>"];
    XCTAssertEqualObjects(style.sanitizedHtml,
                          @"<p>Generic tracker with 1x1 style </p>");
    XCTAssertEqual(style.certainty, BLOCKING_RESULT_CERTAINTY_MODERATE_HEURISTIC);

    MTBBlockedMessage *attrAndStyleSpaced = [[MTBBlockedMessage alloc] initWithHtml:@"<p>Generic tracker with 1x1 width/height attr with spaces <img width = \"1\" height = \"1\" src=\"https://example.com/track.gif\"></p>"];
    XCTAssertEqualObjects(attrAndStyleSpaced.sanitizedHtml,
                          @"<p>Generic tracker with 1x1 width/height attr with spaces </p>");
    XCTAssertEqual(attrAndStyleSpaced.certainty, BLOCKING_RESULT_CERTAINTY_MODERATE_HEURISTIC);
    
    MTBBlockedMessage *zeroByZero = [[MTBBlockedMessage alloc] initWithHtml:@"<p>Generic tracker with 0x0 and display none<img src=\"https://example/?j3hjhdf3jsl&invite-opened=yes\" width=\"0\" height=\"0\" style=\"display: none !important;\" alt=\"\"></p>"];
    XCTAssertEqualObjects(zeroByZero.sanitizedHtml,
                          @"<p>Generic tracker with 0x0 and display none</p>");
    XCTAssertEqual(zeroByZero.certainty, BLOCKING_RESULT_CERTAINTY_MODERATE_HEURISTIC);
}

- (void)testMultipleGenericPixels {
    MTBBlockedMessage *msg = [[MTBBlockedMessage alloc] initWithHtml:@"<p>This is an email with multiple generic pixel trackers <img src='https://example.com/foo/123ef89329817898/3248932743' width='1' height='1' style='width: 1px; height: 1px;'></p>\n<img src='https://foo.com/bar/xyzsdfji' style='width: 1px; height: 1px;'>"];
    XCTAssertEqualObjects(msg.sanitizedHtml,
                          @"<p>This is an email with multiple generic pixel trackers </p>\n");
    XCTAssertEqual(msg.certainty, BLOCKING_RESULT_CERTAINTY_MODERATE_HEURISTIC);
}

- (void)testMultipleNamedTrackers {
    MTBBlockedMessage *msg = [[MTBBlockedMessage alloc] initWithHtml:@"<p>This is an email with 2 trackers <img src=\"https://pixel.app.returnpath.net/pixel.gif?r=ed9192ab2ef6abcde2e8e6ff2800a1f9c04d3790&c=OP21002_Tax_Readiness_EM_DM\" width=\"1\" height=\"1\" /><img src=\"https://click.e-vanguard.com/open.aspx?ffcb10-fe87157972610abcde-fe3217727162057c721673-fe9a13727561007d76-ff6a1abcde-fe3315737367047e711478-fefa15717abcde&d=70166&bmt=0\" width=\"1\" height=\"1\" alt=\"\"></p>"];
    XCTAssertEqualObjects(msg.sanitizedHtml,
                          @"<p>This is an email with 2 trackers </p>");
    XCTAssertEqualObjects(msg.detectedTracker, @"Salesforce");
    XCTAssertEqual(msg.certainty, BLOCKING_RESULT_CERTAINTY_CONFIDENT_HARD_MATCH);
}

- (void)testBase64Email {
    NSString *email = [self getHTMLResourceWithFileName:@"embeddedBase64Img"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Timeout"];
    MTBBlockedMessage __block *msg;
    dispatch_async(dispatch_get_main_queue(), ^{
        msg = [[MTBBlockedMessage alloc] initWithHtml: email];
        [expectation fulfill];
    });
    [self waitForExpectations:@[expectation] timeout:5];
    XCTAssertEqual(msg.certainty, BLOCKING_RESULT_CERTAINTY_LOW_NO_MATCHES);
}

- (void)testCSSTracker {
    NSString *css = @"<style>#_eoa_div, #_eoa_img { display: none; } @media print { #_eoa_div { background-image: url('https://b2ccbsz7BC.eoapxl.com/b2ccbsz7BC/3211022171135001432317022/P');} } div.OutlookMessageHeader, table.moz-email-headers-table, blockquote #_eoa_div, #mailContainerBody #_eoa_div {background-image: url('https://b2ccbsz7BC.eoapxl.com/b2ccbsz7BC/3211022171135001432317022/F') }</style>";
    MTBBlockedMessage *msg3 = [[MTBBlockedMessage alloc] initWithHtml:css];
    XCTAssertEqualObjects(msg3.sanitizedHtml, @"<style>#_eoa_div, #_eoa_img { display: none; } @media print { #_eoa_div { ;} } div.OutlookMessageHeader, table.moz-email-headers-table, blockquote #_eoa_div, #mailContainerBody #_eoa_div { }</style>");
    // email on acid
    XCTAssertEqual(msg3.knownTrackerCount, 2);
}

- (void)testMultipleBackgroundCSSAndImgTagTrackers {
    NSString *email = [self getHTMLResourceWithFileName:@"multibgcsstrackers"];
    MTBBlockedMessage *msg = [[MTBBlockedMessage alloc] initWithHtml:email];
    XCTAssertEqual(msg.detectedTrackers.count, 2);
    XCTAssertEqual(msg.knownTrackerCount, 10);
    XCTAssertTrue([msg.detectedTrackers containsObject:@"Litmus"]);
    XCTAssertTrue([msg.detectedTrackers containsObject:@"SparkPost"]);
}

- (void)testEscalentBackgroundCSSAndImgTagTrackers {
    NSString *email = @"<style> @media print{ #_two50 { background-image:url('http://email-analytics.morpace.com/ea/IImB1RCPJg/?t=p&e=4642959029~F230064_7&c=F230064_7&ID=4642959029'); } } blockquote #_two50, #mailContainerBody #_two50, div.OutlookMessageHeader, table.moz-email-headers-table { background-image:url('http://email-analytics.morpace.com/ea/IImB1RCPJg/?t=f&e=4642959029~F230064_7&c=F230064_7&ID=4642959029'); } </style> <div id='_two50'></div> <img id='_two50_img' src='http://email-analytics.morpace.com/ea/IImB1RCPJg/?e=4642959029~F230064_7&c=F230064_7&ID=4642959029' width='1' height='1' style='margin:0 !important; padding:0 !important; border:0 !important; height:1px !important; width:1px !important;' />";
    MTBBlockedMessage *msg = [[MTBBlockedMessage alloc] initWithHtml:email];
    XCTAssertEqual(msg.detectedTrackers.count, 1);
    XCTAssertEqual(msg.knownTrackerCount, 3);
    XCTAssertTrue([msg.detectedTrackers containsObject:@"Escalent"]);
}

- (void)testSendy {
    NSString *email = @"<img src=\"https://lists.panic.com/t/TfytDRucxMhTmMmeRUryNg/Bw2EZEL3ysIdV5Ql3aYwKw\" alt=\"\" style=\"width:1px;height:1px;\"/>";
    MTBBlockedMessage *msg = [[MTBBlockedMessage alloc] initWithHtml:email];
    XCTAssertEqual(msg.detectedTrackers.count, 1);
    XCTAssertEqual(msg.knownTrackerCount, 1);
    XCTAssertEqualObjects(msg.detectedTracker, @"Sendy");
}

- (void)testRFC2392EmbeddedSpacer {
    NSString *email = @"<img src=\"cid:image001.gif@01D99D4F.450764F0\" v:src=\"cid:image001.gif@01D99D4F.450764F0\" v:shapes=\"_x0000_Mail\" width=\"0\" height=\"0\" class=\"shape\" style=\"display:none;width:0;height:0\">";
    MTBBlockedMessage *msg = [[MTBBlockedMessage alloc] initWithHtml:email];
    XCTAssertEqual(msg.detectedTrackers.count, 0);
    XCTAssertEqual(msg.certainty, BLOCKING_RESULT_CERTAINTY_LOW_NO_MATCHES);
}

// expected not be marked as generic pixels
- (void)testSpacers {
    NSString *email = @"<img src=\"https://www.redditstatic.com/spacer.gif\" width=\"620\" height=\"1\" style=\"min-width:620px\" alt=\" border=\"0\" />";
    MTBBlockedMessage *msg = [[MTBBlockedMessage alloc] initWithHtml:email];
    XCTAssertEqualObjects(msg.sanitizedHtml, email);
    XCTAssertEqualObjects(msg.detectedTracker, nil);
    XCTAssertEqual(msg.certainty, BLOCKING_RESULT_CERTAINTY_LOW_NO_MATCHES);
    
    NSString *email2 = @"<img src=\"https://www.FAASafety.gov/include/lookandfeel/images/email/spacer.gif\" WIDTH=\"1\" HEIGHT=\"1\" alt=\"used for alignment\" />";
    MTBBlockedMessage *msg2 = [[MTBBlockedMessage alloc] initWithHtml:email2];
    XCTAssertEqualObjects(msg2.sanitizedHtml, email2);
    XCTAssertEqualObjects(msg2.detectedTracker, nil);
    XCTAssertEqual(msg2.certainty, BLOCKING_RESULT_CERTAINTY_LOW_NO_MATCHES);
    
    NSString *email3 = @"<img style=\"display: block;\" src=\"https://image.fidelityinvestments.com/lib/fe90157070640d7a7c/m/3/pi_svc_spacer.gif\" alt=\" height=\"10\" border=\"0\" width=\"1\">";
    MTBBlockedMessage *msg3 = [[MTBBlockedMessage alloc] initWithHtml:email3];
    XCTAssertEqualObjects(msg3.sanitizedHtml, email3);
    XCTAssertEqualObjects(msg3.detectedTracker, nil);
    XCTAssertEqual(msg3.certainty, BLOCKING_RESULT_CERTAINTY_LOW_NO_MATCHES);
    
    NSString *email4 = @"<img style=\"display:inline-block; color: #4D148C;\" alt=\"FedEx\" height=\"157\" width=\"44\" border=\"0\" src=\"http://www.fedex.com/ENS/images/fedex_collective_logo_desktop.png\">";
    MTBBlockedMessage *msg4 = [[MTBBlockedMessage alloc] initWithHtml:email4];
    XCTAssertEqualObjects(msg4.sanitizedHtml, email4);
    XCTAssertEqualObjects(msg4.detectedTracker, nil);
    XCTAssertEqual(msg4.certainty, BLOCKING_RESULT_CERTAINTY_LOW_NO_MATCHES);
    
    NSString *email5 = @"<img alt=\"FedEx\" border=\"0\" class=\"showonmobilelogo\" style=\"display:none;width:0px;max-height:0px;overflow:hidden;\" height=\"1\" width=\"1\" src=\"http://www.fedex.com/ENS/images/fedex_collective_logo_mobile.png\">";
    MTBBlockedMessage *msg5 = [[MTBBlockedMessage alloc] initWithHtml:email5];
    XCTAssertEqualObjects(msg5.sanitizedHtml, email5);
    XCTAssertEqualObjects(msg5.detectedTracker, nil);
    XCTAssertEqual(msg5.certainty, BLOCKING_RESULT_CERTAINTY_LOW_NO_MATCHES);
    
    NSString *emailPP = @"<img src=\"https://www.paypalobjects.com/digitalassets/c/system-triggered-email/n/layout/images/sidebar-gradient.png\" width=\"1\" height=\"100\" style=\"display:block;\" alt=\"\">";
    MTBBlockedMessage *msgPP = [[MTBBlockedMessage alloc] initWithHtml:emailPP];
    XCTAssertEqualObjects(msgPP.sanitizedHtml, emailPP);
    XCTAssertEqualObjects(msgPP.detectedTracker, nil);
    XCTAssertEqual(msgPP.certainty, BLOCKING_RESULT_CERTAINTY_LOW_NO_MATCHES);
}

- (void)testTwoTrackersSameVendor {
    NSString *emailPP = @"<img src=\"https://sli.komando.com/imp?s=810140&amp;e=example@gmail.com&amp;p=1647437190982&amp;stpe=default\" border=\"0\" width=\"600\" style=\"width: 100%; max-width: 600px !important;\"><img src=\"https://sli.komando.com/imp?s=810141&amp;e=example@gmail.com&amp;p=1647437190982&amp;stpe=default\" border=\"0\" width=\"600\" style=\"width: 100%; max-width: 600px !important;\">";
    MTBBlockedMessage *msg = [[MTBBlockedMessage alloc] initWithHtml:emailPP];
    XCTAssertEqualObjects(msg.sanitizedHtml,
                          @"");
    XCTAssertEqualObjects(msg.detectedTracker, @"LiveIntent");
    XCTAssertEqual(msg.certainty, BLOCKING_RESULT_CERTAINTY_CONFIDENT_HARD_MATCH);
}

- (void)test2x2TrackerVendor {
    NSString *email = @"<img src=\"https://link.runtastic.com/mo/W37jKbRMwg_645781705_2447263_458311_1086436.gif\" height=\"2\" width=\"2\" border=\"0\" alt=\"\"></body>";
    MTBBlockedMessage *msg = [[MTBBlockedMessage alloc] initWithHtml:email];
    XCTAssertEqual(msg.certainty, BLOCKING_RESULT_CERTAINTY_CONFIDENT_HARD_MATCH);
}

#pragma mark - Helpers

- (NSString*)getHTMLResourceWithFileName:(NSString*)fileName {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:fileName ofType:@"html"];
    NSData *xmlData = [NSData dataWithContentsOfFile:path];
    return [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
}
@end
