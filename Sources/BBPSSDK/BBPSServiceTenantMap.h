
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BBPSServiceTenantMap : NSObject

@property (nonatomic, readonly) NSString *tenantId;
@property (nonatomic, readonly) NSString *releaseConfigTemplateUrl;
@property (nonatomic, readonly, nullable) NSDictionary *logsEndPoints;

+ (nullable instancetype)tenantWithName:(NSString *)name;

- (nullable id)objectForKeyedSubscript:(NSString *)key;

@end

NS_ASSUME_NONNULL_END