//
//  AlexGromoreBannerCustomEvent.m
//  AlexGromoreMixSDKAdapter
//
//  Created by Alex on 2/1/21.
//  Copyright © 2021 Alex. All rights reserved.
//

#import "AlexGromoreBannerCustomEvent.h"
#import "AlexC2SBiddingParameterManager.h"
#import "AlexGromoreBaseManager.h"

@interface AlexGromoreBannerCustomEvent ()
@property (nonatomic, strong) BUNativeExpressBannerView *bannerAd;
@end

@implementation AlexGromoreBannerCustomEvent

#pragma mark - BUMNativeExpressBannerViewDelegate
/// 广告展示回调
- (void)nativeExpressBannerAdViewDidBecomeVisible:(BUNativeExpressBannerView *)bannerAdView {
    [AlexGromoreBaseManager AL_logMessage:@"Banner::nativeExpressBannerAdViewDidBecomeVisible"];
    [self trackBannerAdImpression];
}

/// 广告加载成功后为「混用的信息流自渲染广告」时会触发该回调，提供给开发者自渲染的时机
/// @param bannerAd 广告操作对象
/// @param canvasView 携带物料的画布，需要对其内部提供的物料及控件做布局及设置UI
/// @warning 轮播开启时，每次轮播到自渲染广告均会触发该回调，并且canvasView为其他回调中bannerView的子控件
- (void)nativeExpressBannerAdNeedLayoutUI:(BUNativeExpressBannerView *)bannerAd canvasView:(BUMCanvasView *)canvasView {
    [AlexGromoreBaseManager AL_logMessage:@"Banner::nativeExpressBannerAdNeedLayoutUI:canvasView:"];
}

/**
 This method is called when bannerAdView ad slot loaded successfully.
 @param bannerAdView : view for bannerAdView
 */
- (void)nativeExpressBannerAdViewDidLoad:(BUNativeExpressBannerView *)bannerAdView {
    [AlexGromoreBaseManager AL_logMessage:@"Banner::nativeExpressBannerAdViewDidLoad:"];
    self.bannerAd = bannerAdView;
    if (self.isC2SBiding && NSClassFromString(@"AlexGromoreC2SBiddingRequestManager")) {
        id<AlexGromoreBiddingRequest_plus> request = [[AlexC2SBiddingParameterManager sharedInstance] getRequestItemWithUnitID:self.networkAdvertisingID];
        request.bannerView = bannerAdView;
        NSString *price = [NSClassFromString(@"AlexGromoreC2SBiddingRequestManager") getPriceWithAd:bannerAdView.mediation];
        [NSClassFromString(@"AlexGromoreC2SBiddingRequestManager") disposeLoadSuccessCall:price customObject:bannerAdView unitID:self.networkAdvertisingID];
        self.isC2SBiding = NO;
    } else {
        [self trackBannerAdLoaded:bannerAdView adExtra:nil];
    }
}

/**
 This method is called when bannerAdView ad slot failed to load.
 @param error : the reason of error
 */
- (void)nativeExpressBannerAdView:(BUNativeExpressBannerView *)bannerAdView didLoadFailWithError:(NSError *_Nullable)error {
    [AlexGromoreBaseManager AL_logMessage:[NSString stringWithFormat:@"Banner::nativeExpressBannerAdView:didLoadFailWithError:%@", error]];
    if (self.isC2SBiding && NSClassFromString(@"AlexGromoreC2SBiddingRequestManager")) {
        [NSClassFromString(@"AlexGromoreC2SBiddingRequestManager") disposeLoadFailCall:error key:kATSDKFailedToLoadBannerADMsg unitID:self.networkAdvertisingID];
    } else {
        [self trackBannerAdLoadFailed:error];
    }
}

/**
 This method is called when bannerAdView is clicked.
 */
- (void)nativeExpressBannerAdViewDidClick:(BUNativeExpressBannerView *)bannerAdView {
    [AlexGromoreBaseManager AL_logMessage:@"Banner::nativeExpressBannerAdViewDidClick:"];
    [self trackBannerAdClick];
}

/**
 This method is called when the user clicked dislike button and chose dislike reasons.
 @param filterwords : the array of reasons for dislike.
 */
- (void)nativeExpressBannerAdView:(BUNativeExpressBannerView *)bannerAdView dislikeWithReason:(NSArray<BUDislikeWords *> *_Nullable)filterwords {
    [AlexGromoreBaseManager AL_logMessage:@"Banner::nativeExpressBannerAdView:dislikeWithReason:"];
}

/**
 This method is called when another controller has been closed.
 @param interactionType : open appstore in app or open the webpage or view video ad details page.
 */
- (void)nativeExpressBannerAdViewDidCloseOtherController:(BUNativeExpressBannerView *)bannerAdView interactionType:(BUInteractionType)interactionType {
    [AlexGromoreBaseManager AL_logMessage:[NSString stringWithFormat:@"Banner::nativeExpressBannerAdViewDidCloseOtherController:interactionType:%ld", interactionType]];
}

/**
 This method is called when the Ad view container is forced to be removed.
 @param bannerAdView : Express Banner Ad view container
 */
- (void)nativeExpressBannerAdViewDidRemoved:(BUNativeExpressBannerView *)bannerAdView {
    [AlexGromoreBaseManager AL_logMessage:@"Banner::nativeExpressBannerAdViewDidRemoved:"];
    [self trackBannerAdClosed];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"slot_id"];
}

- (NSDictionary *)networkCustomInfo {
    BUMRitInfo *info = [self.bannerAd.mediation getShowEcpmInfo];
    NSMutableDictionary *extra = [AlexGromoreBaseManager AL_getExtraForRitInfo:info];
    return extra;
}

@end
