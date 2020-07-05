//
//  CCLog.h
//  gitVersions
//
//  Created by Koenraad Van Nieuwenhove on 26/08/08.
//  Copyright 2008 CoCoa Crumbs. All rights reserved.
//
#import <Cocoa/Cocoa.h>

// idea from http://www.borkware.com/rants/agentm/mlog/

#define CCLog(s,...)                           \
[CCLog myLog:__FILE__                      \
lineNumber:__LINE__                      \
format:(s), ##__VA_ARGS__]

@interface CCLog : NSObject
{
} 

+ (void)myLog:(char*)file
   lineNumber:(int)lineNumber
       format:(NSString*)format, ...;

@end /* interface CCLog */
