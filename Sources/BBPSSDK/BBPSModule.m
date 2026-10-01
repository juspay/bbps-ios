//
//  BBPSModule.m
//  BBPSSDK
//
//  Created by pawan singh on 11/12/25.
//

#import "BBPSModule.h"

@interface BBPSModule()

@property (nonatomic, strong) BBPSBridge *bbpsBridge;

@end

@implementation BBPSModule

- (instancetype)init {
    self = [super init];
    if(self) {
        self.bbpsBridge = [[BBPSBridge alloc] init];
    }
    return self;
}

- (void)setBridgeComponent:(id<BridgeComponent>)bridgeComponent {
    [self.bbpsBridge setBridgeComponent:bridgeComponent];
}

- (NSArray<NSObject *> *)getJSIntefaces {
    return @[self.bbpsBridge];
}

- (NSDictionary<NSString *, NSObject *> *)getNamedJsInterfaces {
    return @{@"BBPSBridge": self.bbpsBridge};
}

- (NSArray<NSString *> *)getEventsToWhitelist {
    return @[@"DO_PAYMENT"];
}

- (void)terminate {
    // Implementation here
}

@end
