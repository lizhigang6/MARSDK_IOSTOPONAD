//
//  AlexGromoreBaseManager.m
//  AlexGromoreMixSDKAdapter
//
//  Created by Alex on 2/1/21.
//  Copyright © 2021 . All rights reserved.
//

#import "AlexGromoreBaseManager.h"
#import "AlexGromoreCacheManger.h"

#pragma mark - Gromore
NSString *const kATSplashExtraGromoreRIDKey = @"at_splash_rid";
NSString *const kATSplashExtraGromoreAppIDKey = @"at_splash_app_id";
NSString *const kATSplashExtraGromoreAdnNameKey = @"at_splash_gromore_adn_name";
NSString *const kATSplashExtraGromoreAppKeyKey = @"at_splash_gromore_app_key";
NSString *const kATExtraGromoreMutedKey = @"at_extra_gromore_muted_key";

@implementation AlexGromoreBaseManager

+ (void)initWithCustomInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[ATAPI sharedInstance] setVersion:[BUAdSDKManager SDKVersion] forNetwork:kATNetworkNameMobrain];
        if (![[ATAPI sharedInstance] initFlagForNetwork:kATNetworkNameMobrain]) {
            [[ATAPI sharedInstance] setInitFlagForNetwork:kATNetworkNameMobrain];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (NSClassFromString(@"ATTTMixBaseManager")) {
                     // 动态调用CSJ融合初始化方法，避免重复初始化
                    [NSClassFromString(@"ATTTMixBaseManager") initWithCustomInfo:serverInfo localInfo:localInfo];
                    return;
                }
                
                // SDK初始化接口
                BUAdSDKConfiguration *configuration = [AlexGromoreCacheManger sharedManager].gromoreConfiguration;
                configuration.appID = serverInfo[@"app_id"];
                configuration.useMediation = YES;
                
                NSInteger state = [[ATAPI sharedInstance] getPersonalizedAdState] == ATNonpersonalizedAdStateType ? 1 : 0;
                configuration.mediation.limitPersonalAds = @(state);
                [BUAdSDKManager startWithAsyncCompletionHandler:^(BOOL success, NSError *error) {
                    [[ATAPI sharedInstance] setInitFlag:2 forNetwork:kATNetworkNameMobrain];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kAdGromoreInitiatedKey object:nil];
                }];
            });
        }
    });
}

+ (UIImageView *)captureScreenForView:(UIView *)currentView {
    // UIGraphicsBeginImageContextWithOptions xcode15上17.0以上机器debug下当size宽或高为0时会报assert，所以先做个判断
    if (!(currentView && currentView.frame.size.height > 0 && currentView.frame.size.width > 0)) {
        return [[UIImageView alloc]initWithFrame:CGRectZero];;
    }
    if (@available(iOS 10.0, *)) {
        UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat defaultFormat];
        format.opaque = NO;
        format.scale = [UIScreen mainScreen].scale;
        UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:currentView.frame.size format:format];
        UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
            [currentView.layer renderInContext:context.CGContext];
        }];
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:currentView.frame];
        imageView.image = image;
        return imageView;
    } else {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(currentView.frame.size.width, currentView.frame.size.height), NO, 0.0);//原图
        [currentView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:currentView.frame];
        imageView.image = viewImage;
        return imageView;
    }
}

+ (NSMutableDictionary *)AL_getExtraForRitInfo:(BUMRitInfo *)info {
    NSMutableDictionary *extra = [NSMutableDictionary dictionary];
    [AlexGromoreBaseManager AL_Dictionary:extra setValue:info.adnName forKey:@"network_name"];
    [AlexGromoreBaseManager AL_Dictionary:extra setValue:info.slotID forKey:@"network_unit_id"];
    [AlexGromoreBaseManager AL_Dictionary:extra setValue:info.ecpm forKey:@"network_ecpm"];
    [AlexGromoreBaseManager AL_Dictionary:extra setValue:info.requestID forKey:@"request_id"];
    [AlexGromoreBaseManager AL_Dictionary:extra setValue:@(info.biddingType) forKey:@"bidding_type"];
    return extra;
}

+ (void)AL_Dictionary:(NSMutableDictionary *)dictionary setValue:(id)value forKey:(NSString *)key {
    if (!dictionary || !value || !key) {
        return;
    }
    [dictionary setObject:value forKey:key];
}

+ (void)AL_logMessage:(NSString *)message {
    NSString *string = [NSString stringWithFormat:@"💚💚 AlexGromore Message:%@ 💚", message];
    NSLog(@"%@", string);
}

@end
