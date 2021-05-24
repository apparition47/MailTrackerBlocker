#import "MTBExampleClass.h"

@implementation MTBExampleClass
- (NSURL *)bundleApplicationSupportDirectory {
    NSError *error;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *applicationSupport = [manager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:false error:&error];
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    NSURL *folder = [applicationSupport URLByAppendingPathComponent:identifier];
    [manager createDirectoryAtURL:folder withIntermediateDirectories:true attributes:nil error:&error];
    return folder;
}

// this is executed after mailbundle loads
-(void)runExample {
    // CODE_SIGN_ENTITLEMENTS = Resources/Entitlements.plist was set
    
    NSString *pkgNameToCheck = @"Test.pkg";
    
    // save file to ~/Library/Containers/com.apple.mail/Data/Library/Application\ Support/com.apple.mail/Test.pkg
    NSString *urlToDownload = @"https://github.com/apparition47/MailTrackerBlocker/releases/download/0.1.1/MailTrackerBlocker-beta2.pkg";
    NSURL  *url = [NSURL URLWithString:urlToDownload];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    if ( urlData ) {
        NSURL  *filePath = [self.bundleApplicationSupportDirectory URLByAppendingPathComponent:pkgNameToCheck];

        NSLog(@"mtbbbbbb - filepath: %@", filePath);
        [urlData writeToURL:filePath atomically:NO];
        NSLog(@"mtbbbbbb - File Saved !");
    }
    
    // run NSTask
    // $ pkgutil --check-signature Test.pkg
    NSString *errorString;
    NSPipe                *outputPipe, *errorPipe;
    NSFileHandle        *outputHandle, *errorHandle;
    NSTask                *task;
    NSData                *outputData, *errorData;
    
    outputPipe = [NSPipe pipe];
    errorPipe = [NSPipe pipe];
    task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/sbin/pkgutil"];
    [task setCurrentDirectoryURL:self.bundleApplicationSupportDirectory];
    [task setArguments:@[@"--check-signature", pkgNameToCheck]];
    [task setStandardOutput: outputPipe];
    [task setStandardError: errorPipe];
    
    outputHandle = [outputPipe fileHandleForReading];
    errorHandle = [errorPipe fileHandleForReading];
    [task launch];
    
    outputData = [outputHandle readDataToEndOfFile];
    errorData = [errorHandle readDataToEndOfFile];
    if ([errorData length])
        errorString = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
    else
        errorString = nil;
    NSString *result = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];

    NSLog(@"mtbbbbbb - result %@ - error %@", result, errorString);
    // Could not open package: Test.pkg
    // doesn't seem to work
}
@end
