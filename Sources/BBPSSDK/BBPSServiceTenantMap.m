
#import "BBPSServiceTenantMap.h"

@implementation BBPSServiceTenantMap

static NSMutableDictionary<NSString *, BBPSServiceTenantMap *> *_tenantRegistry = nil;

+ (void)initialize {
    if (self == [BBPSServiceTenantMap class]) {
        _tenantRegistry = [[NSMutableDictionary alloc] init];
        [self registerDefaultTenants];
    }
}

+ (void)registerDefaultTenants {
    // Try to load from JSON first, fallback to hardcoded if fails
    if (![self registerTenantsFromJSONFile:@"tenants_config"]) {
        // register with some default config
    }
}

+ (BOOL)registerTenantsFromJSONFile:(NSString *)fileName {
    NSString *filePath = [[NSBundle bundleForClass:self] pathForResource:fileName ofType:@"json"];;
    if (!filePath) {
        NSLog(@"Could not find JSON file: %@", fileName);
        return NO;
    }
    
    NSError *error;
    NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
    if (!jsonData) {
        NSLog(@"Could not read JSON file: %@", fileName);
        return NO;
    }
    
    NSDictionary *tenantsDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:0
                                                                  error:&error];
    if (error) {
        NSLog(@"Error parsing JSON: %@", error.localizedDescription);
        return NO;
    }
    
    if (![tenantsDict isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Invalid JSON structure - root should be a dictionary");
        return NO;
    }
    
    // Single iteration through all tenants
    for (NSString *tenantName in tenantsDict) {
        NSDictionary *tenantConfig = tenantsDict[tenantName];
        [self registerTenantWithName:tenantName fromConfig:tenantConfig];
    }
    return YES;
}

+ (void)registerTenantWithName:(NSString *)tenantName fromConfig:(NSDictionary *)tenantConfig {
    if (![tenantConfig isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Skipping invalid tenant configuration for %@: %@", tenantName, tenantConfig);
        return;
    }
    
    NSString *tenantId = tenantConfig[@"tenantId"];
    NSString *releaseConfigTemplateUrl = tenantConfig[@"releaseConfigTemplateUrl"];
    id logsEndPoints = tenantConfig[@"logsEndPoints"];
    
    // Convert NSNull to nil
    if ([logsEndPoints isKindOfClass:[NSNull class]]) {
        logsEndPoints = nil;
    }
    
    // Validate required fields
    if (!tenantId || !releaseConfigTemplateUrl) {
        NSLog(@"Skipping tenant '%@' - missing required fields (tenantId: %@, releaseConfigTemplateUrl: %@)",
              tenantName, tenantId, releaseConfigTemplateUrl);
        return;
    }
    
    [self registerTenantWithName:tenantName
                        tenantId:tenantId
        releaseConfigTemplateUrl:releaseConfigTemplateUrl
                   logsEndPoints:logsEndPoints];
}

- (instancetype)initWithTenantId:(NSString *)tenantId
            releaseConfigTemplateUrl:(NSString *)releaseConfigTemplateUrl
                       logsEndPoints:(nullable NSDictionary *)logsEndPoints {
    self = [super init];
    if (self) {
        _tenantId = [tenantId copy];
        _releaseConfigTemplateUrl = [releaseConfigTemplateUrl copy];
        _logsEndPoints = [logsEndPoints copy];
    }
    return self;
}

+ (void)registerTenantWithName:(NSString *)name
                      tenantId:(NSString *)tenantId
      releaseConfigTemplateUrl:(NSString *)releaseConfigTemplateUrl
                 logsEndPoints:(nullable NSDictionary *)logsEndPoints {
    
    id tenant = [[self alloc]
                                    initWithTenantId:tenantId
                                    releaseConfigTemplateUrl:releaseConfigTemplateUrl
                                    logsEndPoints:logsEndPoints];
    
    @synchronized(_tenantRegistry) {
        _tenantRegistry[name] = tenant;
    }
}

+ (nullable instancetype)tenantWithName:(NSString *)name {
    @synchronized(_tenantRegistry) {
        return _tenantRegistry[name];
    }
}

// Dictionary-style access
- (nullable id)objectForKeyedSubscript:(NSString *)key {
    return [self valueForKey:key];
}

- (nullable id)valueForKey:(NSString *)key {
    if ([key isEqualToString:@"tenantId"]) {
        return self.tenantId;
    } else if ([key isEqualToString:@"releaseConfigTemplateUrl"]) {
        return self.releaseConfigTemplateUrl;
    } else if ([key isEqualToString:@"logsEndPoints"]) {
        return self.logsEndPoints;
    }
    return [super valueForKey:key];
}

@end