//
//  BBPSUtils.m
//

#import "BBPSUtils.h"
#import "BBPSConstants.h"

@implementation BBPSUtils

+ (NSString *)getSDKVersion {
    return BBPSSDKVersion;
}

+ (BOOL)isValidPayload:(NSDictionary *)payload {
    if (!payload || ![payload isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    // Add specific validation logic for BBPS payloads
    return YES;
}

+ (NSDictionary *)sanitizePayload:(NSDictionary *)payload {
    if (![self isValidPayload:payload]) {
        return @{};
    }
    
    NSMutableDictionary *sanitizedPayload = [payload mutableCopy];
    // Add sanitization logic here
    
    return [sanitizedPayload copy];
}

@end