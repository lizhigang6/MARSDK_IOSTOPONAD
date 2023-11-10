//
//  AlexGromoreNativeAdapter.m
//  AlexGromoreMixSDKAdapter
//
//  Created by Alex on 2/1/21.
//  Copyright © 2021 . All rights reserved.
//

#import "AlexGromoreNativeAdapter.h"
#import "AlexC2SBiddingParameterManager.h"
#import <BUAdSDK/BUAdSDK.h>
#import "AlexGromoreBaseManager.h"
#import "AlexGromoreNativeCustomEvent.h"
#import "AlexGromoreNativeRenderer.h"

@interface AlexGromoreNativeAdapter ()<ATAdAdapter, ATAdAdapterC2S>
@property (nonatomic, readonly) AlexGromoreNativeCustomEvent *customEvent;
@property (nonatomic, strong) BUNativeAdsManager *adManager;
@property (nonatomic, strong) id observer;
@end

@implementation AlexGromoreNativeAdapter

+ (Class)rendererClass {
    return [AlexGromoreNativeRenderer class];
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
                        self->_customEvent = (AlexGromoreNativeCustomEvent*)request.customEvent;
                        self->_customEvent.requestCompletionBlock = completion;
                        
                        self->_adManager = request.customObject;
                        self->_adManager.delegate = self->_customEvent;
                        [self->_customEvent loadedWithAdsManager:self->_adManager nativeAdViewArray:request.nativeAds];
                    }
                    [[AlexC2SBiddingParameterManager sharedInstance] removeRequestItemWithUnitID:slotIdStr];
                    return;
                }
            }
            
            self->_customEvent = [[AlexGromoreNativeCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
            self->_customEvent.requestCompletionBlock = completion;
            
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
            
            BUSize *imgBUSize = [[BUSize alloc] init];
            imgBUSize.width = imgSize.width;
            imgBUSize.height = imgSize.height;
            
            BUAdSlot *slot = [[BUAdSlot alloc] init];
            slot.imgSize = imgBUSize;
            slot.ID = slotIdStr;
            slot.adSize = adSize;
            if (localInfo[kATExtraGromoreMutedKey] != nil) {
                slot.mediation.mutedIfCan = [localInfo[kATExtraGromoreMutedKey] boolValue];
            }
            self.adManager = [[BUNativeAdsManager alloc] initWithSlot:slot];
            self.adManager.mediation.rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
            self.adManager.delegate = self->_customEvent;
            
            NSNumber *number = serverInfo[@"request_num"];
            [self.adManager loadAdDataWithCount:number ? [number integerValue] : 1];
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
            AlexGromoreNativeCustomEvent *customEvent = [[AlexGromoreNativeCustomEvent alloc] initWithInfo:info localInfo:info];
            customEvent.isC2SBiding = YES;
            customEvent.networkAdvertisingID = unitGroupModel.content[@"slot_id"];
            
            id<AlexGromoreBiddingRequest_plus> request = [NSClassFromString(@"AlexGromoreBiddingRequest") new];
            request.unitGroup = unitGroupModel;
            request.placementID = placementModel.placementID;
            request.customEvent = customEvent;
            request.bidCompletion = completion;
            request.unitID = info[@"slot_id"];
            request.extraInfo = info;
            request.adType = ATAdFormatNative;
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
