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
#import "NSObject+SafeKVC.h"

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

- (BOOL)isRingerMuted {
    if ([self mediaController] && [[self mediaController] respondsToSelector:@selector(isRingerMuted)]) return [self mediaController].isRingerMuted;
    if ([self ringerControl] && [[self ringerControl] respondsToSelector:@selector(isRingerMuted)]) return [self ringerControl].isRingerMuted;
    return NO;
}

- (NSString *)overrideTextForVolume:(CGFloat)volume {
    if (_mode == ABVolumeHUDVolumeModeRinger && [self isRingerMuted]) return @"Silent";
    return nil;
}

- (CGFloat)iconVolumeForRealVolume:(CGFloat)volume {
    if (_mode == ABVolumeHUDVolumeModeRinger && [self isRingerMuted]) return 0;
    return volume;
}

- (BOOL)shouldDeemphasizeSliderForVolume:(CGFloat)volume {
    return _mode == ABVolumeHUDVolumeModeRinger && [self isRingerMuted];
}

- (UIView<ABVolumeHUDIconGlyphProviding> *)iconGlyphProvider {
    if (_mode == ABVolumeHUDVolumeModeRinger) return [[ABVolumeHUDIconRingerGlyph alloc] init];
    return [[ABVolumeHUDIconVolumeGlyph alloc] init];
}

- (SBMediaController *)mediaController {
    Class mediaControllerClass = NSClassFromString(@"SBMediaController");
    if (!mediaControllerClass) return nil;
    return [mediaControllerClass sharedInstance];
}

- (SBRingerControl *)ringerControl {
    SBMainWorkspace *workspace = [NSClassFromString(@"SBMainWorkspace") sharedInstance];
    if (![workspace respondsToSelector:@selector(ringerControl)]) return nil;
    return [workspace ringerControl];
}

@end
