//
//  AlexGromoreRewardedVideoAgainCustomEvent.h
//  AlexGromoreMixSDKAdapter
//
//  Created by Alex on 12/21/21.
//  Copyright © 2021 . All rights reserved.
//

#import <AnyThinkRewardedVideo/AnyThinkRewardedVideo.h>
#import <BUAdSDK/BUAdSDK.h>

NS_ASSUME_NONNULL_BEGIN

static NSString * kAlexGromoreRewardedVideoAgainRewardedKey = @"kAlexGromoreRewardedVideoAgainRewardedKey";
@interface AlexGromoreRewardedVideoAgainCustomEvent : ATRewardedVideoCustomEvent<BURewardedVideoAdDelegate, BUNativeExpressRewardedVideoAdDelegate>
@end

NS_ASSUME_NONNULL_END
