//
//  AlexGromoreNativeRenderer.m
//  AlexGromoreMixSDKAdapter
//
//  Created by Alex on 2/1/21.
//  Copyright © 2021 . All rights reserved.
//

#import "AlexGromoreNativeRenderer.h"
#import <BUAdSDK/BUAdSDK.h>
#import "AlexGromoreNativeCustomEvent.h"

@protocol ATNativeADView<NSObject>
@property (nonatomic, readonly) ATNativeADCache *nativeAd;
@end

@interface AlexGromoreNativeRenderer ()
@property (nonatomic, strong) BUMCanvasView *canvasView;
@property (nonatomic, assign) CGFloat expressAdHeight;
@property (nonatomic, assign) BOOL isAddKVOframe;
@end

@implementation AlexGromoreNativeRenderer

- (void)bindCustomEvent {
    AlexGromoreNativeCustomEvent *customEvent = ((ATNativeADCache*)(((id<ATNativeADView>)self.ADView).nativeAd)).assets[kATAdAssetsCustomEventKey];
    customEvent.adView = self.ADView;
    self.ADView.customEvent = customEvent;
}

- (UIView *)getNetWorkMediaView {
    ATNativeADCache *cache = ((ATNativeADCache*)(((id<ATNativeADView>)self.ADView).nativeAd));
    BUNativeAd *nativeAdView = cache.assets[kATAdAssetsCustomObjectKey];
    if (!nativeAdView.mediation.isExpressAd && (nativeAdView.data.imageMode == BUMFeedVideoAdModeImage || nativeAdView.data.imageMode == BUMFeedVideoAdModePortrait)) {
        return nativeAdView.mediation.canvasView.mediaView;
    }
    return nil;
}

- (void)renderOffer:(ATNativeADCache *)offer {
    [super renderOffer:offer];
    
    UIViewController *rootVC = self.configuration.rootViewController;
    if (rootVC == nil) {
        rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    }
    
    BUNativeAd *nativeView = offer.assets[kATAdAssetsCustomObjectKey];
    nativeView.mediation.canvasView.backgroundColor = self.ADView.backgroundColor;
    nativeView.rootViewController = rootVC;
    nativeView.delegate = (AlexGromoreNativeCustomEvent*)self.ADView.customEvent;
    
    if (nativeView.mediation.isExpressAd) {
        // express
        CGFloat height = self.ADView.frame.size.height;
        if (self.configuration.sizeToFit) {
            if (self.expressAdHeight == 0) {
                height = 0;
            } else {
                // 重复渲染
                height = self.expressAdHeight;
                CGRect adFrame = self.ADView.frame;
                adFrame.size.height = height;
                self.ADView.frame = adFrame;
            }
        }
        
        nativeView.mediation.canvasView.frame = CGRectMake(0, 0, self.ADView.frame.size.width, height);
        if (self.configuration.sizeToFit && self.expressAdHeight == 0) {
            [nativeView.mediation.canvasView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
            self.canvasView = nativeView.mediation.canvasView;
            self.isAddKVOframe = YES;
        }
        
        [nativeView.mediation render];
    } else {
        // self-Render
        [self.ADView setNeedsLayout];
        [self.ADView layoutIfNeeded];
        nativeView.mediation.canvasView.frame = self.ADView.bounds;
        if (nativeView.data.imageMode == BUMFeedVideoAdModeImage || nativeView.data.imageMode == BUMFeedVideoAdModePortrait) {
            [nativeView.mediation reSizeMediaView];
        }
        [nativeView registerContainer:self.ADView withClickableViews:[self.ADView clickableViews]];
    }
    // 把gromore父视图放到ADView最底层
    [self.ADView insertSubview:(UIView *)nativeView.mediation.canvasView atIndex:0];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"frame"]) {
        UIView *nativeView = object;
        CGRect adFrame = self.ADView.frame;
        adFrame.size.height = nativeView.frame.size.height;
        self.expressAdHeight = nativeView.frame.size.height;
        self.ADView.frame = adFrame;
        nativeView.center = CGPointMake(CGRectGetMidX(self.ADView.bounds), CGRectGetMidY(self.ADView.bounds));
        [nativeView removeObserver:self forKeyPath:@"frame"];
        self.isAddKVOframe = NO;
    }
}

- (void)dealloc {
    [self clearAdCache];
}

- (void)clearAdCache {
    if (self.isAddKVOframe == YES) {
        [self.canvasView removeObserver:self forKeyPath:@"frame"];
        self.isAddKVOframe = NO;
    }
}

- (BOOL)isVideoContents {
    ATNativeADCache *cache = ((ATNativeADCache*)(((id<ATNativeADView>)self.ADView).nativeAd));
    BUNativeAd *nativeAdView = cache.assets[kATAdAssetsCustomObjectKey];
    return nativeAdView.data.imageMode == BUMFeedVideoAdModeImage || nativeAdView.data.imageMode == BUMFeedVideoAdModePortrait;
}

- (ATNativeAdRenderType)getCurrentNativeAdRenderType {
    ATNativeADCache *cache = ((ATNativeADCache*)(((id<ATNativeADView>)self.ADView).nativeAd));
    BUNativeAd *nativeAdView = cache.assets[kATAdAssetsCustomObjectKey];
    if (nativeAdView.mediation.isExpressAd) {
        return ATNativeAdRenderExpress;
    } else {
        return ATNativeAdRenderSelfRender;
    }
}
@end
