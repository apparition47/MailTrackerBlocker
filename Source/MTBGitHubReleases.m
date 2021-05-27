//
//  MTBGitHubReleases.m
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2021/05/18.
//

#import "MTBGitHubReleases.h"

static NSString *const MTBAppcastURLString = @"https://github.com/apparition47/MailTrackerBlocker/releases.atom";
static NSString *const MTBDownloadTagTemplateURLString = @"https://github.com/apparition47/MailTrackerBlocker/releases/download/%@/MailTrackerBlocker.pkg";

typedef void(^ParserCompletionBlock)(NSString *version, NSURL *pkgURL);

@interface MTBGitHubReleases() <NSXMLParserDelegate>
@property (nonatomic,copy) ParserCompletionBlock completionBlock;
@property (nonatomic,strong) NSXMLParser *xmlParser;
@property (nonatomic,strong) NSDateFormatter *formatter;
@property (nonatomic,strong) NSMutableArray *entries;
@property (nonatomic,strong) NSString *elementBeingParsed;
@property (nonatomic,strong) NSString *elementFinishedParsing;
@end

@implementation MTBGitHubReleases

@synthesize xmlParser;
@synthesize entries;
@synthesize completionBlock;
@synthesize elementBeingParsed;
@synthesize elementFinishedParsing;

- (instancetype)init {
    if (self = [super init]) {
        self.formatter =  [[NSDateFormatter alloc] init];;
        [self.formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        self.entries = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - Public

-(void)checkLatestWithCompletion:(void (^)(NSString *version, NSURL *pkgURL))completion {
    self.completionBlock = completion;
    
    __weak typeof(self) weakSelf = self;
    dispatch_block_t dispatch_block = ^(void) {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:MTBAppcastURLString]];
        [strongSelf.xmlParser setDelegate:strongSelf];
        [strongSelf.xmlParser parse];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            NSString *latestTag = [strongSelf.entries.firstObject valueForKey:@"tag"];
            NSURL *dlURL = [NSURL URLWithString:[NSString stringWithFormat:MTBDownloadTagTemplateURLString, latestTag]];
            self.completionBlock(latestTag, dlURL);
            strongSelf.completionBlock = nil;
        });
    };
    dispatch_queue_t dispatch_queue = dispatch_queue_create("com.onefatgiraffe.mailtrackerblocker.nsxmlparser", NULL);
    dispatch_async(dispatch_queue, dispatch_block);
}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    self.elementBeingParsed = elementName;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if(([string rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location != NSNotFound) && ![self.elementBeingParsed isEqualToString:@"entry"]) {
        return;
    }

    if ([self.elementBeingParsed isEqualToString:@"entry"]){
        NSMutableDictionary *dictUpdate = [NSMutableDictionary dictionary];
        [self.entries addObject:dictUpdate];
    }
    else if ([self.elementBeingParsed isEqualToString:@"id"]){
        NSMutableDictionary *dictUpdate = [self.entries lastObject];
        NSString *tag = [[string componentsSeparatedByString: @"/"] lastObject];
        [dictUpdate setValue:tag forKey:@"tag"];
    }
    else if([self.elementBeingParsed isEqualToString:@"title"]){
        NSMutableDictionary *dictUpdate = [self.entries lastObject];
        [dictUpdate setValue:string forKey:@"title"];
    }
    else if ([self.elementBeingParsed isEqualToString:@"updated"]){
        NSMutableDictionary *dictUpdate = [self.entries lastObject];
        NSDate *date = [self.formatter dateFromString:string];
        [dictUpdate setValue:date forKey:@"updated"];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    self.elementFinishedParsing = elementName;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
   NSLog(@"Error %ld, Description: %@, Line: %ld, Column: %ld",
      [parseError code], [[parser parserError] localizedDescription],
      [parser lineNumber], [parser columnNumber]);
}

@end
