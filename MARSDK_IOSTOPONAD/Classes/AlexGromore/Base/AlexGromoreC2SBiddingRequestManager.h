//
//  AlexGromoreC2SBiddingRequestManager.h
//  AlexGromoreMixSDKAdapter
//
//  Created by Alex on 5/13/22.
//  Copyright © 2022 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlexC2SBiddingParameterManager.h"
#import "AlexGromoreBiddingRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface AlexGromoreC2SBiddingRequestManager : NSObject
+ (instancetype)sharedInstance;
- (void)startWithRequestItem:(AlexGromoreBiddingRequest *)request;
+ (NSString *)getPriceWithAd:(id)abuBaseAd;
+ (void)disposeLoadSuccessCall:(NSString *)priceStr customObject:(id)customObject unitID:(NSString *)unitID;
+ (void)disposeLoadFailCall:(NSError *)error key:(NSString *)keyStr unitID:(NSString *)unitID;
@end

NS_ASSUME_NONNULL_END
