//
//  BBPSService.m
//

#import "BBPSService.h"
#import "BBPSConstants.h"
#import "BBPSUtils.h"

@implementation BBPSService

- (instancetype)initWithClientId:(NSString *)clientId {
    self = [super initWithClientId:clientId];
    if (self) {
        // BBPS-specific initialization
    }
    return self;
}

- (void)initiate:(UIViewController *)viewController payload:(NSDictionary *)initiationPayload callback:(BBPSServiceCallback)callback {
    [super initiate:viewController payload:initiationPayload callback:callback];
}

- (BBPSServiceEventsCallback)merchantEvent {
    return [super merchantEvent];
}

@end