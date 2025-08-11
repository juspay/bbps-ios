//
//  BBPSService.m
//

#import "BBPSService.h"
#import "BBPSServiceTenantMap.h"

@interface BBPSService()

@property (nonatomic, strong) NSString *clientId;

@end

@implementation BBPSService

- (instancetype)initWithClientId:(NSString *)clientId {
    NSString *tenant = @"defaultTenant";
    NSMutableString *updatedTenantId = tenant;
    BBPSServiceTenantMap *tenantMap = [BBPSServiceTenantMap tenantWithName:tenant];

    if (!tenant) {
        NSLog(@"Tenant '%@' not found, falling back to DEFAULT", tenant);
        tenant = [BBPSServiceTenantMap tenantWithName:@"DEFAULT"];
    }

    HyperTenantParams *tenantParams = [[HyperTenantParams alloc] init];
    self.clientId = clientId;
    tenantParams.clientId = clientId;
    tenantParams.tenantId = tenantMap.tenantId;
    tenantParams.releaseConfigURL = tenantMap.releaseConfigTemplateUrl;

    self = [super initWithTenantParams:tenantParams];
    if (self) {

    }
    return self;
}

- (void)initiate:(UIViewController *)viewController payload:(NSDictionary *)initiationPayload callback:(BBPSServiceCallback)callback {
    [super initiate:viewController payload:initiationPayload callback:callback];
}

- (BBPSServiceEventsCallback)merchantEvent {
    return [super merchantEvent];
}

- (void)setDelegate:(id<BBPSServiceDelegate>)delegate {
    [super setHyperDelegate:delegate];
    _delegate = delegate;
}

@end
