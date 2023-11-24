//
//  AlexGromoreBaseManager.h
//  AlexGromoreMixSDKAdapter
//
//  Created by Alex on 2/1/21.
//  Copyright © 2021 . All rights reserved.
//

#import <AnyThinkSDK/AnyThinkSDK.h>
#import <BUAdSDK/BUAdSDK.h>

NS_ASSUME_NONNULL_BEGIN
#pragma mark - Gromore
// kATSplashExtraGromoreAdnTypeKey Obsolete, please use kATSplashExtraGromoreAdnNameKey to pass in, the name of adn, please use the following values'pangle','baidu','gdt','ks', other values may cause the advertisement to fail to load
extern NSString *const kATSplashExtraGromoreAdnNameKey;
extern NSString *const kATSplashExtraGromoreAppKeyKey;
extern NSString *const kATSplashExtraGromoreAppIDKey;
extern NSString *const kATSplashExtraGromoreRIDKey;
/**
 optional
 Set whether to mute the video，YES = mute，NO = unMute
 PS:
 1、RV：only  GDT，Klevin，MTG support setting mute
 2、IV：only  GDT support setting mute
 3、Native video：only  GDT，Admob，Baidu，MTG support setting mute
 */
extern NSString *const kATExtraGromoreMutedKey;

static NSString * kAdGromoreInitiatedKey = @"kAdGromoreInitiatedKey";

@interface AlexGromoreBaseManager : ATNetworkBaseManager
+ (UIImageView *)captureScreenForView:(UIView *)currentView;
+ (NSMutableDictionary *)AL_getExtraForRitInfo:(BUMRitInfo *)info;
+ (void)AL_Dictionary:(NSMutableDictionary *)dictionary setValue:(id)value forKey:(NSString *)key;
+ (void)AL_logMessage:(NSString *)message;
@end

@protocol AlexGromoreBiddingRequest_plus <NSObject>
@property (nonatomic, strong) id customObject;
@property (nonatomic, strong) ATUnitGroupModel *unitGroup;
@property (nonatomic, strong) ATAdCustomEvent *customEvent;
@property (nonatomic, copy) NSString *unitID;
@property (nonatomic, copy) NSString *placementID;
@property (nonatomic, copy) NSDictionary *extraInfo;
@property (nonatomic, copy) NSArray *nativeAds;
@property (nonatomic, strong) UIView *bannerView;
@property (nonatomic, copy) void(^bidCompletion)(ATBidInfo * _Nullable bidInfo, NSError * _Nullable error);
@property (nonatomic, assign) ATAdFormat adType;
@end

@protocol AlexGromoreC2SBiddingRequestManager_plus <NSObject>
+ (instancetype)sharedInstance;
- (void)startWithRequestItem:(id<AlexGromoreBiddingRequest_plus>)request;
+ (NSString *)getPriceWithAd:(id)abuBaseAd;
+ (void)disposeLoadSuccessCall:(NSString *)priceStr customObject:(id)customObject unitID:(NSString *)unitID;
+ (void)disposeLoadFailCall:(NSError *)error key:(NSString *)keyStr unitID:(NSString *)unitID;
@end

NS_ASSUME_NONNULL_END
