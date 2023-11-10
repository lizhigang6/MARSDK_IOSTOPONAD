//
//  AlexGromoreRewardedVideoCustomEvent.m
//  AlexGromoreMixSDKAdapter
//
//  Created by Alex on 2/1/21.
//  Copyright © 2021 Alex. All rights reserved.
//

#import "AlexGromoreRewardedVideoCustomEvent.h"
#import "AlexGromoreBaseManager.h"

@implementation AlexGromoreRewardedVideoCustomEvent

#pragma mark - BUMNativeExpressRewardedVideoAdDelegate
/// 广告展示失败回调
/// @param rewardedVideoAd 广告管理对象
/// @param error 展示失败的原因
- (void)nativeExpressRewardedVideoAdDidShowFailed:(BUNativeExpressRewardedVideoAd *_Nonnull)rewardedVideoAd error:(NSError *_Nonnull)error {
    [AlexGromoreBaseManager AL_logMessage:[NSString stringWithFormat:@"RewardedVideo::nativeExpressRewardedVideoAdDidShowFailed:error:%@",error]];
    [self trackRewardedVideoAdPlayEventWithError:error];
}

#pragma mark - BUNativeExpressRewardedVideoAdDelegate
/**
 This method is called when video ad material loaded successfully.
 */
- (void)nativeExpressRewardedVideoAdDidLoad:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    [AlexGromoreBaseManager AL_logMessage:@"RewardedVideo::nativeExpressRewardedVideoAdDidLoad:"];
    if (self.customEventMetaDataDidLoadedBlock != nil) { self.customEventMetaDataDidLoadedBlock();}
}

/**
 This method is called when video ad materia failed to load.
 @param error : the reason of error
 */
- (void)nativeExpressRewardedVideoAd:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    [AlexGromoreBaseManager AL_logMessage:[NSString stringWithFormat:@"RewardedVideo::nativeExpressRewardedVideoAd:didFailWithError:%@",error]];
    if (self.isC2SBiding && NSClassFromString(@"AlexGromoreC2SBiddingRequestManager")) {
        [NSClassFromString(@"AlexGromoreC2SBiddingRequestManager") disposeLoadFailCall:error key:kATSDKFailedToLoadRewardedVideoADMsg unitID:self.networkAdvertisingID];
    } else {
        [self trackRewardedVideoAdLoadFailed:error];
    }
}

/**
 This method is called when cached successfully.
 For a better user experience, it is recommended to display video ads at this time.
 And you can call [BUNativeExpressRewardedVideoAd showAdFromRootViewController:].
 */
- (void)nativeExpressRewardedVideoAdDidDownLoadVideo:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    [AlexGromoreBaseManager AL_logMessage:@"RewardedVideo::nativeExpressRewardedVideoAdDidDownLoadVideo:"];
    if (self.isC2SBiding && NSClassFromString(@"AlexGromoreC2SBiddingRequestManager")) {
        NSString *price = [NSClassFromString(@"AlexGromoreC2SBiddingRequestManager") getPriceWithAd:rewardedVideoAd.mediation];
        
        [NSClassFromString(@"AlexGromoreC2SBiddingRequestManager") disposeLoadSuccessCall:price customObject:rewardedVideoAd unitID:self.networkAdvertisingID];
        self.isC2SBiding = NO;
    } else {
        [self trackRewardedVideoAdLoaded:rewardedVideoAd adExtra:nil];
    }
}

/**
 This method is called when video ad slot has been shown.
 */
- (void)nativeExpressRewardedVideoAdDidVisible:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    [AlexGromoreBaseManager AL_logMessage:@"RewardedVideo::nativeExpressRewardedVideoAdDidVisible:"];
    [self trackRewardedVideoAdShow];
    [self trackRewardedVideoAdVideoStart];
}

/**
 This method is called when video ad is closed.
 */
- (void)nativeExpressRewardedVideoAdDidClose:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    [AlexGromoreBaseManager AL_logMessage:@"RewardedVideo::nativeExpressRewardedVideoAdDidClose:"];
    [self trackRewardedVideoAdCloseRewarded:self.rewardGranted extra:@{kATADDelegateExtraDismissTypeKey:self.closeType != 0 ? @(self.closeType) : @(ATAdCloseUnknow)}];
}

/**
 This method is called when video ad is clicked.
 */
- (void)nativeExpressRewardedVideoAdDidClick:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    [AlexGromoreBaseManager AL_logMessage:@"RewardedVideo::nativeExpressRewardedVideoAdDidClick:"];
    [self trackRewardedVideoAdClick];
}

/**
 This method is called when the user clicked skip button.
 */
- (void)nativeExpressRewardedVideoAdDidClickSkip:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    [AlexGromoreBaseManager AL_logMessage:@"RewardedVideo::nativeExpressRewardedVideoAdDidClickSkip:"];
    self.closeType = ATAdCloseSkip;
}

/**
 This method is called when video ad play completed or an error occurred.
 @param error : the reason of error
 */
- (void)nativeExpressRewardedVideoAdDidPlayFinish:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    [AlexGromoreBaseManager AL_logMessage:[NSString stringWithFormat:@"RewardedVideo::nativeExpressRewardedVideoAdDidPlayFinish:didFailWithError:%@",error]];
    if (error == nil) {
        self.closeType = ATAdCloseCountdown;
        [self trackRewardedVideoAdVideoEnd];
    } else {
        [self trackRewardedVideoAdPlayEventWithError:error];
    }
}

/**
 Server verification which is requested asynchronously is succeeded. now include two v erify methods:
      1. C2C need  server verify  2. S2S don't need server verify
 @param verify :return YES when return value is 2000.
 */
- (void)nativeExpressRewardedVideoAdServerRewardDidSucceed:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd verify:(BOOL)verify {
    [AlexGromoreBaseManager AL_logMessage:[NSString stringWithFormat:@"RewardedVideo::nativeExpressRewardedVideoAdServerRewardDidSucceed:verify:%d",verify]];
    if (verify) {
        if (self.rewardGranted == NO) {
            // frist rewarded
            [self trackRewardedVideoAdRewarded];
        } else {
            // again rewarded
            [[NSNotificationCenter defaultCenter] postNotificationName:kAlexGromoreRewardedVideoAgainRewardedKey object:rewardedVideoAd.mediation.getShowEcpmInfo.slotID];
        }
    }
}

/**
  Server verification which is requested asynchronously is failed.
  @param rewardedVideoAd express rewardVideo Ad
  @param error request error info
 */
- (void)nativeExpressRewardedVideoAdServerRewardDidFail:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd error:(NSError *_Nullable)error {
    [AlexGromoreBaseManager AL_logMessage:[NSString stringWithFormat:@"RewardedVideo::nativeExpressRewardedVideoAdServerRewardDidFail:error:%@",error]];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"slot_id"];
}

- (NSDictionary *)networkCustomInfo {
    BURewardedVideoAd *rvAd = self.rewardedVideo.customObject;
    BUMRitInfo *info = [rvAd.mediation getShowEcpmInfo];
    NSMutableDictionary *extra = [AlexGromoreBaseManager AL_getExtraForRitInfo:info];
    return extra;
}

@end
