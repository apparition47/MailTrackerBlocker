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
}

- (void)testGoogleAnalytics {
    MTBBlockedMessage *msg = [[MTBBlockedMessage alloc] initWithHtml:@"<p>This is an email with a google tracker <img alt="" height=1 width=3 src=https://notifications.google.com/g/img/AD-FnEzt8doYQCTNQv1w6jsjHDU6Kh6lId34t0STSV3ydKTDIw.gif></p>"];
    XCTAssertEqualObjects(msg.sanitizedHtml,
                          @"<p>This is an email with a google tracker <img alt="" height=1 width=3 src=https://></p>");
    XCTAssertEqualObjects(msg.detectedTracker, @"Google");
    XCTAssertEqual(msg.certainty, BLOCKING_RESULT_CERTAINTY_CONFIDENT_HARD_MATCH);
}

- (void)testAwsTrack {
    MTBBlockedMessage *msg = [[MTBBlockedMessage alloc] initWithHtml:@"<p><a class=\"cta-btn\" href=\"http://qpvvmjwx.r.us-east-1.awstrack.me/L0/http:%2F%2Fmastercardidps.idprotectiononline.com%2Falerts%2Fhistory.html%3Flang=3Den_US%26utm_source=3Demail%26utm_medium=3Demail%26utm_campaign=3Didp_standard_emails%26utm_content=3D44a%2509Identity%2520Monitoring%2520Alert/1/01000178626eb1e0-f1b813fc-c0a8-4ba5-90af-b39d859905cf-000000/27r5oe9sP7Z0DFVB_WeA7aWcx2Y=3D206\">VIEW MY ALERT</a> <img alt=\"\" src=\"http://qpvvmjwx.r.us-east-1.awstrack.me/I0/01000178626eb1e0-f1b813fc-c0a8-4ba5-90af-b39d859905cf-000000/2FKwVZSzpKPUSLDQmdmviCr5aC0206\" style=\"display: none; width: 1px; height: 1px;\"></p>"];
    XCTAssertEqualObjects(msg.sanitizedHtml,
                          @"<p><a class=\"cta-btn\" href=\"http://qpvvmjwx.r.us-east-1.awstrack.me/L0/http:%2F%2Fmastercardidps.idprotectiononline.com%2Falerts%2Fhistory.html%3Flang=3Den_US%26utm_source=3Demail%26utm_medium=3Demail%26utm_campaign=3Didp_standard_emails%26utm_content=3D44a%2509Identity%2520Monitoring%2520Alert/1/01000178626eb1e0-f1b813fc-c0a8-4ba5-90af-b39d859905cf-000000/27r5oe9sP7Z0DFVB_WeA7aWcx2Y=3D206\">VIEW MY ALERT</a> </p>");
    XCTAssertEqualObjects(msg.detectedTracker, @"Amazon SES");
    XCTAssertEqual(msg.certainty, BLOCKING_RESULT_CERTAINTY_CONFIDENT_HARD_MATCH);
}

- (void)testSendgrid {
    MTBBlockedMessage *msg = [[MTBBlockedMessage alloc] initWithHtml:@"<p>This is an email with a sendgrid tracker <img src='https://sendgrid.com/trk/123ef89329817898/3248932743' width='1' height='1' style='width: 1px; height: 1px;'></p>"];
    XCTAssertEqualObjects(msg.sanitizedHtml,
                          @"<p>This is an email with a sendgrid tracker </p>");
    XCTAssertEqualObjects(msg.detectedTracker, @"SendGrid");
    XCTAssertEqual(msg.certainty, BLOCKING_RESULT_CERTAINTY_CONFIDENT_HARD_MATCH);
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

- (void)testMultiplePixels {
    MTBBlockedMessage *msg = [[MTBBlockedMessage alloc] initWithHtml:@"<p>This is an email with multiple generic pixel trackers <img src='https://example.com/foo/123ef89329817898/3248932743' width='1' height='1' style='width: 1px; height: 1px;'></p>\n<img src='https://foo.com/bar/xyzsdfji' style='width: 1px; height: 1px;'>"];
    XCTAssertEqualObjects(msg.sanitizedHtml,
                          @"<p>This is an email with multiple generic pixel trackers </p>\n");
    XCTAssertEqual(msg.certainty, BLOCKING_RESULT_CERTAINTY_MODERATE_HEURISTIC);
}

- (void)testMultipleTrackers {
    MTBBlockedMessage *msg = [[MTBBlockedMessage alloc] initWithHtml:@"<p>This is an email with sendgrid and adobe trackers <img src='https://sendgrid.net/trk/123ef89329817898/3248932743' width='1' height='1' style='width: 1px; height: 1px;'></p>\n<img src='https://demex.com/123456' style='width: 1px; height: 1px;'>"];
    XCTAssertEqualObjects(msg.sanitizedHtml,
                          @"<p>This is an email with sendgrid and adobe trackers </p>\n");
    XCTAssertEqualObjects(msg.detectedTracker, @"SendGrid");
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

- (NSString*)getHTMLResourceWithFileName:(NSString*)fileName {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:fileName ofType:@"html"];
    NSData *xmlData = [NSData dataWithContentsOfFile:path];
    return [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
}
@end
