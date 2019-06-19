//
//  ABVolumeHUDVolumeModeInfo.m
//  Ultrasound
//
//  Created by Ayden Panhuyzen on 8/27/18.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

#import "ABVolumeHUDVolumeModeInfo.h"
#import "ABVolumeHUDIconVolumeGlyph.h"
#import "ABVolumeHUDIconRingerGlyph.h"
#import "Headers.h"

@implementation ABVolumeHUDVolumeModeInfo

- (instancetype)initWithVolumeMode:(ABVolumeHUDVolumeMode)mode {
    self = [super init];
    if (self) _mode = mode;
    return self;
}

+ (instancetype)infoForVolumeMode:(ABVolumeHUDVolumeMode)mode {
    return [[self alloc] initWithVolumeMode:mode];
}

- (BOOL)allowsUserModificationForVolume:(CGFloat)volume {
    return YES;
}

- (NSString *)overrideTextForVolume:(CGFloat)volume {
    if (_mode == ABVolumeHUDVolumeModeRinger) {
        if ([self mediaController] && [self mediaController].isRingerMuted) return @"Silent";
    }
    return nil;
}

- (CGFloat)iconVolumeForRealVolume:(CGFloat)volume {
    if (_mode == ABVolumeHUDVolumeModeRinger) {
        if ([self mediaController] && [self mediaController].isRingerMuted) return 0;
    }
    return volume;
}

- (BOOL)shouldDeemphasizeSliderForVolume:(CGFloat)volume {
    if (_mode == ABVolumeHUDVolumeModeRinger) {
        if ([self mediaController] && [self mediaController].isRingerMuted) return YES;
    }
    return nil;
}

- (UIView<ABVolumeHUDIconGlyphProviding> *)iconGlyphProvider {
    if (_mode == ABVolumeHUDVolumeModeRinger) return [[ABVolumeHUDIconRingerGlyph alloc] init];
    return [[ABVolumeHUDIconVolumeGlyph alloc] init];
}

- (SBMediaController *)mediaController {
    Class mediaControllerClass = NSClassFromString(@"SBMediaController");
    if (mediaControllerClass) return [mediaControllerClass sharedInstance];
    return nil;
}

@end
