//
//  AlexGromoreRewardedVideoCustomEvent.h
//  AlexGromoreMixSDKAdapter
//
//  Created by Alex on 2/1/21.
//  Copyright © 2021 . All rights reserved.
//

#import <AnyThinkRewardedVideo/AnyThinkRewardedVideo.h>
#import "AlexGromoreRewardedVideoAgainCustomEvent.h"
#import <BUAdSDK/BUAdSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlexGromoreRewardedVideoCustomEvent : ATRewardedVideoCustomEvent<BUMNativeExpressRewardedVideoAdDelegate>
@property (nonatomic, strong) AlexGromoreRewardedVideoAgainCustomEvent *againCustomEvent;
@end

NS_ASSUME_NONNULL_END
