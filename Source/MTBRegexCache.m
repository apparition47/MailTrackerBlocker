//
//  RegexCache.m
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2021/03/09.
//

#import "MTBRegexCache.h"

@implementation MTBRegexCache {
    NSMutableDictionary *_cache;
}

+ (instancetype)sharedCache {
    static MTBRegexCache *sharedCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCache = [[self alloc] init];
    });
    return sharedCache;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    _cache = [[NSMutableDictionary alloc] init];
    return self;
}

- (NSRegularExpression*) regularExpressionWithPattern:(NSString*)pattern options:(NSRegularExpressionOptions)options error:(NSError**)error {
    @synchronized(self) {
        NSRegularExpression *regex = _cache[pattern];
        if (regex) {
            return regex;
        }
        regex = [NSRegularExpression regularExpressionWithPattern:pattern options:options error:&error];
        _cache[pattern] = regex;
        return regex;
    }
}
@end
