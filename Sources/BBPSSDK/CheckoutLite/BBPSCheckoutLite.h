//
//  BBPSCheckoutLite.h
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BBPSCheckoutLite : NSObject

+ (void)presentCheckout:(UIViewController *)viewController 
                payload:(NSDictionary *)payload 
             completion:(void(^)(NSDictionary *result))completion;

@end

NS_ASSUME_NONNULL_END