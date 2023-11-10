//
//  AlexGromoreCacheManger.h
//  AlexGromoreMixSDKAdapter
//
//  Created by Alex on 8/23/23.
//  Copyright © 2023 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BUAdSDK/BUAdSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlexGromoreCacheManger : NSObject
+ (instancetype)sharedManager;
@property (nonatomic, strong) BUAdSDKConfiguration *gromoreConfiguration;
@end

NS_ASSUME_NONNULL_END
