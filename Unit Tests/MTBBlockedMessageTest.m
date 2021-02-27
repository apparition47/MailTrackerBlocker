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

- (void)testSendgrid {
    MTBBlockedMessage *msg = [[MTBBlockedMessage alloc] initWithHtml:@"<p>This is an email with a sendgrid tracker <img src='https://sendgrid.com/trk/123ef89329817898/3248932743' width='1' height='1' style='width: 1px; height: 1px;'></p>"];
    XCTAssertEqualObjects(msg.sanitizedHtml,
                          @"<p>This is an email with a sendgrid tracker </p>");
    XCTAssertEqualObjects(msg.detectedTracker, @"Sendgrid");
    XCTAssertEqual(msg.certainty, BLOCKING_RESULT_CERTAINTY_CONFIDENT_HARD_MATCH);
}

- (void)testGenericPixel {
    MTBBlockedMessage *msg = [[MTBBlockedMessage alloc] initWithHtml:@"<p>This is an email with a generic pixel tracker <img src='https://example.com/foo/123ef89329817898/3248932743' width='1' height='1' style='width: 1px; height: 1px;'></p>"];
    XCTAssertEqualObjects(msg.sanitizedHtml,
                          @"<p>This is an email with a generic pixel tracker </p>");
    XCTAssertEqual(msg.certainty, BLOCKING_RESULT_CERTAINTY_MODERATE_HEURISTIC);
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

@end
