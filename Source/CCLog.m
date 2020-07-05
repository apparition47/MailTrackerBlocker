//
//  CCLog.m
//  gitVersions
//
//  Created by Koenraad Van Nieuwenhove on 26/08/08.
//  Copyright 2008 CoCoa Crumbs. All rights reserved.
//
#import "CCLog.h"

#define USE_NSLOG

@implementation CCLog

+ (NSInteger)currentThreadNumber
{
    NSString    *threadString;
    NSRange      numRange;
    NSUInteger   numLength;
    
    // Somehow there doesn't seem to be an listOfArgumentsI call to return the
    // threadnumber only the name of the thread can be returned but this is NULL
    // if it is not set first!
    // Here is a bit of code to extract the thread number out of the string
    // an NSThread returns when you ask its description to be printed out
    // by NSLog. The format looks like:
    //     <NSThread: 0x10113a0>{name = (null), num = 1}
    // Basically I search for the "num = " substring, copy the remainder
    // excluding the '}' which gives me the threadnumber.
    threadString = [NSString stringWithFormat:@"%@", [NSThread currentThread]];
    
    numRange = [threadString rangeOfString:@"num = "];
    
    numLength = [threadString length] - numRange.location - numRange.length;
    numRange.location = numRange.location + numRange.length;
    numRange.length   = numLength - 1;
    
    threadString = [threadString substringWithRange:numRange];
    return [threadString integerValue];
} /* end currentThreadNumber */

+ (void)myLog:(char*)file
   lineNumber:(int)lineNumber
       format:(NSString*)format, ...
{
    va_list      listOfArguments;
    NSString    *formattedString;
    NSString    *sourceFile;
    NSString    *logString;
    
    va_start(listOfArguments, format);
    formattedString = [[NSString alloc] initWithFormat:format
                                             arguments:listOfArguments];
    va_end(listOfArguments);
    
    sourceFile = [[NSString alloc] initWithBytes:file
                                          length:strlen(file)
                                        encoding:NSUTF8StringEncoding];
    
    if([[NSThread currentThread] name] == nil)
    {
        // The thread has no name, try to find the threadnumber instead.
        logString = [NSString stringWithFormat:@"Thread %li | %s[%d] %@",
                     (long)[self currentThreadNumber],
                     [[sourceFile lastPathComponent] UTF8String],
                     lineNumber,
                     formattedString];
    }
    else
    {
        logString = [NSString stringWithFormat:@"%@ | %s[%d] %@",
                     [[NSThread currentThread] name],
                     [[sourceFile lastPathComponent] UTF8String],
                     lineNumber,
                     formattedString];
    } /* end if */
    
#ifdef  USE_NSLOG
    NSLog(@"%@", logString);
#else
    printf("%s\n", [logString UTF8String]);
#endif /* USE_NSLOG */
    
    // cleanup
} /* end myLog */

@end /* implementation CCLog */
