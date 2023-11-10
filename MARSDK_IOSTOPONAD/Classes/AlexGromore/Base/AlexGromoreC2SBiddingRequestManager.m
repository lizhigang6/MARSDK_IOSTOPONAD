//
//  AlexGromoreC2SBiddingRequestManager.m
//  AlexGromoreMixSDKAdapter
//
//  Created by Alex on 5/13/22.
//  Copyright © 2022 . All rights reserved.
//

#import "AlexGromoreC2SBiddingRequestManager.h"
#import "AlexGromoreBaseManager.h"
#import "AlexGromoreInterstitialCustomEvent.h"
#import "AlexGromoreNativeCustomEvent.h"
#import "AlexGromoreRewardedVideoCustomEvent.h"
#import "AlexGromoreSplashCustomEvent.h"
#import "AlexGromoreBannerCustomEvent.h"
#import <AnyThinkSDK/AnyThinkSDK.h>
#import <AnyThinkRewardedVideo/AnyThinkRewardedVideo.h>
#import <AnyThinkNative/AnyThinkNative.h>
#import <AnyThinkInterstitial/AnyThinkInterstitial.h>
#import <AnyThinkSplash/AnyThinkSplash.h>
#import <AnyThinkBanner/AnyThinkBanner.h>
#import <BUAdSDK/BUAdSDK.h>

@implementation AlexGromoreC2SBiddingRequestManager

+ (instancetype)sharedInstance {
    static AlexGromoreC2SBiddingRequestManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AlexGromoreC2SBiddingRequestManager alloc] init];
    });
    return sharedInstance;
}

#pragma mark - public
- (void)startWithRequestItem:(AlexGromoreBiddingRequest *)request {
    [[AlexC2SBiddingParameterManager sharedInstance] saveRequestItem:request withUnitId:request.unitID];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (request.adType) {
            case ATAdFormatInterstitial:
                [self startLoadInterstitialAdWithRequest:request];
                break;
            case ATAdFormatRewardedVideo:
                [self startLoadRewardedVideoAdWithRequest:request];
                break;
            case ATAdFormatNative:
                [self startLoadNativeAdWithRequest:request];
                break;
            case ATAdFormatBanner:
                [self startLoadBannerAdWithRequest:request];
                break;
            case ATAdFormatSplash:
                [self startLoadSplashAdWithRequest:request];
                break;
            default:
                break;
        }
    });
}

#pragma mark - ATAdFormatInterstitial
- (void)startLoadInterstitialAdWithRequest:(AlexGromoreBiddingRequest *)request {
    NSDictionary *localInfo = request.extraInfo;
    NSString *slotIdStr = request.unitGroup.content[@"slot_id"];
    
    BUAdSlot *slot = [[BUAdSlot alloc] init];
    slot.ID = slotIdStr;
    
    BUNativeExpressFullscreenVideoAd *interstitialAd = [[BUNativeExpressFullscreenVideoAd alloc] initWithSlot:slot];
    interstitialAd.delegate = (AlexGromoreInterstitialCustomEvent*)request.customEvent;
    if (localInfo[kATExtraGromoreMutedKey] != nil) {
        slot.mediation.mutedIfCan = [localInfo[kATExtraGromoreMutedKey] boolValue];
    }
    
    request.customObject = interstitialAd;
    [interstitialAd loadAdData];
}

#pragma mark - ATAdFormatRewardedVideo
- (void)startLoadRewardedVideoAdWithRequest:(AlexGromoreBiddingRequest *)request {
    NSDictionary *localInfo = request.extraInfo;
    NSString *slotIdStr = request.unitGroup.content[@"slot_id"];
    
    BURewardedVideoModel *model = [[BURewardedVideoModel alloc] init];
    if (localInfo[kATAdLoadingExtraUserIDKey] != nil) {
        model.userId = localInfo[kATAdLoadingExtraUserIDKey];
    }
    if([localInfo[kATAdLoadingExtraMediaExtraKey] isKindOfClass:[NSString class]]){
        model.extra = [localInfo[kATAdLoadingExtraMediaExtraKey] stringByReplacingOccurrencesOfString:kATAdLoadingExtraNetworkPlacementIDKey withString:slotIdStr];
    }
    if (localInfo[kATAdLoadingExtraRewardNameKey] != nil) {
        model.rewardName = localInfo[kATAdLoadingExtraRewardNameKey];
    }
    if (localInfo[kATAdLoadingExtraRewardAmountKey] != nil) {
        model.rewardAmount = [localInfo[kATAdLoadingExtraRewardAmountKey] integerValue];
    }
    
    BUAdSlot *slot = [[BUAdSlot alloc] init];
    slot.ID = slotIdStr;
    if (localInfo[kATExtraGromoreMutedKey] != nil) {
        slot.mediation.mutedIfCan = [localInfo[kATExtraGromoreMutedKey] boolValue];
    }
    
    BUNativeExpressRewardedVideoAd *rewardedVideoAd = [[BUNativeExpressRewardedVideoAd alloc] initWithSlot:slot rewardedVideoModel:model];
    AlexGromoreRewardedVideoCustomEvent *customEvent = (AlexGromoreRewardedVideoCustomEvent*)request.customEvent;
    rewardedVideoAd.delegate = customEvent;
    rewardedVideoAd.rewardPlayAgainInteractionDelegate = customEvent.againCustomEvent;
    request.customObject = rewardedVideoAd;
    [rewardedVideoAd loadAdData];
}

#pragma mark - ATAdFormatNative
- (void)startLoadNativeAdWithRequest:(AlexGromoreBiddingRequest *)request {
    NSDictionary *serverInfo = request.unitGroup.content;
    NSDictionary *localInfo = request.extraInfo;
    NSString *slotIdStr = request.unitGroup.content[@"slot_id"];
    
//    NSDictionary *slotInfo = [NSJSONSerialization JSONObjectWithData:[serverInfo[@"slot_info"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    CGSize adSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), 200.0f);
    if ([localInfo[kATExtraInfoNativeAdSizeKey] respondsToSelector:@selector(CGSizeValue)]) {
        adSize = [localInfo[kATExtraInfoNativeAdSizeKey] CGSizeValue];
    }
    
    CGSize imgSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), 200.0f);
    if ([localInfo[kATExtraNativeImageSizeKey] respondsToSelector:@selector(CGSizeValue)]) {
        imgSize = [localInfo[kATExtraNativeImageSizeKey] CGSizeValue];
    }
    if ([localInfo[kATNativeAdSizeToFitKey] boolValue]) {
        imgSize = CGSizeMake(imgSize.width, 0);
    }
    
    BUAdSlot *slot = [[BUAdSlot alloc] init];
    BUSize *imgBUSize = [[BUSize alloc] init];
    imgBUSize.width = imgSize.width;
    imgBUSize.height = imgSize.height;
    slot.imgSize = imgBUSize;
    slot.ID = slotIdStr;
    slot.adSize = adSize;

    BUNativeAdsManager *adManager = [[BUNativeAdsManager alloc] initWithSlot:slot];
    adManager.mediation.rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (localInfo[kATExtraGromoreMutedKey] != nil) {
        slot.mediation.mutedIfCan = [localInfo[kATExtraGromoreMutedKey] boolValue];
    }
    adManager.delegate = (AlexGromoreNativeCustomEvent*)request.customEvent;
    request.customObject = adManager;
    NSNumber *count = serverInfo[@"request_num"];
    [adManager loadAdDataWithCount:count ? [count integerValue] : 1];
}

#pragma mark - ATAdFormatBanner
- (void)startLoadBannerAdWithRequest:(AlexGromoreBiddingRequest *)request {
    NSDictionary *serverInfo = request.unitGroup.content;
    NSDictionary *localInfo = request.extraInfo;
    NSString *slotIdStr = request.unitGroup.content[@"slot_id"];
    
    NSDictionary *slotInfo = [NSJSONSerialization JSONObjectWithData:[serverInfo[@"slot_info"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    
    CGSize adSize = CGSizeZero;
    if ([localInfo[kATAdLoadingExtraBannerAdSizeKey] respondsToSelector:@selector(CGSizeValue)]) {
        adSize = [localInfo[kATAdLoadingExtraBannerAdSizeKey] CGSizeValue];
    } else{
        NSString* sizeStr = slotInfo[@"common"][@"size"];
        NSArray<NSString*>* comp = [sizeStr componentsSeparatedByString:@"x"];
        if ([comp count] == 2 && [comp[0] respondsToSelector:@selector(doubleValue)] && [comp[1] respondsToSelector:@selector(doubleValue)]) {
            adSize = CGSizeMake([comp[0] doubleValue], [comp[1] doubleValue]);
        }
    }
    
    BUAdSlot *slot = [[BUAdSlot alloc] init];
    slot.ID = slotIdStr;
    if (localInfo[kATExtraGromoreMutedKey] != nil) {
        slot.mediation.mutedIfCan = [localInfo[kATExtraGromoreMutedKey] boolValue];
    }
    
    BUNativeExpressBannerView *bannerAd = [[BUNativeExpressBannerView alloc] initWithSlot:slot rootViewController:[UIApplication sharedApplication].keyWindow.rootViewController adSize:adSize];
    bannerAd.delegate = (AlexGromoreBannerCustomEvent*)request.customEvent;
    request.customObject = bannerAd;
    
    [bannerAd loadAdData];
}

#pragma mark - ATAdFormatSplash
- (void)startLoadSplashAdWithRequest:(AlexGromoreBiddingRequest *)request {
    NSDictionary *serverInfo = request.unitGroup.content;
    NSDictionary *localInfo = request.extraInfo;
    NSString *slotIdStr = request.unitGroup.content[@"slot_id"];
    
    NSDictionary *slotInfo = [NSJSONSerialization JSONObjectWithData:[serverInfo[@"slot_info"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    
    NSNumber *number = localInfo[kATSplashExtraTolerateTimeoutKey];
    NSTimeInterval tolerateTimeout = number ? [number doubleValue] : 5;
    
    BUAdSlot *slot = [[BUAdSlot alloc] init];
    slot.ID = slotIdStr;
    if (localInfo[kATSplashExtraGromoreAdnNameKey] != nil) {
        BUMSplashUserData *userData = [[BUMSplashUserData alloc] init];
        userData.adnName = localInfo[kATSplashExtraGromoreAdnNameKey];
        userData.appKey = localInfo[kATSplashExtraGromoreAppKeyKey];
        userData.appID = localInfo[kATSplashExtraGromoreAppIDKey];
        userData.rit = localInfo[kATSplashExtraGromoreRIDKey];
        
        slot.mediation.splashUserData = userData;
    }
    
    CGSize size = [UIApplication sharedApplication].keyWindow.rootViewController.view.bounds.size;
    BUSplashAd *splashAd = [[BUSplashAd alloc] initWithSlot:slot adSize:CGSizeZero];
    splashAd.delegate = (AlexGromoreSplashCustomEvent*)request.customEvent;
    splashAd.zoomOutDelegate = (AlexGromoreSplashCustomEvent*)request.customEvent;
    splashAd.tolerateTimeout = tolerateTimeout;
    if (localInfo[kATSplashExtraContainerViewKey] != nil) {
        UIView *containerView = localInfo[kATSplashExtraContainerViewKey];
        splashAd.mediation.customBottomView = [AlexGromoreBaseManager captureScreenForView:containerView];
    }
    if ([slotInfo[@"common"][@"btn_type"] intValue] == 0) {
        splashAd.mediation.splashButtonType = BUMSplashButtonTypeFullScreen;
    } else if ([slotInfo[@"common"][@"btn_type"] intValue] == 1) {
        splashAd.mediation.splashButtonType = BUMSplashButtonTypeDownloadBar;
    }
    splashAd.supportZoomOutView = [slotInfo[@"common"][@"zoomoutad_sw"] integerValue] == 2 ? YES : NO;
    
    request.customObject = splashAd;
    [splashAd loadAdData];
}

#pragma mark - private
+ (NSString *)getPriceWithAd:(id)abuBaseAd {
    NSString *price = @"0";
    if ([abuBaseAd respondsToSelector:@selector(adapterToAdPackage)]) {
        NSMutableArray *tempEcpmArray = [[NSMutableArray alloc] init];
        NSDictionary *infoDict = [abuBaseAd valueForKey:@"adapterToAdPackage"];
        [infoDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSString *ecpm = [obj valueForKey:@"ecpm"];
            if (ecpm) {
                [tempEcpmArray addObject:ecpm];
            }
        }];
        
        if (tempEcpmArray.count > 1) {
            NSArray<NSString *> *array = [tempEcpmArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                NSDecimalNumber *obj1_num = [NSDecimalNumber decimalNumberWithString:obj1];
                NSDecimalNumber *obj2_num = [NSDecimalNumber decimalNumberWithString:obj2];
                return [obj2_num compare:obj1_num];
            }];
            
            price = array.firstObject;
        } else {
            if (tempEcpmArray.firstObject) {
                price = tempEcpmArray.firstObject;
            }
        }
    } else {
    }
    
    NSDecimalNumber *price_num = [NSDecimalNumber decimalNumberWithString:price];
    NSString *finalPrice = [[price_num decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"100"]] stringValue];
    return finalPrice;
}

+ (void)disposeLoadSuccessCall:(NSString *)priceStr customObject:(id)customObject unitID:(NSString *)unitID {
    [AlexGromoreBaseManager AL_logMessage:[NSString stringWithFormat:@"disposeLoadSuccessCall:priceStr:%@，unitID:%@", priceStr, unitID]];

    AlexGromoreBiddingRequest *request = [[AlexC2SBiddingParameterManager sharedInstance] getRequestItemWithUnitID:unitID];
    if (request == nil) {
        return;
    }
    
    BOOL isUS = request.unitGroup.networkCurrencyType == ATNetworkCurrencyUSDType ? YES : NO;
    
    ATBidInfo *bidInfo = [ATBidInfo bidInfoC2SWithPlacementID:request.placementID unitGroupUnitID:request.unitGroup.unitID adapterClassString:request.unitGroup.adapterClassString price:priceStr currencyType:isUS ? ATBiddingCurrencyTypeUS : ATBiddingCurrencyTypeCNY expirationInterval:request.unitGroup.bidTokenTime customObject:customObject];
    bidInfo.networkFirmID = request.unitGroup.networkFirmID;
    
    if (request.bidCompletion) {
        request.bidCompletion(bidInfo, nil);
    }
}

+ (void)disposeLoadFailCall:(NSError *)error key:(NSString *)keyStr unitID:(NSString *)unitID {
    [AlexGromoreBaseManager AL_logMessage:[NSString stringWithFormat:@"disposeLoadFailCall:error:%@，unitID:%@", error, unitID]];

    AlexGromoreBiddingRequest *request = [[AlexC2SBiddingParameterManager sharedInstance] getRequestItemWithUnitID:unitID];
    
    if (request == nil) {
        return;
    }
    
    if (request.bidCompletion) {
        request.bidCompletion(nil, [NSError errorWithDomain:@"com.alexGromore.GromoreSDK" code:error.code userInfo:@{
            NSLocalizedDescriptionKey:keyStr,
            NSLocalizedFailureReasonErrorKey:error}]);
    }
    
    [[AlexC2SBiddingParameterManager sharedInstance] removeRequestItemWithUnitID:unitID];
}

@end
