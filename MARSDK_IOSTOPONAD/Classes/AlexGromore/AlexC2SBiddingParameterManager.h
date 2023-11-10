//
//  AlexC2SBiddingParameterManager.h
//  AlexGromoreMixSDKAdapter
//
//  Created by Alex on 2022/3/21.
//  Copyright © 2022 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlexC2SBiddingRequestProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface AlexC2SBiddingParameterManager : NSObject
+ (instancetype)sharedInstance;
- (void)saveRequestItem:(id<ATC2SBiddingParameterProtocol>)request withUnitId:(NSString *)unitID;
- (id<ATC2SBiddingParameterProtocol>)getRequestItemWithUnitID:(NSString*)unitID;
- (void)removeRequestItemWithUnitID:(NSString*)unitID;
- (NSDictionary *)getRequests;
- (void)saveBiddingDelegate:(id)delegate withUnitId:(NSString *)unitID;
- (id)getBiddingDelegateWithUnitId:(NSString *)unitID;
- (void)removeBiddingDelegateWithUnitId:(NSString *)unitID;
@end

NS_ASSUME_NONNULL_END
