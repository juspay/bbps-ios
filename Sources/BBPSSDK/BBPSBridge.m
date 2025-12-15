//
//  BBPSBridge.m
//  BBPSSDK
//
//  Created by pawan singh on 11/12/25.
//

#import "BBPSBridge.h"
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonHMAC.h>

@interface BBPSBridge ()
@property (nonatomic, strong) id<BridgeComponent> bridgeComponent;

@end

@implementation BBPSBridge

- (void) dealloc {
    _bridgeComponent = nil;
}

- (NSString *)generateSignature:(NSString *)sessionKey :(NSString *)apiPath :(NSString *)timestamp :(NSString *)data
  {
      // Build base string
      NSMutableString *baseString = [NSMutableString string];
      [baseString appendString:apiPath];
      [baseString appendString:timestamp];
      [baseString appendString:data];

      NSLog(@"pawan >>> %@", baseString);

      // Convert session key to bytes
      NSData *keyData = [sessionKey dataUsingEncoding:NSUTF8StringEncoding];
      NSData *msgData = [baseString dataUsingEncoding:NSUTF8StringEncoding];

      // HMAC-SHA256
      unsigned char hmac[CC_SHA256_DIGEST_LENGTH];
      CCHmac(kCCHmacAlgSHA256,
             keyData.bytes,
             keyData.length,
             msgData.bytes,
             msgData.length,
             hmac);

      // Convert to hex string
      NSMutableString *hexSignature = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
      for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
          [hexSignature appendFormat:@"%02x", hmac[i]];  // lowercase hex
      }

      return hexSignature;
  }

- (NSString *)base64Encode:(NSString *)data {
    if (data == nil) return nil;

    NSData *rawData = [data dataUsingEncoding:NSUTF8StringEncoding];
    if (!rawData) return nil;

    // Equivalent to Base64.NO_WRAP — no newlines
    NSString *encoded = [rawData base64EncodedStringWithOptions:0];

    return encoded;
}


@end
