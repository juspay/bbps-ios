//
//  BBPSBridge.h
//  BBPSSDK
//
//  Created by pawan singh on 11/12/25.
//

#import <Foundation/Foundation.h>
#import <HyperSDK/HyperSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface BBPSBridge : NSObject

- (void)setBridgeComponent:(id<BridgeComponent>)component;
- (nullable NSString *)generateSignature:(NSString *)sessionKey
                                        :(NSString *)apiPath
                                        :(NSString *)timestamp
                                        :(NSString *)data;
- (NSString *)base64Encode:(NSString *)data;


@end

NS_ASSUME_NONNULL_END
