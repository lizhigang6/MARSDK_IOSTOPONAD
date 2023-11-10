//
//  AlexGromoreBannerAdapter.m
//  AlexGromoreMixSDKAdapter
//
//  Created by Alex on 2/1/21.
//  Copyright © 2021 Alex. All rights reserved.
//

#import "AlexGromoreBannerAdapter.h"
#import "AlexC2SBiddingParameterManager.h"
#import "AlexGromoreBaseManager.h"
#import "AlexGromoreBannerCustomEvent.h"

#import <BUAdSDK/BUAdSDK.h>

@interface AlexGromoreBannerAdapter ()
@property (nonatomic, strong) AlexGromoreBannerCustomEvent *customEvent;
@property (nonatomic, strong) BUNativeExpressBannerView *bannerAd;
@property (nonatomic, strong) id observer;
@end

@implementation AlexGromoreBannerAdapter

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [AlexGromoreBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    __weak typeof(self) weakSelf = self;
    void(^load)(void) = ^{
        NSString *slotIdStr = serverInfo[@"slot_id"];
        NSString *bidId = serverInfo[kATAdapterCustomInfoBuyeruIdKey];
    
        // C2S
        if (bidId) {
            if (NSClassFromString(@"AlexGromoreBiddingRequest")) {
                id<AlexGromoreBiddingRequest_plus> request = [[AlexC2SBiddingParameterManager sharedInstance] getRequestItemWithUnitID:slotIdStr];
                if (request != nil && request.customObject) {
                    self->_customEvent = (AlexGromoreBannerCustomEvent*)request.customEvent;
                    self->_customEvent.requestCompletionBlock = completion;
                    
                    self.bannerAd = (BUNativeExpressBannerView *)request.customObject;
                    [weakSelf.customEvent trackBannerAdLoaded:request.bannerView adExtra:nil];
                }
    
                [[AlexC2SBiddingParameterManager sharedInstance] removeRequestItemWithUnitID:slotIdStr];
                return;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
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
            
            self->_customEvent = [[AlexGromoreBannerCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
            self->_customEvent.requestCompletionBlock = completion;
            
            BUAdSlot *slot = [[BUAdSlot alloc] init];
            slot.ID = slotIdStr;
            if (localInfo[kATExtraGromoreMutedKey] != nil) {
                slot.mediation.mutedIfCan = [localInfo[kATExtraGromoreMutedKey] boolValue];
            }
            self->_bannerAd = [[BUNativeExpressBannerView alloc] initWithSlot:slot rootViewController:[UIApplication sharedApplication].keyWindow.rootViewController adSize:adSize];
            self->_bannerAd.delegate = self->_customEvent;
            [self->_bannerAd loadAdData];
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
            AlexGromoreBannerCustomEvent *customEvent = [[AlexGromoreBannerCustomEvent alloc] initWithInfo:info localInfo:info];
            customEvent.isC2SBiding = YES;
            customEvent.networkAdvertisingID = unitGroupModel.content[@"slot_id"];
            
            id<AlexGromoreBiddingRequest_plus> request = [NSClassFromString(@"AlexGromoreBiddingRequest") new];
            request.unitGroup = unitGroupModel;
            request.placementID = placementModel.placementID;
            request.customEvent = customEvent;
            request.bidCompletion = completion;
            request.unitID = info[@"slot_id"];
            request.extraInfo = info;
            request.adType = ATAdFormatBanner;
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
