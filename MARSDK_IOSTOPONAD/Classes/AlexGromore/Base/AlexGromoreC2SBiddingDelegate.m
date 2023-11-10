//
//  AlexGromoreC2SBiddingDelegate.m
//  AlexGromoreMixSDKAdapter
//
//  Created by Alex on 5/13/22.
//  Copyright © 2022 Alex. All rights reserved.
//

#import "AlexGromoreC2SBiddingDelegate.h"
#import "AlexGromoreC2SBiddingRequestManager.h"
#import "AlexGromoreBiddingRequest.h"

@implementation AlexGromoreC2SBiddingDelegate

#pragma mark - ABUInterstitialAdDelegate
- (void)nativeExpressFullscreenVideoAdDidLoad:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    
    id intersitiialAd = nil;
    if ([fullscreenVideoAd.mediation respondsToSelector:@selector(intersitiialProAd)]) {
        intersitiialAd = [fullscreenVideoAd.mediation performSelector:@selector(intersitiialProAd)];
    }
    if ([fullscreenVideoAd.mediation respondsToSelector:@selector(fullscreenVideoAd)] && !intersitiialAd) {
        intersitiialAd = [fullscreenVideoAd.mediation performSelector:@selector(fullscreenVideoAd)];
    }
    
    NSString * price = [self getPriceWithAd:intersitiialAd];
    
    [self disposeLoadSuccessCall:price customObject:fullscreenVideoAd];
}

- (void)nativeExpressFullscreenVideoAd:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error {
    
    [self disposeLoadFailCall:error key:kATSDKFailedToLoadInterstitialADMsg];
}

#pragma mark - ABURewardedVideoAdDelegate
- (void)rewardedVideoAdDidLoad:(BURewardedVideoAd *)rewardedVideoAd {
    
    NSString *price = [self getPriceWithAd:rewardedVideoAd.mediation];
    
    [self disposeLoadSuccessCall:price customObject:rewardedVideoAd];
}

- (void)rewardedVideoAd:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    
    [self disposeLoadFailCall:error key:kATSDKFailedToLoadRewardedVideoADMsg];
}

#pragma mark - ABUSplashAdDelegate
- (void)splashAdLoadSuccess:(BUSplashAd *)splashAd {
    
    NSString *price = [self getPriceWithAd:splashAd.mediation];
    
    [self disposeLoadSuccessCall:price customObject:splashAd];
}

- (void)splashAdLoadFail:(BUSplashAd *)splashAd error:(BUAdError *_Nullable)error {
    
    [self disposeLoadFailCall:error key:kATSDKFailedToLoadSplashADMsg];
}

#pragma mark - ABUNativeAdsManagerDelegate
- (void)nativeAdsManagerSuccessToLoad:(BUNativeAdsManager *)adsManager nativeAds:(NSArray<BUNativeAd *> *_Nullable)nativeAdDataArray {
    if (nativeAdDataArray.count) {
        AlexGromoreBiddingRequest *request = [[AlexC2SBiddingParameterManager sharedInstance] getRequestItemWithUnitID:self.unitID];
        BUNativeAd *nativeAd = nativeAdDataArray.firstObject;
        request.nativeAds = @[nativeAd];
        NSString *price = [self getPriceWithAd:adsManager.mediation];
        [self disposeLoadSuccessCall:price customObject:nativeAd];
    }
}

- (void)nativeAdsManager:(BUNativeAdsManager *)adsManager didFailWithError:(NSError *_Nullable)error {
    [self disposeLoadFailCall:error key:kATSDKFailedToLoadNativeADMsg];
}

#pragma mark - ABUBannerAdDelegate
- (void)nativeExpressBannerAdViewDidLoad:(BUNativeExpressBannerView *)bannerAdView {
    AlexGromoreBiddingRequest *request = [[AlexC2SBiddingParameterManager sharedInstance] getRequestItemWithUnitID:self.unitID];
    request.bannerView = bannerAdView;
    NSString *price = [self getPriceWithAd:bannerAdView.mediation];
    [self disposeLoadSuccessCall:price customObject:bannerAdView];
}

- (void)nativeExpressBannerAdView:(BUNativeExpressBannerView *)bannerAdView didLoadFailWithError:(NSError *_Nullable)error {
    [self disposeLoadFailCall:error key:kATSDKFailedToLoadBannerADMsg];
}

#pragma mark - private
- (NSString *)getPriceWithAd:(id)abuBaseAd {
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

- (void)disposeLoadSuccessCall:(NSString *)priceStr customObject:(id)customObject{
    AlexGromoreBiddingRequest *request = [[AlexC2SBiddingParameterManager sharedInstance] getRequestItemWithUnitID:self.unitID];
    if (request == nil) {
        return;
    }
    
    
    BOOL isUS = request.unitGroup.networkCurrencyType == ATNetworkCurrencyUSDType ? YES : NO;
    
    ATBidInfo *bidInfo = [ATBidInfo bidInfoC2SWithPlacementID:request.placementID unitGroupUnitID:request.unitGroup.unitID adapterClassString:request.unitGroup.adapterClassString price:priceStr currencyType:isUS ? ATBiddingCurrencyTypeUS : ATBiddingCurrencyTypeCNY expirationInterval:request.unitGroup.bidTokenTime customObject:customObject];
    bidInfo.networkFirmID = request.unitGroup.networkFirmID;
    if (request.bidCompletion) {
        request.bidCompletion(bidInfo, nil);
    }
    [[AlexC2SBiddingParameterManager sharedInstance] removeBiddingDelegateWithUnitId:request.unitID];
}

- (void)disposeLoadFailCall:(NSError *)error key:(NSString *)keyStr{
    
    AlexGromoreBiddingRequest *request = [[AlexC2SBiddingParameterManager sharedInstance] getRequestItemWithUnitID:self.unitID];
    
    if (request == nil) {
        return;
    }
    
    if (request.bidCompletion) {
        request.bidCompletion(nil, [NSError errorWithDomain:@"com.alexGromore.GromoreSDK" code:error.code userInfo:@{
            NSLocalizedDescriptionKey:keyStr,
            NSLocalizedFailureReasonErrorKey:error}]);
    }
    [[AlexC2SBiddingParameterManager sharedInstance] removeRequestItemWithUnitID:self.unitID];
    
    [[AlexC2SBiddingParameterManager sharedInstance] removeBiddingDelegateWithUnitId:request.unitID];
}

@end
