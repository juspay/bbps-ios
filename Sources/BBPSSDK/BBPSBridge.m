//
//  BBPSBridge.m
//  BBPSSDK
//
//  Created by pawan singh on 11/12/25.
//

#import "BBPSBridge.h"
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonHMAC.h>
#import <Photos/Photos.h>

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

- (NSString *)onBBPSEvent:(NSString *)event :(NSString *)payload {
    NSDictionary *userInfo = @{
        @"event": event ?: @"",
        @"payload": payload ?: @""
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BBPSEventNotification" object:nil userInfo:userInfo];
    return @"true";
}

- (NSString*)saveImage:(NSString *)viewId :(NSString *)callback {
    UIView *parentView = [[self.bridgeComponent getContainerView] viewWithTag:[viewId intValue]];
    if (parentView == nil || ![parentView isKindOfClass:[UIView class]]){
//        [self invokeDUICallback:callback withValue:@"{\"error\":\"true\",\"data\":\"invalid viewId\"}"];
        return @"false";
    }

    UIImage *image = [self captureView:parentView];
    [self saveImageToPhotos:image];
    return @"true";
}

- (UIImage *)captureView:(UIView *)view {

    if (!view) return nil;

    [view layoutIfNeeded];

    UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat defaultFormat];
    format.opaque = YES;
    format.scale = UIScreen.mainScreen.scale;

    UIGraphicsImageRenderer *renderer =
        [[UIGraphicsImageRenderer alloc] initWithSize:view.bounds.size
                                               format:format];

    UIImage *image =
        [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull context) {
            [view drawViewHierarchyInRect:view.bounds
                       afterScreenUpdates:YES];
        }];

    return image;
}

- (void)saveImageToPhotos:(UIImage *)image {

    if (!image) {
        NSLog(@"Image is nil");
        return;
    }

    [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelAddOnly
                                                handler:^(PHAuthorizationStatus status) {

        if (status == PHAuthorizationStatusAuthorized ||
            status == PHAuthorizationStatusLimited) {

            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                [PHAssetChangeRequest creationRequestForAssetFromImage:image];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {

                dispatch_async(dispatch_get_main_queue(), ^{
                    if (success) {
                        NSLog(@"Saved successfully");
                    } else {
                        NSLog(@"Save failed: %@", error.localizedDescription);
                    }
                });
            }];

        } else {
            NSLog(@"Permission denied");
        }
    }];
}

- (BOOL)isUpiUrlWhitelisted:(NSString *)urlString {
    NSArray<NSString *> *whitelistedSchemes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"LSApplicationQueriesSchemes"] ?: @[];
    for (NSString *scheme in whitelistedSchemes) {
        NSString *schemePrefix = [scheme stringByAppendingString:@"://"];
        if ([urlString hasPrefix:schemePrefix]) {
            return YES;
        }
    }
    return NO;
}

- (void)openUpiIntent:(NSString *)upiIntentUrl {
    if (upiIntentUrl == nil || upiIntentUrl.length == 0) return;

    if (![self isUpiUrlWhitelisted:upiIntentUrl]) return;

    NSURL *appURL = [NSURL URLWithString:upiIntentUrl];
    if (appURL == nil) return;

    dispatch_async(dispatch_get_main_queue(), ^{
        if ([[UIApplication sharedApplication] canOpenURL:appURL]) {
            [[UIApplication sharedApplication] openURL:appURL options:@{} completionHandler:nil];
        }
    });
}


@end
