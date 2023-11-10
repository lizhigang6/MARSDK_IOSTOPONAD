//
//  AlexC2SBiddingParameterManager.m
//  AlexGromoreMixSDKAdapter
//
//  Created by Alex on 2022/3/21.
//  Copyright © 2022 Alex. All rights reserved.
//

#import "AlexC2SBiddingParameterManager.h"
#import "NSMutableDictionary+AlexAdditional.h"
#import "AlexSafeThreadDictionary.h"

@interface AlexC2SBiddingParameterManager()
@property(nonatomic, strong) AlexSafeThreadDictionary<NSString *, id<AlexC2SBiddingRequestProtocol> > *requestDic;
@property(nonatomic, strong) AlexSafeThreadDictionary *biddingDelegateDic;
@end

@implementation AlexC2SBiddingParameterManager

+ (instancetype)sharedInstance {
    static AlexC2SBiddingParameterManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AlexC2SBiddingParameterManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    _requestDic = [AlexSafeThreadDictionary dictionary];
    _biddingDelegateDic = [AlexSafeThreadDictionary dictionary];
    return self;
}

#pragma mark - request CRUD
- (void)saveRequestItem:(id<AlexC2SBiddingRequestProtocol>)request withUnitId:(NSString *)unitID{
    [self.requestDic AL_setDictValue:request key:unitID];
}

- (id<AlexC2SBiddingRequestProtocol>)getRequestItemWithUnitID:(NSString*)unitID {
    return [self.requestDic objectForKey:unitID];
}

- (void)removeRequestItemWithUnitID:(NSString*)unitID {
    [self.requestDic removeObjectForKey:unitID];
}

- (NSDictionary *)getRequests {
    return self.requestDic;
}

#pragma mark - delegate CRUD
- (void)saveBiddingDelegate:(id)delegate withUnitId:(NSString *)unitID{
    [self.biddingDelegateDic AL_setDictValue:delegate key:unitID];
}

- (id)getBiddingDelegateWithUnitId:(NSString *)unitID {
    return [self.biddingDelegateDic objectForKey:unitID];
}

- (void)removeBiddingDelegateWithUnitId:(NSString *)unitID{
    [self.biddingDelegateDic removeObjectForKey:unitID];
}

@end
