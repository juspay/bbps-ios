//
//  BBPSService.m
//

#import "BBPSService.h"
#import "BBPSServiceTenantMap.h"

@interface BBPSService()

@property (nonatomic, strong) NSString *clientId;
@property (nonatomic, copy) BBPSServiceCallback bbpsCallback;

@end

@implementation BBPSService

- (instancetype)initWithClientId:(NSString *)clientId {
    NSString *tenant = @"bbps";
    NSMutableString *updatedTenantId = tenant;
    BBPSServiceTenantMap *tenantMap = [BBPSServiceTenantMap tenantWithName:tenant];

    if (!tenant) {
        NSLog(@"Tenant '%@' not found, falling back to DEFAULT", tenant);
        tenant = [BBPSServiceTenantMap tenantWithName:@"DEFAULT"];
    }

    HyperTenantParams *tenantParams = [[HyperTenantParams alloc] init];
    self.clientId = clientId;
    tenantParams.clientId = clientId;
    tenantParams.tenantId = @"bbps";
    tenantParams.moduleNames = @[@"BBPSModule"];
    tenantParams.releaseConfigURL = @"https://airborne.juspay.in/release/juspay/bbps-ios";
    tenantParams.releaseConfigHeaders = @{ @"client_id": clientId };
//    tenantParams.baseContent = @"<html><head><title>BBPS</title></head><body><script>try{let generateCommand=function(inv,met,ret,fs,sk,v){return{invokeOn:inv,methodName:met,return:ret,fromStore:fs,storeKey:sk,values:v};};let getValues=function(n,c,t){return[{name:n,computed:c,type:t}];};const thisconst='this';const trueconst=true+'';const SELF='SELF';let shouldEnableInspect=true;const WEBVIEW='WEBVIEW';const webView='webView';const setInspectable='setInspectable:';window.webkit.messageHandlers.IOS.postMessage(JSON.stringify({methodName:'runInUI',parameters:[generateCommand(thisconst,webView,WEBVIEW,trueconst,SELF),generateCommand(thisconst,setInspectable,undefined,trueconst,WEBVIEW,getValues(shouldEnableInspect?'1':'0',undefined,'i'))]}));}catch(e){} </script><script type='text/javascript'>var headID=document.getElementsByTagName('head')[0];var newScript=document.createElement('script');newScript.type='text/javascript';newScript.id='boot_loader';function whenAvailable(name,callback){var interval=10;window.setTimeout(function(){if(window[name]){callback();}else{whenAvailable(name,callback);}},interval);}whenAvailable('JBridge',()=>{window.__OS='IOS';window.DUIGatekeeper=window.JBridge;window.loadBundle=function(){newScript.src='http://192.168.29.87:8088/payments-in.juspay.bbps-v1-index_bundle.js';newScript.onload=function(){window.JBridge.runInJuspayBrowser('onMicroAppLoaded',null,null);};headID.appendChild(newScript);};setTimeout(function(){ console.log('loading bundle'); window.loadBundle();}, 5000);});window.onerror=function(event,src,lineNo,colNo,error){};</script></body></html>";
    NSLog(@"Tenant params : %@", tenantParams.releaseConfigURL);
    self = [super initWithTenantParams:tenantParams];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleBBPSEvent:)
                                                     name:@"BBPSEventNotification"
                                                   object:nil];
    }
    return self;
}

- (void)preFetch: (NSDictionary *)payload {
    [HyperServices preFetch:payload];
}

- (NSDictionary *)createBBPSPayload:(NSDictionary *)innerPayload {

    NSString *requestId = [[NSUUID UUID] UUIDString];

    NSDictionary *outerPayload = @{
        @"service": @"in.juspay.bbps",
        @"requestId": requestId,
        @"payload": innerPayload ?: @{}
    };

    return outerPayload;
}

- (void)initiate:(UIViewController *)viewController payload:(NSDictionary *)initiationPayload callback:(BBPSServiceCallback)callback {
    self.bbpsCallback = callback;
    BBPSServiceCallback bbpsCallback = ^(NSDictionary *response) {
        NSLog(@"In bbpscallback : %@", response);
        NSString *event = response [@"event"];
        NSDictionary *payload = response[@"payload"];
        
        if ([event isEqualToString:@"initiate_result"]) {
            NSLog(@"Initiate result: %@", payload);
            callback(payload);
        } else if([event isEqualToString:@"process_result"]) {
            NSLog(@"Process result: %@", payload);
            callback(payload);
        } else if([event isEqualToString:@"refresh_auth"]) {
            NSLog(@"Refresh auth triggered");
            callback(payload);
        } else {
            NSLog(@"Invalid response from SDK. Unidentified event");
        }
    };
    [super initiate:viewController payload:[self createBBPSPayload:initiationPayload] callback:bbpsCallback];
}

- (void)handleBBPSEvent:(NSNotification *)notification {
    NSString *event = notification.userInfo[@"event"];
    NSString *payloadStr = notification.userInfo[@"payload"];

    if (self.bbpsCallback) {
        NSDictionary *parsedPayload = @{};
        if (payloadStr.length > 0) {
            NSData *data = [payloadStr dataUsingEncoding:NSUTF8StringEncoding];
            if (data) {
                NSError *jsonError;
                id decoded = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                if (!jsonError && [decoded isKindOfClass:[NSDictionary class]]) {
                    parsedPayload = decoded;
                }
            }
        }

        NSDictionary *response = @{
            @"event": event ?: @"",
            @"payload": parsedPayload,
            @"error": @NO,
            @"errorCode": @"",
            @"errorMessage": @""
        };
        self.bbpsCallback(response);
    }
}

- (void)process:(UIViewController *)viewController payload:(NSDictionary *)processPayload {
    NSLog(@"calling process with view");
    [super process:viewController processPayload:[self createBBPSPayload: processPayload]];
}

- (void)process:(NSDictionary *)processPayload {
    NSLog(@"calling process", processPayload);
    [super process:[self createBBPSPayload:processPayload]];
}

- (void)terminate {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BBPSEventNotification" object:nil];
    self.bbpsCallback = nil;
    [super terminate];
}

- (Boolean)isInitialised {
    [super isInitialised];
}

- (BBPSServiceEventsCallback)merchantEvent {
    return [super merchantEvent];
}

- (void)setDelegate:(id<BBPSServiceDelegate>)delegate {
    [super setHyperDelegate:delegate];
    _delegate = delegate;
}

@end
