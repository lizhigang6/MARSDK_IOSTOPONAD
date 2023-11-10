//
//  NSMutableDictionary+AlexAdditional.m
//  AlexGromoreMixSDKAdapter
//
//  Created by li Alex on 2023/7/21.
//  Copyright © 2023 Alex. All rights reserved.
//

#import "NSMutableDictionary+AlexAdditional.h"

@implementation NSMutableDictionary (AlexAdditional)

- (void)AL_setDictValue:(id)value key:(NSString *)key {
    if (!value || !key) {
        return;
    }
    [self setObject:value forKey:key];
}

@end
