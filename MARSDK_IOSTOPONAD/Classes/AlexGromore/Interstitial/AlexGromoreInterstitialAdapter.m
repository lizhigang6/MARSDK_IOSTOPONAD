//
//  AlexGromoreInterstitialAdapter.m
//  AlexGromoreMixSDKAdapter
//
//  Created by Alex on 2/1/21.
//  Copyright © 2021 . All rights reserved.
//

#import "AlexGromoreInterstitialAdapter.h"
#import "AlexC2SBiddingParameterManager.h"
#import <BUAdSDK/BUAdSDK.h>
#import "AlexGromoreBaseManager.h"
#import "AlexGromoreInterstitialCustomEvent.h"

@interface AlexGromoreInterstitialAdapter ()<ATAdAdapter, ATAdAdapterC2S>
@property (nonatomic, strong) BUNativeExpressFullscreenVideoAd *interstitialAd;
@property (nonatomic, strong) AlexGromoreInterstitialCustomEvent *customEvent;
@property (nonatomic, strong) id observer;
@end

@implementation AlexGromoreInterstitialAdapter

+ (BOOL)adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    return ((BUNativeExpressFullscreenVideoAd*)customObject).mediation.isReady;
}

+ (void)showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    interstitial.customEvent.delegate = delegate;
    if ([interstitial.customObject isKindOfClass:[BUNativeExpressFullscreenVideoAd class]]) {
        BUNativeExpressFullscreenVideoAd *nativeExpressFullscreenVideoAd = (BUNativeExpressFullscreenVideoAd *)interstitial.customObject;
        [nativeExpressFullscreenVideoAd showAdFromRootViewController:viewController];
    }
}

- (instancetype)initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [AlexGromoreBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

- (void)loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    __weak typeof(self) weakSelf = self;
    void(^load)(void) = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *slotIdStr = serverInfo[@"slot_id"];
            NSString *bidId = serverInfo[kATAdapterCustomInfoBuyeruIdKey];
            // C2S
            if (bidId) {
                if (NSClassFromString(@"AlexGromoreBiddingRequest")) {
                    id<AlexGromoreBiddingRequest_plus> request = [[AlexC2SBiddingParameterManager sharedInstance] getRequestItemWithUnitID:slotIdStr];
                    if (request != nil && request.customObject) {
                        self->_customEvent = (AlexGromoreInterstitialCustomEvent*)request.customEvent;
                        self->_customEvent.requestCompletionBlock = completion;
                        
                        self.interstitialAd = (BUNativeExpressFullscreenVideoAd *)request.customObject;
                        if (self.interstitialAd.mediation.isReady) {
                            [self.customEvent trackInterstitialAdLoaded:self->_interstitialAd adExtra:nil];
                        } else {
                            [self.interstitialAd loadAdData];
                        }
                    }
                    
                    [[AlexC2SBiddingParameterManager sharedInstance] removeRequestItemWithUnitID:slotIdStr];
                    return;
                }
            }
            
            self->_customEvent = [[AlexGromoreInterstitialCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
            self->_customEvent.requestCompletionBlock = completion;
            
            BUAdSlot *slot = [[BUAdSlot alloc] init];
            slot.ID = slotIdStr;
            if (localInfo[kATExtraGromoreMutedKey] != nil) {
                slot.mediation.mutedIfCan = [localInfo[kATExtraGromoreMutedKey] boolValue];
            }
            
            self.interstitialAd = [[BUNativeExpressFullscreenVideoAd alloc] initWithSlot:slot];
            self.interstitialAd.delegate = self->_customEvent;
            [self.interstitialAd loadAdData];
        });
    };
    
    [[ATAPI sharedInstance] inspectInitFlagForNetwork:kATNetworkNameMobrain usingBlock:^NSInteger(NSInteger currentValue) {
        if (currentValue == 2) {
            load();
            return currentValue;
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self.observer name:kAdGromoreInitiatedKey object:nil];
        self.observer = nil;
        self.observer = [[NSNotificationCenter defaultCenter] addObserverForName:kAdGromoreInitiatedKey object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            load();
            [[NSNotificationCenter defaultCenter] removeObserver:weakSelf.observer name:kAdGromoreInitiatedKey object:nil];
            weakSelf.observer = nil;
        }];
        return currentValue;
    }];
}

#pragma mark - AlexC2SBiddingRequestProtocol
+ (void)bidRequestWithPlacementModel:(nonnull ATPlacementModel *)placementModel unitGroupModel:(nonnull ATUnitGroupModel *)unitGroupModel info:(nonnull NSDictionary *)info completion:(nonnull void (^)(ATBidInfo * _Nonnull, NSError * _Nonnull))completion {
    
    if (NSClassFromString(@"AlexGromoreBiddingRequest")) {
        [AlexGromoreBaseManager initWithCustomInfo:info localInfo:info];
        
        void(^startRequest)(void) = ^{
            AlexGromoreInterstitialCustomEvent *customEvent = [[AlexGromoreInterstitialCustomEvent alloc] initWithInfo:info localInfo:info];
            customEvent.isC2SBiding = YES;
            customEvent.networkAdvertisingID = unitGroupModel.content[@"slot_id"];
            
            id<AlexGromoreBiddingRequest_plus> request = [NSClassFromString(@"AlexGromoreBiddingRequest") new];
            request.unitGroup = unitGroupModel;
            request.placementID = placementModel.placementID;
            request.customEvent = customEvent;
            request.bidCompletion = completion;
            request.unitID = info[@"slot_id"];
            request.extraInfo = info;
            request.adType = ATAdFormatInterstitial;
            [[NSClassFromString(@"AlexGromoreC2SBiddingRequestManager") sharedInstance] startWithRequestItem:request];
        };
        
        [[ATAPI sharedInstance] inspectInitFlagForNetwork:kATNetworkNameMobrain usingBlock:^NSInteger(NSInteger currentValue) {
            if (currentValue == 2) {
                startRequest();
                return currentValue;
            }
            [[NSNotificationCenter defaultCenter] addObserverForName:kAdGromoreInitiatedKey object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
                startRequest();
            }];
            return currentValue;
        }];
    } else {
        completion(nil, [NSError errorWithDomain:@"com.alexGromore.C2SBiddingRequest" code:kATBiddingInitiatingFailedCode userInfo:@{NSLocalizedDescriptionKey:@"C2S bidding request has failed", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"Gromore Adapter not support"]}]);
    }
}

@end
