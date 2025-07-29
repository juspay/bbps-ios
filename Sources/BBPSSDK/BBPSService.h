//
//  BBPSService.h
//

#import <Foundation/Foundation.h>
#import <HyperSDK/Hyper.h>

NS_ASSUME_NONNULL_BEGIN

typedef HyperSDKCallback BBPSServiceCallback;

typedef HyperEventsCallback BBPSServiceEventsCallback;

@protocol BBPSServiceDelegate <HyperDelegate>

@end

@interface BBPSService : HyperServices

@property (nonatomic, weak) id <BBPSServiceDelegate> _Nullable delegate;

+ (void)preFetch:(NSDictionary *)data __unavailable;

- (instancetype _Nonnull)initWithClientId:(NSString * _Nonnull)clientId;

- (void)initiate:(UIViewController * _Nonnull)viewController payload:(NSDictionary * _Nonnull)initiationPayload callback:(BBPSServiceCallback _Nonnull)callback;

- (BBPSServiceEventsCallback _Nullable)merchantEvent;

@end

NS_ASSUME_NONNULL_END