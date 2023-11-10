//
//  AlexC2SBiddingRequestProtocol.h
//  AlexGromoreMixSDKAdapter
//
//  Created by Alex on 2022/3/21.
//  Copyright © 2022 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AnyThinkSDK/AnyThinkSDK.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, ATGDTLossSeatIDType) {
    ATGDTLossSeatIDTypeLossGDTNormal = 1, //输给优量汇其它非Bidding广告源
    ATGDTLossSeatIDTypeLossNotGDT, //输给第三方ADN
    ATGDTLossSeatIDTypeLossSelf, //输给自售广告主 直投广告、交叉推广
    ATGDTLossSeatIDTypeLossGDTBidding, //输给优量汇其它Bidding广告源
};

typedef NS_ENUM(NSUInteger, ATGDTLossUserInfoKeyType) {
    ATGDTLossUserInfoKeyTypeNetworkFirmID = 1, //输给优量汇其它非Bidding广告源
    ATGDTLossUserInfoKeyTypeSeatId,
};

@protocol ATC2SBiddingParameterProtocol <NSObject>
@optional
@property(nonatomic, strong) id customObject;
@property(nonatomic, strong) ATUnitGroupModel *unitGroup;
@property(nonatomic, strong) ATAdCustomEvent *customEvent;
@property(nonatomic, copy) NSString *unitID;
@property(nonatomic, copy) NSString *publisherID;
@property(nonatomic, copy) NSString *placementID;
@property(nonatomic, copy) NSDictionary *extraInfo;
@property(nonatomic, copy) NSArray* nativeAds;
@property(nonatomic, copy) void(^bidCompletion)(ATBidInfo * _Nullable bidInfo, NSError * _Nullable error);
@property(nonatomic, assign) ATAdFormat adType;
@end

@protocol AlexC2SBiddingRequestProtocol <NSObject>
+(void) bidRequestWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion;
@optional
+ (void) sendWinnerNotifyWithCustomObject:(id)customObject secondPrice:(NSString*)price userInfo:(NSDictionary<NSString *, NSString *> *)userInfo;
+ (void)sendLossNotifyWithCustomObject:(nonnull id)customObject lossType:(ATBiddingLossType)lossType winPrice:(nonnull NSString *)price userInfo:(NSDictionary *)userInfo;
@end

NS_ASSUME_NONNULL_END
