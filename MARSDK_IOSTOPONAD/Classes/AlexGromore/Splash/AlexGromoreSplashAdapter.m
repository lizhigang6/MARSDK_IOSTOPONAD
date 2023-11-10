//
//  AlexGromoreSplashAdapter.m
//  AlexGromoreMixSDKAdapter
//
//  Created by Alex on 2/1/21.
//  Copyright © 2021 . All rights reserved.
//

#import "AlexGromoreSplashAdapter.h"
#import "AlexC2SBiddingParameterManager.h"
#import <BUAdSDK/BUAdSDK.h>
#import "AlexGromoreBaseManager.h"
#import "AlexGromoreSplashCustomEvent.h"

@interface AlexGromoreSplashAdapter ()<ATAdAdapter, ATAdAdapterC2S>
@property (nonatomic, strong) AlexGromoreSplashCustomEvent *customEvent;
@property (nonatomic, strong) BUSplashAd *splashAd;
@property (nonatomic, strong) id observer;
@end

@implementation AlexGromoreSplashAdapter

+ (BOOL)adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    return customObject != nil;
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
                        self->_customEvent = (AlexGromoreSplashCustomEvent*)request.customEvent;
                        self->_customEvent.requestCompletionBlock = completion;
                        self->_customEvent.delegate = self.delegateToBePassed;
                        
                        self->_splashAd = request.customObject;
                        if (self->_splashAd.mediation.isReady) {
                            [self->_customEvent trackSplashAdLoaded:self->_splashAd adExtra:nil];
                        } else {
                            [self->_splashAd loadAdData];
                        }
                    }
                    
                    [[AlexC2SBiddingParameterManager sharedInstance] removeRequestItemWithUnitID:slotIdStr];
                    return;
                }
            }
            
            self->_customEvent = [[AlexGromoreSplashCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
            self->_customEvent.requestCompletionBlock = completion;
            self->_customEvent.delegate = self.delegateToBePassed;
            
            NSDictionary *slotInfo = [NSJSONSerialization JSONObjectWithData:[serverInfo[@"slot_info"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            
            NSNumber *timeout = localInfo[kATSplashExtraTolerateTimeoutKey];
            NSTimeInterval tolerateTimeout = timeout ? [timeout doubleValue] : 5;
            
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
            
            self->_splashAd = [[BUSplashAd alloc] initWithSlot:slot adSize:CGSizeZero];
            self->_splashAd.delegate = self->_customEvent;
            self->_splashAd.zoomOutDelegate = self->_customEvent;
            self->_splashAd.tolerateTimeout = tolerateTimeout;
            if (localInfo[kATSplashExtraContainerViewKey] != nil) {
                UIView *containerView = localInfo[kATSplashExtraContainerViewKey];
                self->_splashAd.mediation.customBottomView = [AlexGromoreBaseManager captureScreenForView:containerView];
            }
            if ([slotInfo[@"common"][@"btn_type"] intValue] == 0) {
                self->_splashAd.mediation.splashButtonType = BUMSplashButtonTypeFullScreen;
            } else if ([slotInfo[@"common"][@"btn_type"] intValue] == 1) {
                self->_splashAd.mediation.splashButtonType = BUMSplashButtonTypeDownloadBar;
            }
            self->_splashAd.supportZoomOutView = [slotInfo[@"common"][@"zoomoutad_sw"] integerValue] == 2 ? YES : NO;
            [self->_splashAd loadAdData];
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

+ (void)showSplash:(ATSplash *)splash localInfo:(NSDictionary *)localInfo delegate:(id<ATSplashDelegate>)delegate{
    BUSplashAd *splashAd = splash.customObject;
    splash.customEvent.delegate = delegate;
    UIWindow *window = localInfo[kATSplashExtraWindowKey];
    [splashAd showSplashViewInRootViewController:window.rootViewController];
}

#pragma mark - AlexC2SBiddingRequestProtocol
+ (void)bidRequestWithPlacementModel:(nonnull ATPlacementModel *)placementModel unitGroupModel:(nonnull ATUnitGroupModel *)unitGroupModel info:(nonnull NSDictionary *)info completion:(nonnull void (^)(ATBidInfo * _Nonnull, NSError * _Nonnull))completion {
    if (NSClassFromString(@"AlexGromoreBiddingRequest")) {
        [AlexGromoreBaseManager initWithCustomInfo:info localInfo:info];
        
        void(^startRequest)(void) = ^{
            AlexGromoreSplashCustomEvent *customEvent = [[AlexGromoreSplashCustomEvent alloc] initWithInfo:info localInfo:info];
            customEvent.isC2SBiding = YES;
            customEvent.networkAdvertisingID = unitGroupModel.content[@"slot_id"];
            
            id<AlexGromoreBiddingRequest_plus> request = [NSClassFromString(@"AlexGromoreBiddingRequest") new];
            request.unitGroup = unitGroupModel;
            request.placementID = placementModel.placementID;
            request.customEvent = customEvent;
            request.bidCompletion = completion;
            request.unitID = info[@"slot_id"];
            request.extraInfo = info;
            request.adType = ATAdFormatSplash;
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
