//  AlexSafeThreadDictionary.h
//  AlexGromoreMixSDKAdapter
//
//  Created by Alex on 2020/9/21.
//  Copyright © 2020 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 A simple implementation of thread safe mutable dictionary.
 
 @discussion Generally, access performance is lower than NSMutableDictionary,
 but higher than using @synchronized, NSLock, or pthread_mutex_t.
 
 @warning Fast enumerate(for...in) and enumerator is not thread safe,
 use enumerate using block instead. When enumerate or sort with block/callback,
 do *NOT* send message to the dictionary inside the block/callback.
 */
@interface AlexSafeThreadDictionary<KeyType, ObjectType> : NSMutableDictionary

@end
