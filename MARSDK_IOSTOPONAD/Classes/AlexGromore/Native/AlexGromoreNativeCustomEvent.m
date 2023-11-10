//
//  AlexGromoreNativeCustomEvent.m
//  AlexGromoreMixSDKAdapter
//
//  Created by Alex on 2/1/21.
//  Copyright © 2021 Alex. All rights reserved.
//

#import "AlexGromoreNativeCustomEvent.h"
#import "AlexC2SBiddingParameterManager.h"
#import "AlexGromoreBaseManager.h"

@interface AlexGromoreNativeCustomEvent ()
@property (nonatomic, weak) BUNativeAd *nativeAd;
@property (nonatomic, strong) BUNativeAdsManager *adsManager;
@end

@implementation AlexGromoreNativeCustomEvent

- (void)loadedWithAdsManager:(BUNativeAdsManager * _Nonnull)adsManager nativeAdViewArray:(NSArray<BUNativeAd *> * _Nullable)nativeAdViewArray {
    [AlexGromoreBaseManager AL_logMessage:@"Native::loadedWithAdsManager:nativeAdViewArray:"];
    self.adsManager = adsManager;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray<NSDictionary*>* assets = [NSMutableArray<NSDictionary*> array];
        self.nativeAd = nativeAdViewArray.firstObject;
        [nativeAdViewArray enumerateObjectsUsingBlock:^(BUNativeAd *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableDictionary *asset = [NSMutableDictionary dictionary];
            
            [AlexGromoreBaseManager AL_Dictionary:asset setValue:self forKey:kATAdAssetsCustomEventKey];
            [AlexGromoreBaseManager AL_Dictionary:asset setValue:obj forKey:kATAdAssetsCustomObjectKey];
            [AlexGromoreBaseManager AL_Dictionary:asset setValue:@(obj.mediation.isExpressAd) forKey:kATNativeADAssetsIsExpressAdKey];
            
            if (obj.mediation.isExpressAd) {
                // express
                CGSize expressAdViewSize = obj.mediation.canvasView.frame.size;
                [AlexGromoreBaseManager AL_Dictionary:asset setValue:[NSString stringWithFormat:@"%lf",expressAdViewSize.width] forKey:kATNativeADAssetsNativeExpressAdViewWidthKey];
                [AlexGromoreBaseManager AL_Dictionary:asset setValue:[NSString stringWithFormat:@"%lf",expressAdViewSize.height] forKey:kATNativeADAssetsNativeExpressAdViewHeightKey];
            } else {
                // self-Render
                [AlexGromoreBaseManager AL_Dictionary:asset setValue:obj.data.AdTitle forKey:kATNativeADAssetsMainTitleKey];
                [AlexGromoreBaseManager AL_Dictionary:asset setValue:obj.data.AdDescription forKey:kATNativeADAssetsMainTextKey];
                [AlexGromoreBaseManager AL_Dictionary:asset setValue:obj.data.buttonText forKey:kATNativeADAssetsCTATextKey];
                [AlexGromoreBaseManager AL_Dictionary:asset setValue:obj.data.mediation.advertiser forKey:kATNativeADAssetsAdvertiserKey];
                [AlexGromoreBaseManager AL_Dictionary:asset setValue:obj.data.source forKey:kATNativeADAssetsSourceKey];
                [AlexGromoreBaseManager AL_Dictionary:asset setValue:@(obj.data.score) forKey:kATNativeADAssetsRatingKey];
                [AlexGromoreBaseManager AL_Dictionary:asset setValue:@(obj.data.interactionType) forKey:kATNativeADAssetsInteractionTypeKey];
                [AlexGromoreBaseManager AL_Dictionary:asset setValue:obj.data.mediaExt forKey:kATNativeADAssetsMediaExtKey];
                [AlexGromoreBaseManager AL_Dictionary:asset setValue:@(obj.data.commentNum) forKey:kATNativeADAssetsCommentNumKey];
                [AlexGromoreBaseManager AL_Dictionary:asset setValue:@(obj.data.appSize) forKey:kATNativeADAssetsAppSizeKey];
                [AlexGromoreBaseManager AL_Dictionary:asset setValue:obj.data.mediation.appPrice forKey:kATNativeADAssetsAppPriceKey];
                [AlexGromoreBaseManager AL_Dictionary:asset setValue:obj.data.videoUrl forKey:kATNativeADAssetsVideoUrlKey];
                [AlexGromoreBaseManager AL_Dictionary:asset setValue:@(obj.data.videoDuration) forKey:kATNativeADAssetsVideoDurationKey];
                [AlexGromoreBaseManager AL_Dictionary:asset setValue:@(obj.data.mediation.videoAspectRatio) forKey:kATNativeADAssetsVideoAspectRatioKey];
                if (obj.data.imageMode == BUMFeedVideoAdModeImage || obj.data.imageMode == BUMFeedVideoAdModePortrait) {
                    [AlexGromoreBaseManager AL_Dictionary:asset setValue:@(YES) forKey:kATNativeADAssetsContainsVideoFlag];
                }
                
                [AlexGromoreBaseManager AL_Dictionary:asset setValue:obj.data.icon.imageURL forKey:kATNativeADAssetsIconURLKey];
                [AlexGromoreBaseManager AL_Dictionary:asset setValue:obj.data.mediation.adLogo forKey:kATNativeADAssetsLogoURLKey];
                if ([obj.data.imageAry count] > 0) {
                    BUImage *mainImage = obj.data.imageAry.firstObject;
                    if (mainImage.imageURL) {
                        [AlexGromoreBaseManager AL_Dictionary:asset setValue:mainImage.imageURL forKey:kATNativeADAssetsImageURLKey];
                        [AlexGromoreBaseManager AL_Dictionary:asset setValue:@(mainImage.width) forKey:kATNativeADAssetsMainImageWidthKey];
                        [AlexGromoreBaseManager AL_Dictionary:asset setValue:@(mainImage.height) forKey:kATNativeADAssetsMainImageHeightKey];
                    }
                    
                    NSMutableArray *imageList = [NSMutableArray array];
                    [obj.data.imageAry enumerateObjectsUsingBlock:^(BUImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (obj.imageURL) {
                            [imageList addObject:obj.imageURL];
                        }
                    }];
                    
                    if (imageList.count > 0) {
                        [AlexGromoreBaseManager AL_Dictionary:asset setValue:imageList forKey:kATNativeADAssetsImageListKey];
                    }
                }
            }
            [assets addObject:asset];
        }];
        
        [self trackNativeAdLoaded:assets];
    });
}

#pragma mark - ABUNativeAdsManagerDelegate
- (void)nativeAdsManagerSuccessToLoad:(BUNativeAdsManager *)adsManager nativeAds:(NSArray<BUNativeAd *> *_Nullable)nativeAdDataArray {
    [AlexGromoreBaseManager AL_logMessage:@"Native::nativeAdsManagerSuccessToLoad:nativeAds:"];
    if (self.isC2SBiding && NSClassFromString(@"AlexGromoreC2SBiddingRequestManager")) {
        if (nativeAdDataArray.count) {
            id<AlexGromoreBiddingRequest_plus> request = [[AlexC2SBiddingParameterManager sharedInstance] getRequestItemWithUnitID:self.networkAdvertisingID];
            BUNativeAd *nativeAd = nativeAdDataArray.firstObject;
            request.nativeAds = @[nativeAd];
            NSString *price = [NSClassFromString(@"AlexGromoreC2SBiddingRequestManager") getPriceWithAd:adsManager.mediation];
            [NSClassFromString(@"AlexGromoreC2SBiddingRequestManager") disposeLoadSuccessCall:price customObject:nativeAd unitID:self.networkAdvertisingID];
            self.isC2SBiding = NO;
        }
    } else {
        [self loadedWithAdsManager:adsManager nativeAdViewArray:nativeAdDataArray];
    }
}

- (void)nativeAdsManager:(BUNativeAdsManager *)adsManager didFailWithError:(NSError *_Nullable)error {
    [AlexGromoreBaseManager AL_logMessage:[NSString stringWithFormat:@"Native::nativeAdsManager:didFailWithError:%@", error]];
    if (self.isC2SBiding && NSClassFromString(@"AlexGromoreC2SBiddingRequestManager")) {
        [NSClassFromString(@"AlexGromoreC2SBiddingRequestManager") disposeLoadFailCall:error key:kATSDKFailedToLoadNativeADMsg unitID:self.networkAdvertisingID];
    } else {
        [self trackNativeAdLoadFailed:error];
    }
}

#pragma mark - BUMNativeAdDelegate
/// 广告即将展示全屏页面/商店时触发
/// @param nativeAd 广告视图
- (void)nativeAdWillPresentFullScreenModal:(BUNativeAd *_Nonnull)nativeAd {
    [AlexGromoreBaseManager AL_logMessage:@"Native::nativeAdWillPresentFullScreenModal"];
}

/// 聚合维度混出模板广告时渲染成功回调，可能不会回调
/// @param nativeAd 模板广告对象
- (void)nativeAdExpressViewRenderSuccess:(BUNativeAd *_Nonnull)nativeAd {
    [AlexGromoreBaseManager AL_logMessage:@"Native::nativeAdExpressViewRenderSuccess"];
}

/// 聚合维度混出模板广告时渲染失败回调，可能不会回调
/// @param nativeAd 模板广告对象
/// @param error 渲染出错原因
- (void)nativeAdExpressViewRenderFail:(BUNativeAd *_Nonnull)nativeAd error:(NSError *_Nullable)error {
    [AlexGromoreBaseManager AL_logMessage:[NSString stringWithFormat:@"Native::nativeAdExpressViewRenderFail:error:%@", error]];
}

/// 当视频播放状态改变之后触发
/// @param nativeAd 广告视图
/// @param playerState 变更后的播放状态
- (void)nativeAdVideo:(BUNativeAd *_Nullable)nativeAd stateDidChanged:(BUPlayerPlayState)playerState {
    [AlexGromoreBaseManager AL_logMessage:[NSString stringWithFormat:@"Native::nativeAdVideo:stateDidChanged:%ld",playerState]];
}

/// 广告视图中视频视图被点击时触发
/// @param nativeAd 广告视图
- (void)nativeAdVideoDidClick:(BUNativeAd *_Nullable)nativeAd {
    [AlexGromoreBaseManager AL_logMessage:@"Native::nativeAdVideoDidClick:"];
    [self trackNativeAdClick];
}

/// 广告视图中视频播放完成时触发
/// @param nativeAd 广告视图
- (void)nativeAdVideoDidPlayFinish:(BUNativeAd *_Nullable)nativeAd {
    [AlexGromoreBaseManager AL_logMessage:@"Native::nativeAdVideoDidPlayFinish:"];
    [self trackNativeAdVideoEnd];
}

/// 广告摇一摇提示view消除时调用该方法
/// @param nativeAd 广告视图
- (void)nativeAdShakeViewDidDismiss:(BUNativeAd *_Nullable)nativeAd {
    [AlexGromoreBaseManager AL_logMessage:@"Native::nativeAdShakeViewDidDismiss:"];
}

/// 激励信息流视频进入倒计时状态时调用
/// @param nativeAdView 广告视图
/// @param countDown : 倒计时
/// @Note : 当前该回调仅适用于CSJ广告 - v4200
- (void)nativeAdVideo:(BUNativeAd *_Nullable)nativeAdView rewardDidCountDown:(NSInteger)countDown {
    [AlexGromoreBaseManager AL_logMessage:[NSString stringWithFormat:@"Native::nativeAdVideo:rewardDidCountDown:%ld",countDown]];
}

#pragma mark - BUNativeAdDelegate
/**
 This method is called when native ad slot has been shown.
 */
- (void)nativeAdDidBecomeVisible:(BUNativeAd *)nativeAd {
    [AlexGromoreBaseManager AL_logMessage:@"Native::nativeAdDidBecomeVisible:"];
    [self trackNativeAdImpression];
}

/**
 This method is called when another controller has been closed.
 @param interactionType : open appstore in app or open the webpage or view video ad details page.
 */
- (void)nativeAdDidCloseOtherController:(BUNativeAd *)nativeAd interactionType:(BUInteractionType)interactionType {
    [AlexGromoreBaseManager AL_logMessage:[NSString stringWithFormat:@"Native::nativeAdDidCloseOtherController:interactionType:%ld",interactionType]];
    [self trackNativeAdCloseDetail];
}

/**
 This method is called when native ad is clicked.
 */
- (void)nativeAdDidClick:(BUNativeAd *)nativeAd withView:(UIView *_Nullable)view {
    [AlexGromoreBaseManager AL_logMessage:@"Native::nativeAdDidClick:withView:"];
    [self trackNativeAdClick];
}

/**
 This method is called when the user clicked dislike reasons.
 Only used for dislikeButton in BUNativeAdRelatedView.h
 @param filterWords : reasons for dislike
 */
- (void)nativeAd:(BUNativeAd *_Nullable)nativeAd dislikeWithReason:(NSArray<BUDislikeWords *> *_Nullable)filterWords {
    [AlexGromoreBaseManager AL_logMessage:@"Native::nativeAd:dislikeWithReason:"];
    [self trackNativeAdClosed];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"slot_id"];
}

- (NSDictionary *)networkCustomInfo {
    BUMRitInfo *info = [self.nativeAd.mediation getShowEcpmInfo];
    NSMutableDictionary *extra = [AlexGromoreBaseManager AL_getExtraForRitInfo:info];
    return extra;
}

@end
