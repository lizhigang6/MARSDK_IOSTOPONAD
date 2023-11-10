//
//  AlexGromoreRewardedVideoAgainCustomEvent.m
//  AlexGromoreMixSDKAdapter
//
//  Created by Alex on 12/21/21.
//  Copyright © 2021 Alex. All rights reserved.
//

#import "AlexGromoreRewardedVideoAgainCustomEvent.h"
#import "AlexGromoreBaseManager.h"

@interface AlexGromoreRewardedVideoAgainCustomEvent ()
@property(nonatomic, strong) NSString *adNetworkRitId;
@end

@implementation AlexGromoreRewardedVideoAgainCustomEvent

- (instancetype)initWithInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    self = [super initWithInfo:serverInfo localInfo:localInfo];
    if (self != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gromoreRewardedVideoAgainRewarded:) name:kAlexGromoreRewardedVideoAgainRewardedKey object:nil];
    }
    return self;
}

- (void)gromoreRewardedVideoAgainRewarded:(NSNotification *)notification {
    [AlexGromoreBaseManager AL_logMessage:@"RewardedVideoAgain::gromoreRewardedVideoAgainRewarded:"];
    NSString *adNetworkRitId = notification.object;
    if ([self.adNetworkRitId isEqualToString:adNetworkRitId]) {
        [self trackRewardedVideoAdRewarded];
    }
}

#pragma mark - BUMNativeExpressRewardedVideoAdDelegate
/// 广告展示失败回调
/// @param rewardedVideoAd 广告管理对象
/// @param error 展示失败的原因
- (void)nativeExpressRewardedVideoAdDidShowFailed:(BUNativeExpressRewardedVideoAd *_Nonnull)rewardedVideoAd error:(NSError *_Nonnull)error {
    [AlexGromoreBaseManager AL_logMessage:[NSString stringWithFormat:@"RewardedVideoAgain::nativeExpressRewardedVideoAdDidShowFailed:error:%@",error]];
    [self trackRewardedVideoAdPlayEventWithError:error];
}

#pragma mark - BUNativeExpressRewardedVideoAdDelegate
/**
 This method is called when video ad slot has been shown.
 */
- (void)nativeExpressRewardedVideoAdDidVisible:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    [AlexGromoreBaseManager AL_logMessage:@"RewardedVideoAgain::nativeExpressRewardedVideoAdDidVisible:"];
    self.adNetworkRitId = rewardedVideoAd.mediation.getShowEcpmInfo.slotID;
    [self trackRewardedVideoAdShow];
    [self trackRewardedVideoAdVideoStart];
}

/**
 This method is called when video ad is closed.
 */
- (void)nativeExpressRewardedVideoAdDidClose:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    [AlexGromoreBaseManager AL_logMessage:@"RewardedVideoAgain::nativeExpressRewardedVideoAdDidClose:"];
    [self trackRewardedVideoAdCloseRewarded:self.rewardGranted extra:@{kATADDelegateExtraDismissTypeKey:self.closeType != 0 ? @(self.closeType) : @(ATAdCloseUnknow)}];
}

/**
 This method is called when video ad is clicked.
 */
- (void)nativeExpressRewardedVideoAdDidClick:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    [AlexGromoreBaseManager AL_logMessage:@"RewardedVideoAgain::nativeExpressRewardedVideoAdDidClick:"];
    [self trackRewardedVideoAdClick];
}

/**
 This method is called when the user clicked skip button.
 */
- (void)nativeExpressRewardedVideoAdDidClickSkip:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    [AlexGromoreBaseManager AL_logMessage:@"RewardedVideoAgain::nativeExpressRewardedVideoAdDidClickSkip:"];
    self.closeType = ATAdCloseSkip;
}

/**
 This method is called when video ad play completed or an error occurred.
 @param error : the reason of error
 */
- (void)nativeExpressRewardedVideoAdDidPlayFinish:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    [AlexGromoreBaseManager AL_logMessage:[NSString stringWithFormat:@"RewardedVideoAgain::nativeExpressRewardedVideoAdDidPlayFinish:didFailWithError:%@",error]];
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
    [AlexGromoreBaseManager AL_logMessage:[NSString stringWithFormat:@"RewardedVideoAgain::nativeExpressRewardedVideoAdServerRewardDidSucceed:verify:%d",verify]];
    if (verify) {
        [self trackRewardedVideoAdRewarded];
    }
}

/**
  Server verification which is requested asynchronously is failed.
  @param rewardedVideoAd express rewardVideo Ad
  @param error request error info
 */
- (void)nativeExpressRewardedVideoAdServerRewardDidFail:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd error:(NSError *_Nullable)error {
    [AlexGromoreBaseManager AL_logMessage:[NSString stringWithFormat:@"RewardedVideoAgain::nativeExpressRewardedVideoAdServerRewardDidFail:error:%@",error]];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"slot_id"];
}

- (NSDictionary *)networkCustomInfo {
    BURewardedVideoAd *rvAd = self.rewardedVideo.customObject;
    BUMRitInfo *info = [rvAd.mediation getShowEcpmInfo];
    NSMutableDictionary *extra = [AlexGromoreBaseManager AL_getExtraForRitInfo:info];
    extra[kATRewardedVideoAgainFlag] = @YES;
    return extra;
}

@end
