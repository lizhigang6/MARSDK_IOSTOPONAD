//
//  AlexGromoreInterstitialCustomEvent.m
//  AlexGromoreMixSDKAdapter
//
//  Created by Alex on 2/1/21.
//  Copyright © 2021 Alex. All rights reserved.
//

#import "AlexGromoreInterstitialCustomEvent.h"
#import "AlexGromoreBaseManager.h"

@implementation AlexGromoreInterstitialCustomEvent

#pragma mark - BUMNativeExpressFullscreenVideoAdDelegate
/// 广告展示失败回调
/// @param fullscreenVideoAd 广告管理对象
/// @param error 展示失败的原因
- (void)nativeExpressFullscreenVideoAdDidShowFailed:(BUNativeExpressFullscreenVideoAd *_Nonnull)fullscreenVideoAd error:(NSError *_Nonnull)error {
    [AlexGromoreBaseManager AL_logMessage:[NSString stringWithFormat:@"Interstitial::nativeExpressFullscreenVideoAdDidShowFailed:error:%@", error]];
    [self trackInterstitialAdShowFailed:error];
}

/// 即将弹出广告详情页回调
/// @param fullscreenVideoAd 广告管理对象
- (void)nativeExpressFullscreenVideoAdWillPresentFullScreenModal:(BUNativeExpressFullscreenVideoAd *_Nonnull)fullscreenVideoAd {
    [AlexGromoreBaseManager AL_logMessage:@"Interstitial::nativeExpressFullscreenVideoAdWillPresentFullScreenModal:"];
}

/// 目前支持的adn:GDT
- (void)nativeExpressFullscreenVideoAdServerRewardDidSucceed:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd verify:(BOOL)verify {
    [AlexGromoreBaseManager AL_logMessage:[NSString stringWithFormat:@"Interstitial::nativeExpressFullscreenVideoAdServerRewardDidSucceed:verify:%d", verify]];
}

/// 目前支持的adn:GDT
- (void)nativeExpressFullscreenVideoAdServerRewardDidFail:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd error:(NSError *)error {
    [AlexGromoreBaseManager AL_logMessage:[NSString stringWithFormat:@"Interstitial::nativeExpressFullscreenVideoAdServerRewardDidFail:error:%@", error]];
    [self trackInterstitialAdShowFailed:error];
}

#pragma mark - BUNativeExpressFullscreenVideoAdDelegate
/**
 This method is called when video ad material loaded successfully.
 */
- (void)nativeExpressFullscreenVideoAdDidLoad:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    [AlexGromoreBaseManager AL_logMessage:@"Interstitial::nativeExpressFullscreenVideoAdDidLoad:"];
    if (self.customEventMetaDataDidLoadedBlock != nil) { self.customEventMetaDataDidLoadedBlock();}
}

/**
 This method is called when video ad materia failed to load.
 @param error : the reason of error
 */
- (void)nativeExpressFullscreenVideoAd:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error {
    [AlexGromoreBaseManager AL_logMessage:[NSString stringWithFormat:@"Interstitial::nativeExpressFullscreenVideoAd:didFailWithError:%@", error]];
    if (self.isC2SBiding && NSClassFromString(@"AlexGromoreC2SBiddingRequestManager")) {
        [NSClassFromString(@"AlexGromoreC2SBiddingRequestManager") disposeLoadFailCall:error key:kATSDKFailedToLoadInterstitialADMsg unitID:self.networkAdvertisingID];
    } else {
        [self trackInterstitialAdLoadFailed:error];
    }
}

/**
 This method is called when a nativeExpressAdView failed to render.
 @param error : the reason of error
 */
- (void)nativeExpressFullscreenVideoAdViewRenderFail:(BUNativeExpressFullscreenVideoAd *)rewardedVideoAd error:(NSError *_Nullable)error {
    [AlexGromoreBaseManager AL_logMessage:[NSString stringWithFormat:@"Interstitial::nativeExpressFullscreenVideoAdViewRenderFail:error:%@", error]];
    [self trackInterstitialAdShowFailed:error];
}

/**
 This method is called when video cached successfully.
 For a better user experience, it is recommended to display video ads at this time.
 And you can call [BUNativeExpressFullscreenVideoAd showAdFromRootViewController:].
 */
- (void)nativeExpressFullscreenVideoAdDidDownLoadVideo:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    [AlexGromoreBaseManager AL_logMessage:@"Interstitial::nativeExpressFullscreenVideoAdDidDownLoadVideo:"];
    if (self.isC2SBiding && NSClassFromString(@"AlexGromoreC2SBiddingRequestManager")) {
        id intersitiialAd = nil;
        if ([fullscreenVideoAd.mediation respondsToSelector:@selector(intersitiialProAd)]) {
            intersitiialAd = [fullscreenVideoAd.mediation performSelector:@selector(intersitiialProAd)];
        }
        if ([fullscreenVideoAd.mediation respondsToSelector:@selector(fullscreenVideoAd)] && !intersitiialAd) {
            intersitiialAd = [fullscreenVideoAd.mediation performSelector:@selector(fullscreenVideoAd)];
        }
        
        NSString * price = [NSClassFromString(@"AlexGromoreC2SBiddingRequestManager") getPriceWithAd:intersitiialAd];
        
        [NSClassFromString(@"AlexGromoreC2SBiddingRequestManager") disposeLoadSuccessCall:price customObject:fullscreenVideoAd unitID:self.networkAdvertisingID];
        self.isC2SBiding = NO;
    } else {
        [self trackInterstitialAdLoaded:fullscreenVideoAd adExtra:nil];
    }
}

/**
 This method is called when video ad slot has been shown.
 */
- (void)nativeExpressFullscreenVideoAdDidVisible:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    [AlexGromoreBaseManager AL_logMessage:@"Interstitial::nativeExpressFullscreenVideoAdDidVisible:"];
    [self trackInterstitialAdShow];
}

/**
 This method is called when video ad is clicked.
 */
- (void)nativeExpressFullscreenVideoAdDidClick:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    [AlexGromoreBaseManager AL_logMessage:@"Interstitial::nativeExpressFullscreenVideoAdDidClick:"];
    self.closeType = ATAdCloseClickcontent;
    [self trackInterstitialAdClick];
}

/**
 This method is called when the user clicked skip button.
 */
- (void)nativeExpressFullscreenVideoAdDidClickSkip:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    [AlexGromoreBaseManager AL_logMessage:@"Interstitial::nativeExpressFullscreenVideoAdDidClickSkip:"];
    self.closeType = ATAdCloseSkip;
}

/**
 This method is called when video ad is closed.
 */
- (void)nativeExpressFullscreenVideoAdDidClose:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    [AlexGromoreBaseManager AL_logMessage:@"Interstitial::nativeExpressFullscreenVideoAdDidClose:"];
    [self trackInterstitialAdClose:@{kATADDelegateExtraDismissTypeKey: self.closeType != 0 ? @(self.closeType) : @(ATAdCloseUnknow)}];
}

/**
 This method is called when video ad play completed or an error occurred.
 @param error : the reason of error
 */
- (void)nativeExpressFullscreenVideoAdDidPlayFinish:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error {
    [AlexGromoreBaseManager AL_logMessage:[NSString stringWithFormat:@"Interstitial::nativeExpressFullscreenVideoAdDidPlayFinish:didFailWithError:%@", error]];
    if (error) {
        [self trackInterstitialAdDidFailToPlayVideo:error];
    } else {
        self.closeType = ATAdCloseCountdown;
        [self trackInterstitialAdVideoEnd];
    }
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"slot_id"];
}

- (NSDictionary *)networkCustomInfo {
    BUNativeExpressFullscreenVideoAd *interstitial = self.interstitial.customObject;
    BUMRitInfo *info = [interstitial.mediation getShowEcpmInfo];
    NSMutableDictionary *extra = [AlexGromoreBaseManager AL_getExtraForRitInfo:info];
    return extra;
}

@end
