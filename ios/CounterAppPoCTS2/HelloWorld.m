//
//  HelloWorld.m
//  CounterAppPoCTS2
//
//  Created by Luis Castillo on 25/10/21.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(HelloWorld, NSObject)
RCT_EXTERN_METHOD(ShowMessageSync:(NSString *)message duration:(double *)duration)
RCT_EXTERN_METHOD(ShowMessage:(NSString *)message
                              duration:(double *)duration
                              resolve: (RCTPromiseResolveBlock)resolve
                              rejecter:(RCTPromiseRejectBlock)reject)
@end
