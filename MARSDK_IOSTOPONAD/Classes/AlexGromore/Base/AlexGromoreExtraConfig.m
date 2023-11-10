//
//  AlexGromoreExtraConfig.m
//  AlexGromoreMixSDKAdapter
//
//  Created by Alex on 2022/8/26.
//  Copyright © 2022 . All rights reserved.
//

#import "AlexGromoreExtraConfig.h"

@implementation AlexGromoreExtraConfig
+ (void)setExtraConfig:(void(^_Nullable)(BUAdSDKConfiguration * _Nullable configuration))extraConfigBlock {
    if (extraConfigBlock) {
        BUAdSDKConfiguration *configuration = [BUAdSDKConfiguration configuration];
        extraConfigBlock(configuration);
    }
}
@end
