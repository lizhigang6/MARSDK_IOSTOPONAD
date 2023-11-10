//
//  AlexGromoreRewardedVideoAdapter.m
//  AlexGromoreMixSDKAdapter
//
//  Created by Alex on 2/1/21.
//  Copyright © 2021 . All rights reserved.
//

#import "AlexGromoreRewardedVideoAdapter.h"
#import "AlexC2SBiddingParameterManager.h"
#import <BUAdSDK/BUAdSDK.h>
#import "AlexGromoreBaseManager.h"
#import "AlexGromoreRewardedVideoCustomEvent.h"
#import "AlexGromoreRewardedVideoAgainCustomEvent.h"

@interface AlexGromoreRewardedVideoAdapter ()<ATAdAdapter, ATAdAdapterC2S>
@property (nonatomic, readonly) AlexGromoreRewardedVideoCustomEvent *customEvent;
@property (nonatomic, readonly) BUNativeExpressRewardedVideoAd *rewardedVideoAd;
@property (nonatomic, strong) id observer;
@end

@implementation AlexGromoreRewardedVideoAdapter

+ (BOOL)adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    return ((BUNativeExpressRewardedVideoAd*)customObject).mediation.isReady;
}

+ (void)showRewardedVideo:(ATRewardedVideo*)rewardedVideo inViewController:(UIViewController*)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    AlexGromoreRewardedVideoCustomEvent *customEvent = (AlexGromoreRewardedVideoCustomEvent*)rewardedVideo.customEvent;
    customEvent.rewardedVideo = rewardedVideo;
    customEvent.delegate = delegate;
    customEvent.againCustomEvent.rewardedVideo = rewardedVideo;
    customEvent.againCustomEvent.delegate = delegate;
    [((BUNativeExpressRewardedVideoAd *)rewardedVideo.customObject) showAdFromRootViewController:viewController];
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
                        self->_customEvent = (AlexGromoreRewardedVideoCustomEvent*)request.customEvent;
                        self->_customEvent.requestCompletionBlock = completion;
                        self->_customEvent.customEventMetaDataDidLoadedBlock = self.metaDataDidLoadedBlock;
                        
                        self->_rewardedVideoAd = request.customObject;
                        if (self->_rewardedVideoAd.mediation.isReady) {
                            [self->_customEvent trackRewardedVideoAdLoaded:self->_rewardedVideoAd adExtra:nil];
                        } else {
                            [self->_rewardedVideoAd loadAdData];
                        }
                    }
                    
                    [[AlexC2SBiddingParameterManager sharedInstance] removeRequestItemWithUnitID:slotIdStr];
                    return;
                }
            }
            
            AlexGromoreRewardedVideoAgainCustomEvent *againCustomEvent = [[AlexGromoreRewardedVideoAgainCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
            self->_customEvent = [[AlexGromoreRewardedVideoCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
            self->_customEvent.requestCompletionBlock = completion;
            self->_customEvent.customEventMetaDataDidLoadedBlock = self.metaDataDidLoadedBlock;
            self->_customEvent.againCustomEvent = againCustomEvent;
            
            BURewardedVideoModel *model = [[BURewardedVideoModel alloc] init];
            if (localInfo[kATAdLoadingExtraUserIDKey] != nil) {
                model.userId = localInfo[kATAdLoadingExtraUserIDKey];
            }
            if ([localInfo[kATAdLoadingExtraMediaExtraKey] isKindOfClass:[NSString class]]) {
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
            
            self->_rewardedVideoAd = [[BUNativeExpressRewardedVideoAd alloc] initWithSlot:slot rewardedVideoModel:model];
            self->_rewardedVideoAd.delegate = self->_customEvent;
            self->_rewardedVideoAd.rewardPlayAgainInteractionDelegate = againCustomEvent;
            [self.rewardedVideoAd loadAdData];
            NSLog(@"self.rewardedVideoAd loadAdData");
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
            AlexGromoreRewardedVideoAgainCustomEvent *againCustomEvent = [[AlexGromoreRewardedVideoAgainCustomEvent alloc] initWithInfo:info localInfo:info];
            AlexGromoreRewardedVideoCustomEvent *customEvent = [[AlexGromoreRewardedVideoCustomEvent alloc] initWithInfo:info localInfo:info];
            customEvent.isC2SBiding = YES;
            customEvent.networkAdvertisingID = unitGroupModel.content[@"slot_id"];
            customEvent.againCustomEvent = againCustomEvent;
            
            id<AlexGromoreBiddingRequest_plus> request = [NSClassFromString(@"AlexGromoreBiddingRequest") new];
            request.unitGroup = unitGroupModel;
            request.placementID = placementModel.placementID;
            request.customEvent = customEvent;
            request.bidCompletion = completion;
            request.unitID = info[@"slot_id"];
            request.extraInfo = info;
            request.adType = ATAdFormatRewardedVideo;
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
