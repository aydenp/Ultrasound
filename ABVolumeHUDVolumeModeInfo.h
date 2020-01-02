//
//  ABVolumeHUDVolumeModeInfo.h
//  Ultrasound
//
//  Created by Ayden Panhuyzen on 9/8/18.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ABVolumeHUDIconGlyphProviding.h"

typedef NS_ENUM(NSInteger, ABVolumeHUDVolumeMode) {
    ABVolumeHUDVolumeModeAudio,
    ABVolumeHUDVolumeModeRinger
};

@interface ABVolumeHUDVolumeModeInfo : NSObject
@property (nonatomic, assign) ABVolumeHUDVolumeMode mode;
+ (instancetype)infoForVolumeMode:(ABVolumeHUDVolumeMode)mode;
- (BOOL)allowsUserModificationForVolume:(CGFloat)volume;
- (NSString *)overrideTextForVolume:(CGFloat)volume;
- (CGFloat)iconVolumeForRealVolume:(CGFloat)volume;
- (BOOL)shouldDeemphasizeSliderForVolume:(CGFloat)volume;
- (UIView<ABVolumeHUDIconGlyphProviding> *)iconGlyphProvider;
@end
