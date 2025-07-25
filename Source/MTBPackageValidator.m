//
//  MTBPackageValidator.m
//  MailTrackerBlocker
//
//  Created by Aaron Lee on 2021/05/27.
//

#import "MTBPackageValidator.h"
#import <xar/xar.h>

// Use the public key of your Developer ID Installer
// Derived from PKCS#1 base64 enc output from SecKeyCopyExternalRepresentation of my Developer ID Installer (XXX)
// OR command to get without ASN.1 parsing output:
// $ security find-certificate -c "Developer ID Installer: Name (TEAM_ID)" -p | openssl x509 -pubkey -noout | openssl asn1parse -strparse 19 -noout -out - | base64
const NSString *pinnedDevIDInstallerPKCS1PubKey = @"MIIBCgKCAQEAxTrGKLRw9XGmHprzbVYQyvApHGlqz7lm0/P3VOMUqHcvZR/hnL3qrM7BISbyqbFFygFrpEiy1HBwbGKPEa3WOaxo+FWFK1EuVPLCWX45JA7uyc5xusdcPjnYWkPeZ3teaRfEKPvTZGpKs33iUmfwNu+3xFH7kqBJjacV3IPn25rmQDsoEirfy0te8Tjxzj6ORJUlwcNn1qjjdOLwDhRAYZrskGFNE2ZUQ26iVHW0/PCt8B4zQNyujwOe80Sw14S1pw+MLUw2JSbQ/hKsn4iWAnWRmNh1zkjlwwQf8l5bSa444bpaXqUaTcKvBd/iEehlXfSkoTXf6Fdr/+QL9xYfnwIDAQAB";

@implementation MTBPackageValidator
+(BOOL)isPkgSignatureValidAtURL:(NSURL *)url {
    if (@available(macOS 10.12, *)) {} else
        return YES;
    
    OSStatus err = noErr;
    xar_t pkg = NULL;
    xar_signature_t sig = NULL;
    int32_t ncerts = 0;
    const uint8_t *data = NULL;
    uint32_t len = 0;
    SecCertificateRef certRef = NULL;

    // read pkg file
    pkg = xar_open([url.path cStringUsingEncoding:NSUTF8StringEncoding], READ);
    if (pkg == NULL) {
        NSLog(@"error opening Xar in path");
        return NO;
    }

    sig = xar_signature_first(pkg);
    if (sig == NULL) {
        NSLog(@"error getting xar signature in path");
        return NO;
    }
    
    ncerts = xar_signature_get_x509certificate_count(sig);
    
    // iterate all (usually 3) X509 certs
    for (int32_t i = 0; i < ncerts; i++) {
        if (xar_signature_get_x509certificate_data(sig, i, &data, &len) == -1) {
            NSLog(@"Unable to extract certificate data/xar signature in path");
            return NO;
        }

        const CSSM_DATA crt = { (CSSM_SIZE) len, (uint8_t *) data };
        err = SecCertificateCreateFromData(&crt, CSSM_CERT_X_509v3, CSSM_CERT_ENCODING_DER, &certRef);
        
        // get public key
        SecKeyRef secKeyRef;
        SecCertificateCopyPublicKey(certRef, &secKeyRef);
        
//        CFStringRef summaryRef = SecCertificateCopySubjectSummary(certRef);
//        NSLog(@"Subject: %@", summaryRef);
//        CFRelease(summaryRef);
        
        // get base64 encoded PKCS#1 AES
        CFErrorRef error = NULL;
        CFDataRef dlData = SecKeyCopyExternalRepresentation(secKeyRef, &error);
        NSString *base64PkgPubKey = [(__bridge NSData*)dlData base64EncodedStringWithOptions:0];
        CFRelease(dlData);
        
        if ([pinnedDevIDInstallerPKCS1PubKey isEqualToString:base64PkgPubKey])
            return YES;
    }
    return NO;
}
@end
