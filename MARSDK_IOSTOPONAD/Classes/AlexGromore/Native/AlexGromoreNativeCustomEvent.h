//
//  AlexGromoreNativeCustomEvent.h
//  AlexGromoreMixSDKAdapter
//
//  Created by Alex on 2/1/21.
//  Copyright © 2021 Alex. All rights reserved.
//

#import <AnyThinkNative/AnyThinkNative.h>
#import <BUAdSDK/BUAdSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlexGromoreNativeCustomEvent : ATNativeADCustomEvent<BUMNativeAdsManagerDelegate, BUMNativeAdDelegate>
- (void)loadedWithAdsManager:(BUNativeAdsManager * _Nonnull)adsManager nativeAdViewArray:(NSArray<BUNativeAd *> * _Nullable)nativeAdViewArray;
@end

NS_ASSUME_NONNULL_END
