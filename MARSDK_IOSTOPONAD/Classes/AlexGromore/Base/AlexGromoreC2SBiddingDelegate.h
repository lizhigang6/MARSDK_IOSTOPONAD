//
//  AlexGromoreC2SBiddingDelegate.h
//  AlexGromoreMixSDKAdapter
//
//  Created by Alex on 5/13/22.
//  Copyright © 2022 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BUAdSDK/BUAdSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlexGromoreC2SBiddingDelegate : NSObject<BUSplashZoomOutDelegate, BUMSplashAdDelegate, BURewardedVideoAdDelegate, BUMNativeExpressBannerViewDelegate, BUMNativeAdsManagerDelegate, BUMNativeAdDelegate, BUNativeExpressFullscreenVideoAdDelegate>
@property (nonatomic, strong) NSString *unitID;
@end

NS_ASSUME_NONNULL_END
