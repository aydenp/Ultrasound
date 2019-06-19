//
//  ABVolumeHUDViewSettings.m
//  Ultrasound
//
//  Created by Ayden Panhuyzen on 8/28/18.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

#import "ABVolumeHUDViewSettings.h"

@implementation ABVolumeHUDViewSettings

+ (instancetype)sharedSettings {
    static ABVolumeHUDViewSettings *sharedSettings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSettings = [[self alloc] init];
    });
    return sharedSettings;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _showVolumeIcon = YES;
        _showVolumePercentage = YES;
        _timeout = 3;
        _showOLEDVolumeIcon = YES;
        _showOLEDVolumePercentage = YES;
        _enableHapticFeedback = YES;
    }
    return self;
}

- (void)settingsChanged {
    [[NSNotificationCenter defaultCenter] postNotificationName:kHUDSettingsChanged object:nil];
}

// MARK: - Observers

- (void)setShowVolumeIcon:(BOOL)showVolumeIcon {
    _showVolumeIcon = showVolumeIcon;
    [self settingsChanged];
}

- (void)setShowVolumePercentage:(BOOL)showVolumePercentage {
    _showVolumePercentage = showVolumePercentage;
    [self settingsChanged];
}

- (void)setTimeout:(CGFloat)timeout {
    _timeout = timeout;
    [self settingsChanged];
}

- (void)setShowOLEDVolumeIcon:(BOOL)showOLEDVolumeIcon {
    _showOLEDVolumeIcon = showOLEDVolumeIcon;
    [self settingsChanged];
}

- (void)setShowOLEDVolumePercentage:(BOOL)showOLEDVolumePercentage {
    _showOLEDVolumePercentage = showOLEDVolumePercentage;
    [self settingsChanged];
}

- (void)setEnableHapticFeedback:(BOOL)enableHapticFeedback {
    _enableHapticFeedback = enableHapticFeedback;
    [self settingsChanged];
}

- (void)setStyle:(ABVolumeHUDStyle)style {
    _style = style;
    [self settingsChanged];
}

@end
