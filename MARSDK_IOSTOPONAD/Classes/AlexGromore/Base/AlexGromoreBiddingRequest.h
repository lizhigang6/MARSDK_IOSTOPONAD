//
//  AlexGromoreBiddingRequest.h
//  AlexGromoreMixSDKAdapter
//
//  Created by Alex on 5/13/22.
//  Copyright © 2022 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlexC2SBiddingRequestProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface AlexGromoreBiddingRequest : NSObject<ATC2SBiddingParameterProtocol>
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

NS_ASSUME_NONNULL_END
