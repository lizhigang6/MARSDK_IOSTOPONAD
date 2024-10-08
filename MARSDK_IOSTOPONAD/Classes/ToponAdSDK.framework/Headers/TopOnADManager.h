//
//  TopOnADManager.h
//  国内SDK
//
//  Created by js wu on 2021/12/29.
//

#import <Foundation/Foundation.h>
#import <AnyThinkSDK/AnyThinkSDK.h>
#import <AnyThinkSplash/AnyThinkSplash.h>
#import <AnyThinkBanner/AnyThinkBanner.h>
#import <AnyThinkRewardedVideo/AnyThinkRewardedVideo.h>
#import <AnyThinkInterstitial/AnyThinkInterstitial.h>
#import <MARSDKCore/MARAd.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TopOnADType) {
    TopOnADTypeRewarded,
    TopOnADTypeInterstitial,
    TopOnADTypeSplash,
    TopOnADTypeBanner,
    TopOnADTypeNativePatch
};






@interface TopOnADManager : NSObject

+ (instancetype)managerWithAppID:(NSString *)appID
                          appKey:(NSString *)appKey
                     rewardedKey:(NSString *)rewardedKey
                 interstitialKey:(NSString *)interstitialKey
                       splashKey:(NSString *)splashKey
                       bannerKey:(NSString *)bannerKey
                          userID:(NSString *)userID
                    bannerHighly:(NSString *)bannerHighly
                     bannerWidht:(NSString *)bannerWidht
                 native_splashId:(NSString *)native_splashId
                 native_bannerId:(NSString *)native_bannerId
                 native_plaqueId:(NSString *)native_plaqueId
                  native_patchId:(NSString *)native_patchId
                        float_Id:(NSString *)float_Id
                        showtime:(NSString *)showtime
                  bidding_enable:(NSString *)bidding_enable
                       spreadOut:(NSString *)spreadOut
                      DEBUGMODEL:(NSString *)DEBUGMODEL;




@property (nonatomic, copy, readonly) NSString *appID;
@property (nonatomic, copy, readonly) NSString *appKey;
@property (nonatomic, copy, readonly) NSArray *rewardedArray;
@property (nonatomic, copy, readonly) NSString *splashKey;
@property (nonatomic, copy, readonly) NSString *bannerKey;

@property (nonatomic, copy, readonly) NSString *userID;

@property (nonatomic, copy, readonly) NSString *bannerHighly;
@property (nonatomic, copy, readonly) NSString *bannerWidht;
@property (nonatomic, copy, readonly) NSString *DEBUGMODEL;



@property (nonatomic, copy, readonly) NSString *native_splashId;
@property (nonatomic, copy, readonly) NSString *native_patchId;
@property (nonatomic, copy, readonly) NSString *float_Id;

@property (nonatomic, copy, readonly) NSString *showtime;

@property (nonatomic, copy, readonly) NSString *spreadOut;

@property (nonatomic,strong) NSString *inters_shake;
@property (nonatomic,strong) NSString *splash_shake;


//是否正在播放广告 （插屏、开屏、激励）
@property (assign, nonatomic) BOOL  isAdsBeingDisplayed;



//是否正在播放广告  贴片
@property (assign, nonatomic) BOOL  isShowPatchAD;

//是否正在播放广告 插屏
@property (assign, nonatomic) BOOL  isShowPlaqueAD;

//是否正在播放广告 激励
@property (assign, nonatomic) BOOL  isShowIncentiveAD;



@property id<MARAdPopupDelegate> Popupdelegate;
@property id<MARAdBannerDelegate> Bannerdelegate;
@property id<MARAdSplashDelegate> Splashdelegate;
@property id<MARAdRewardedDelegate> Rewardeddelegate;
@property id<MARAdNativeDelegate> Nativedelegate;


///  获取MARAction的单例
+(instancetype) sharedInstance;
+ (instancetype)manager;

- (void)NetworkInspection;

- (void)showBanner;

- (void)hideBanner;

-(void)originalPatch;

-(void)hideOriginalPatch;

- (void)showSplash;

- (void)showPatchAD;

- (void)hideNativePatch;
//   显示悬浮广告
-(void)showNativeAD:(CGPoint)Point;
//   隐藏悬浮广告
- (void) hideFloatAd;



- (void)showInterstitialWithScene:(NSString *)scene closeHandler:(void(^)(void))closeHandler;

- (void)showRewardedWithscene:(NSString *)scene closeHandler:(void(^)(BOOL rewarded))closeHandler;

- (void)showRewardedWithCloseHandler:(void(^)(BOOL rewarded))closeHandler;

- (void)showSpecialRewardAd;

- (void)showRewardedWithScene:(NSString *)scene closeHandler:(void(^)(BOOL rewarded))closeHandler;
- (BOOL)isReadyByType:(TopOnADType)type;

-(BOOL) adControlSwitch:(NSString *)AdID;

@property (nonatomic, copy) void(^rewardedVideoDidClick)(NSString *placementID, NSDictionary *extra);
@property (nonatomic, copy) void(^rewardedVideoDidClose)(NSString *placementID, BOOL rewarded, NSDictionary *extra);
@property (nonatomic, copy) void(^rewardedVideoDidDeepLinkOrJump)(NSString *placementID, NSDictionary *extra, BOOL result);
@property (nonatomic, copy) void(^rewardedVideoDidEndPlaying)(NSString *placementID, NSDictionary *extra);
@property (nonatomic, copy) void(^rewardedVideoDidFailToPlay)(NSString *placementID,  NSError *error, NSDictionary *extra);
@property (nonatomic, copy) void(^rewardedVideoDidRewardSuccess)(NSString *placementID, NSDictionary *extra);
@property (nonatomic, copy) void(^rewardedVideoDidStartPlaying)(NSString *placementID, NSDictionary *extra);

@property (nonatomic, copy) void(^interstitialDidClick)(NSString *placementID, NSDictionary *extra);
@property (nonatomic, copy) void(^interstitialDidClose)(NSString *placementID, NSDictionary *extra);
@property (nonatomic, copy) void(^interstitialDeepLinkOrJump)(NSString *placementID, NSDictionary *extra, BOOL result);
@property (nonatomic, copy) void(^interstitialDidEndPlayingVideo)(NSString *placementID, NSDictionary *extra);
@property (nonatomic, copy) void(^interstitialDidFailToPlayVideo)(NSString *placementID,  NSError *error, NSDictionary *extra);
@property (nonatomic, copy) void(^interstitialDidShow)(NSString *placementID, NSDictionary *extra);
@property (nonatomic, copy) void(^interstitialDidStartPlayingVideo)(NSString *placementID, NSDictionary *extra);
@property (nonatomic, copy) void(^interstitialFailedToShow)(NSString *placementID, NSError *error, NSDictionary *extra);

@property (nonatomic, copy) void(^splashCountdown)(NSInteger countdown, NSString *placementID, NSDictionary *extra);
@property (nonatomic, copy) void(^splashDeepLinkOrJump)(NSString *placementID, NSDictionary *extra, BOOL result);
@property (nonatomic, copy) void(^splashDetailDidClosed)(NSString *placementID, NSDictionary *extra);
@property (nonatomic, copy) void(^splashDidClick)(NSString *placementID, NSDictionary *extra);
@property (nonatomic, copy) void(^splashDidClose)(NSString *placementID, NSDictionary *extra);
@property (nonatomic, copy) void(^splashDidShowFailed)(NSString *placementID, NSError *error, NSDictionary *extra);
@property (nonatomic, copy) void(^splashDidShow)(NSString *placementID, NSDictionary *extra);
@property (nonatomic, copy) void(^splashZoomOutViewDidClick)(NSString *placementID, NSDictionary *extra);
@property (nonatomic, copy) void(^splashZoomOutViewDidClose)(NSString *placementID, NSDictionary *extra);

@property (nonatomic, copy) void(^bannerViewDidAutoRefresh)(ATBannerView *bannerView, NSString *placementID, NSDictionary *extra);
@property (nonatomic, copy) void(^bannerViewDidClick)(ATBannerView *bannerView, NSString *placementID, NSDictionary *extra);
@property (nonatomic, copy) void(^bannerViewDidClose)(ATBannerView *bannerView, NSString *placementID, NSDictionary *extra);
@property (nonatomic, copy) void(^bannerViewDidDeepLinkOrJump)(ATBannerView *bannerView, NSString *placementID, NSDictionary *extra, BOOL result);
@property (nonatomic, copy) void(^bannerViewDidShowAd)(ATBannerView *bannerView, NSString *placementID, NSDictionary *extra);
@property (nonatomic, copy) void(^bannerViewDidTapCloseButton)(ATBannerView *bannerView, NSString *placementID, NSDictionary *extra);
@property (nonatomic, copy) void(^bannerViewFailedToAutoRefresh)(ATBannerView *bannerView, NSString *placementID, NSError *error);

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;



-(void)readycache;
-(void)handlerTopOnRewardedDelegate;

-(UIViewController *)getCurrentVC;

-(void)clickCallback:(NSDictionary *)dict type:(NSString *)type;
-(void)trackAd:(NSString *)type  adType:(NSString *)adType   adDict:(NSDictionary *)adDict;
-(void)userDfinedEvents:(NSString *)adId type:(NSString *)type;
-(void)clickAdvertising:(NSString *)adId adPlatform:(NSString *)adPlatform;
-(void)displayAvertising:(NSString *)adId  adPlatform:(NSString *)adPlatform isSuccess:(NSString *)isSuccess;

@end

NS_ASSUME_NONNULL_END
