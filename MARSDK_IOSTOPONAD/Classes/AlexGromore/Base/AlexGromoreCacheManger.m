//
//  AlexGromoreCacheManger.m
//  AlexGromoreMixSDKAdapter
//
//  Created by Alex on 8/23/23.
//  Copyright © 2023 Alex. All rights reserved.
//

#import "AlexGromoreCacheManger.h"

@implementation AlexGromoreCacheManger

+ (instancetype)sharedManager {
    static AlexGromoreCacheManger *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[AlexGromoreCacheManger alloc] init];
    });
    return sharedManager;
}

- (BUAdSDKConfiguration *)gromoreConfiguration {
    if (_gromoreConfiguration) return _gromoreConfiguration;
    BUAdSDKConfiguration *gromoreConfiguration = [BUAdSDKConfiguration configuration];
    return _gromoreConfiguration = gromoreConfiguration;
}

@end
