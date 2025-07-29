//
//  BBPSCheckoutLite.m
//

#import "BBPSCheckoutLite.h"
#import "BBPSUtils.h"

@implementation BBPSCheckoutLite

+ (void)presentCheckout:(UIViewController *)viewController 
                payload:(NSDictionary *)payload 
             completion:(void(^)(NSDictionary *result))completion {
    
    if (![BBPSUtils isValidPayload:payload]) {
        NSError *error = [NSError errorWithDomain:@"BBPSCheckoutLite" 
                                             code:400 
                                         userInfo:@{NSLocalizedDescriptionKey: @"Invalid payload"}];
        completion(@{@"error": error.localizedDescription});
        return;
    }
    
    NSDictionary *sanitizedPayload = [BBPSUtils sanitizePayload:payload];
    
    // BBPS-specific checkout logic
    dispatch_async(dispatch_get_main_queue(), ^{
        completion(@{@"status": @"success", @"payload": sanitizedPayload});
    });
}

@end