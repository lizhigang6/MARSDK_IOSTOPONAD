//
//  AlexGromoreSplashCustomEvent.h
//  AlexGromoreMixSDKAdapter
//
//  Created by Alex on 2/1/21.
//  Copyright © 2021 . All rights reserved.
//

#import <AnyThinkSplash/AnyThinkSplash.h>
#import <BUAdSDK/BUAdSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlexGromoreSplashCustomEvent : ATSplashCustomEvent<BUMSplashAdDelegate, BUSplashCardDelegate, BUSplashZoomOutDelegate>
@end

NS_ASSUME_NONNULL_END
