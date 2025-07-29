//
//  BBPSUtils.h
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BBPSUtils : NSObject

+ (NSString *)getSDKVersion;
+ (BOOL)isValidPayload:(NSDictionary *)payload;
+ (NSDictionary *)sanitizePayload:(NSDictionary *)payload;

@end

NS_ASSUME_NONNULL_END