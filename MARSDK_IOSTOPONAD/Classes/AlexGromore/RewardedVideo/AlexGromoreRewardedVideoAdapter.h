//
//  AlexGromoreRewardedVideoAdapter.h
//  AlexGromoreMixSDKAdapter
//
//  Created by Alex on 2/1/21.
//  Copyright © 2021 . All rights reserved.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlexGromoreRewardedVideoAdapter : NSObject
@property (nonatomic,copy) void (^metaDataDidLoadedBlock)(void);
- (instancetype)initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo;
- (void)loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion;
@end

NS_ASSUME_NONNULL_END
