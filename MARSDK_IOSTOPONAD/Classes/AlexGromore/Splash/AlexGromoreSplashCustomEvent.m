//
//  AlexGromoreSplashCustomEvent.m
//  AlexGromoreMixSDKAdapter
//
//  Created by Alex on 2/1/21.
//  Copyright © 2021 Alex. All rights reserved.
//

#import "AlexGromoreSplashCustomEvent.h"
#import "AlexGromoreBaseManager.h"

@implementation AlexGromoreSplashCustomEvent

#pragma mark - BUMSplashAdDelegate
/// 广告展示失败回调
/// @param splashAd 广告管理对象
/// @param error 展示失败原因
- (void)splashAdDidShowFailed:(BUSplashAd *_Nonnull)splashAd error:(NSError *)error {
    [AlexGromoreBaseManager AL_logMessage:[NSString stringWithFormat:@"Splash::splashAdDidShowFailed:error:%@",error]];
    [self trackSplashAdShowFailed:error];
}

/// 广告即将展示广告详情页回调
/// @param splashAd 广告管理对象
- (void)splashAdWillPresentFullScreenModal:(BUSplashAd *)splashAd {
    [AlexGromoreBaseManager AL_logMessage:@"Splash::splashAdWillPresentFullScreenModal:"];
}

#pragma mark - BUSplashAdDelegate
/// This method is called when material load successful
- (void)splashAdLoadSuccess:(BUSplashAd *)splashAd {
    [AlexGromoreBaseManager AL_logMessage:@"Splash::splashAdLoadSuccess:"];
    if (self.isC2SBiding && NSClassFromString(@"AlexGromoreC2SBiddingRequestManager")) {
        NSString *price = [NSClassFromString(@"AlexGromoreC2SBiddingRequestManager") getPriceWithAd:splashAd.mediation];
        
        [NSClassFromString(@"AlexGromoreC2SBiddingRequestManager") disposeLoadSuccessCall:price customObject:splashAd unitID:self.networkAdvertisingID];
        self.isC2SBiding = NO;
    } else {
        [self trackSplashAdLoaded:splashAd adExtra:nil];
    }
}

/// This method is called when material load failed
- (void)splashAdLoadFail:(BUSplashAd *)splashAd error:(BUAdError *_Nullable)error {
    [AlexGromoreBaseManager AL_logMessage:[NSString stringWithFormat:@"Splash::splashAdLoadFail:error:%@",error]];
    if (self.isC2SBiding && NSClassFromString(@"AlexGromoreC2SBiddingRequestManager")) {
        [NSClassFromString(@"AlexGromoreC2SBiddingRequestManager") disposeLoadFailCall:error key:kATSDKFailedToLoadSplashADMsg unitID:self.networkAdvertisingID];
    } else {
        [self trackSplashAdLoadFailed:error];
    }
}

/// This method is called when splash view will show
- (void)splashAdWillShow:(BUSplashAd *)splashAd {
    [AlexGromoreBaseManager AL_logMessage:@"Splash::splashAdWillShow:"];
    [self trackSplashAdShow];
}

/**
 This method is called when splash ad is clicked.
 */
- (void)splashAdDidClick:(BUSplashAd *)splashAd {
    [AlexGromoreBaseManager AL_logMessage:@"Splash::splashAdDidClick:"];
    [self trackSplashAdClick];
}

/// This method is called when splash view is closed.
- (void)splashAdDidClose:(BUSplashAd *)splashAd closeType:(BUSplashAdCloseType)closeType {
    [AlexGromoreBaseManager AL_logMessage:[NSString stringWithFormat:@"Splash::splashAdDidClose:closeType:%ld",closeType]];
    ATAdCloseType toponCloseType = ATAdCloseUnknow;
    switch (closeType) {
        case BUSplashAdCloseType_Unknow:
            toponCloseType = ATAdCloseUnknow;
            break;
        case BUSplashAdCloseType_ClickSkip:
            toponCloseType = ATAdCloseSkip;
            break;
        case BUSplashAdCloseType_CountdownToZero:
            toponCloseType = ATAdCloseCountdown;
            break;
        case BUSplashAdCloseType_ClickAd:
            toponCloseType = ATAdCloseClickcontent;
            break;
            
        default:
            break;
    }
    
    [self trackSplashAdClosed:@{kATADDelegateExtraDismissTypeKey:@(toponCloseType)}];
    [splashAd.mediation destoryAd];
}

/**
 This method is called when another controller has been closed.
 @param interactionType : open appstore in app or open the webpage or view video ad details page.
 */
- (void)splashDidCloseOtherController:(BUSplashAd *)splashAd interactionType:(BUInteractionType)interactionType {
    [AlexGromoreBaseManager AL_logMessage:[NSString stringWithFormat:@"Splash::splashDidCloseOtherController:interactionType:%ld",interactionType]];
    [self trackSplashAdDetailClosed];
}

/// This method is called when when video ad play completed or an error occurred.
- (void)splashVideoAdDidPlayFinish:(BUSplashAd *)splashAd didFailWithError:(NSError *)error {
    [AlexGromoreBaseManager AL_logMessage:[NSString stringWithFormat:@"Splash::splashVideoAdDidPlayFinish:didFailWithError:%@",error]];
}

#pragma mark - BUSplashCardDelegate
- (void)splashCardReadyToShow:(nonnull BUSplashAd *)splashAd {
    [AlexGromoreBaseManager AL_logMessage:@"Splash::splashCardReadyToShow:"];
    UIWindow *window = self.localInfo[kATSplashExtraWindowKey];
    [splashAd showCardViewInRootViewController:window.rootViewController];
}

- (void)splashCardViewDidClick:(nonnull BUSplashAd *)splashAd {
    [AlexGromoreBaseManager AL_logMessage:@"Splash::splashCardViewDidClick:"];
}

- (void)splashCardViewDidClose:(nonnull BUSplashAd *)splashAd {
    [AlexGromoreBaseManager AL_logMessage:@"Splash::splashCardViewDidClose:"];
}

#pragma mark - BUSplashZoomOutDelegate
/// This method is called when splash zoomout is ready to show.
- (void)splashZoomOutReadyToShow:(BUSplashAd *)splashAd {
    [AlexGromoreBaseManager AL_logMessage:@"Splash::splashZoomOutReadyToShow:"];
    if (splashAd.zoomOutView) {
        UIWindow *window = self.localInfo[kATSplashExtraWindowKey];
        [splashAd showZoomOutViewInRootViewController:window.rootViewController];
    }
}

/// This method is called when splash zoomout is clicked.
- (void)splashZoomOutViewDidClick:(BUSplashAd *)splashAd {
    [AlexGromoreBaseManager AL_logMessage:@"Splash::splashZoomOutViewDidClick:"];
    [self trackSplashAdZoomOutViewClick];
}

/// This method is called when splash zoomout is closed.
- (void)splashZoomOutViewDidClose:(BUSplashAd *)splashAd {
    [AlexGromoreBaseManager AL_logMessage:@"Splash::splashZoomOutViewDidClose:"];
    [self trackSplashAdZoomOutViewClosed];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"slot_id"];
}

- (NSDictionary *)networkCustomInfo {
    BUSplashAd *splash = self.ad.customObject;
    BUMRitInfo *info = [splash.mediation getShowEcpmInfo];
    NSMutableDictionary *extra = [AlexGromoreBaseManager AL_getExtraForRitInfo:info];
    return extra;
}

@end
