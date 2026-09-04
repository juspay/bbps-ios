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
#import <HyperCore/HyperCore.h>

@interface BBPSBridge ()
@property (nonatomic, strong) id<BridgeComponent> bridgeComponent;

// HyperUPI state
@property (nonatomic, strong) HyperServices *hyperUPIServices;
@property (nonatomic, copy)   NSString *upiInitiateCallback;
@property (nonatomic, copy)   NSString *upiProcessCallback;

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

// MARK: - HyperUPI bridge methods

- (void)isHyperUPIPresent:(NSString *)callback {
    NSString *result = (NSClassFromString(@"HyperUPI.HyperUPI") != nil) ? @"true" : @"false";
    [self invokeCallback:callback withJSON:result];
}

- (void)initiateHyperUPI:(NSString *)payload :(NSString *)callback {
    UIViewController *vc = [self.bridgeComponent getBaseViewController];
    if (!vc) {
        NSString *errJson = @"{\"error\":true,\"event\":\"initiate_result\",\"payload\":{\"error\":true,\"errorMessage\":\"No base view controller available\"}}";
        [self invokeCallback:callback withJSON:errJson];
        return;
    }

    self.upiInitiateCallback = callback;
    self.hyperUPIServices = [[HyperServices alloc] init];

    NSError *jsonError = nil;
    NSData *data = [payload dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *params = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
    if (jsonError || !params) {
        NSString *errJson = @"{\"error\":true,\"event\":\"initiate_result\",\"payload\":{\"error\":true,\"errorMessage\":\"Invalid payload JSON\"}}";
        [self invokeCallback:callback withJSON:errJson];
        return;
    }

    __weak typeof(self) weakSelf = self;
    [self.hyperUPIServices initiate:vc payload:params callback:^(NSDictionary *response) {
        [weakSelf routeHyperUPIEvent:response];
    }];
}

- (void)processHyperUPI:(NSString *)payload :(NSString *)callback {
    if (!self.hyperUPIServices || ![self.hyperUPIServices isInitialised]) {
        NSString *errJson = @"{\"error\":true,\"event\":\"process_result\",\"payload\":{\"error\":true,\"errorMessage\":\"HyperUPI not initiated\"}}";
        [self invokeCallback:callback withJSON:errJson];
        return;
    }

    self.upiProcessCallback = callback;

    NSError *jsonError = nil;
    NSData *data = [payload dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *params = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
    if (jsonError || !params) {
        NSString *errJson = @"{\"error\":true,\"event\":\"process_result\",\"payload\":{\"error\":true,\"errorMessage\":\"Invalid payload JSON\"}}";
        [self invokeCallback:callback withJSON:errJson];
        return;
    }

    [self.hyperUPIServices process:params];
}

// MARK: - Private helpers

- (void)routeHyperUPIEvent:(NSDictionary *)event {
    NSString *eventName = event[@"event"] ?: @"";
    NSString *token;

    if ([eventName isEqualToString:@"process_result"]) {
        token = self.upiProcessCallback;
    } else {
        // initiate_result, session_expiry, and any other event route to initiate callback
        token = self.upiInitiateCallback;
    }

    if (!token) {
        NSLog(@"[BBPSBridge] No callback token for HyperUPI event: %@", eventName);
        return;
    }

    NSString *jsonStr = [HPJPHelpers dictionaryToString:event];
    [self invokeCallback:token withJSON:jsonStr];
}

- (void)invokeCallback:(NSString *)callback withJSON:(NSString *)jsonStr {
    if (!callback || !self.bridgeComponent) return;
    NSString *jsStr = [HPJPHelpers responseStringForCallback:callback andData:@[jsonStr]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.bridgeComponent executeOnWebView:jsStr];
    });
}

@end
