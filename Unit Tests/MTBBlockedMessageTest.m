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
    NSString *cleanHTML = @"<p>This is an email without any trackers <img src='https://example.com/foo.png' width='32' height='16' style='width: 32px; height: 16px; border: 1px solid gray;'> blah </p>";
    XCTAssertEqualObjects([[MTBBlockedMessage alloc] initWithHtml:cleanHTML].sanitizedHtml,
                   cleanHTML);
    XCTAssertEqual([[MTBBlockedMessage alloc] initWithHtml:cleanHTML].sanitizedHtml,
                   cleanHTML,
                   @"Original string should be referenced directly for clean HTML");
}

- (void)testGoogleAnalytics {
    MTBBlockedMessage *msg = [[MTBBlockedMessage alloc] initWithHtml:@"<p>This is an email with a google tracker <img alt="" height=1 width=3 src=https://notifications.google.com/g/img/AD-FnEzt8doYQCTNQv1w6jsjHDU6Kh6lId34t0STSV3ydKTDIw.gif></p>"];
    XCTAssertEqualObjects(msg.sanitizedHtml,
                          @"<p>This is an email with a google tracker <img alt="" height=1 width=3 src=https://></p>");
    XCTAssertEqualObjects(msg.detectedTracker, @"Google");
    XCTAssertEqual(msg.certainty, BLOCKING_RESULT_CERTAINTY_CONFIDENT_HARD_MATCH);
}

- (void)testSendgrid {
    MTBBlockedMessage *msg = [[MTBBlockedMessage alloc] initWithHtml:@"<p>This is an email with a sendgrid tracker <img src='https://sendgrid.com/trk/123ef89329817898/3248932743' width='1' height='1' style='width: 1px; height: 1px;'></p>"];
    XCTAssertEqualObjects(msg.sanitizedHtml,
                          @"<p>This is an email with a sendgrid tracker </p>");
    XCTAssertEqualObjects(msg.detectedTracker, @"Sendgrid");
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
    XCTAssertEqualObjects(msg.detectedTracker, @"Sendgrid"); // Or Adobe? Depends on dictionary key order
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
