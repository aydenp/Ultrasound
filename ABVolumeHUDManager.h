//
//  ABVolumeHUDManager.h
//  Ultrasound
//
//  Created by Ayden Panhuyzen on 8/27/18.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ABVolumeHUDVisibilityManager.h"
#import "ABVolumeHUDVolumeModeInfo.h"
#import "ABVolumeHUDVolumeInfoProviding.h"
#import "ABVolumeHUDTapticFeedbackProviding.h"
#import "ABVolumeHUDTheme.h"

#define kVolumeChangeNotification @"kABVolumeHUDVolumeChangedNotificationName"
#define kVolumeModeChangeNotification @"kABVolumeHUDVolumeModeChangedNotificationName"
#define kControlVisibilityChangedNotification @"kABVolumeHUDControlVisibilityChangedNotificationName"
#define kThemeSettingsChangedNotification @"kABVolumeHUDThemeChangedNotificationName"

@interface ABVolumeHUDManager : NSObject
+ (instancetype)sharedManager;
@property (nonatomic, retain) UIView *targetView;
@property (nonatomic, setter=setOLEDMode:) BOOL oledMode;
@property (nonatomic, readonly) ABVolumeHUDVisibilityManager *visibilityManager;
@property (nonatomic, retain) NSObject <ABVolumeHUDVolumeInfoProviding>*volumeInfoProvider;
@property (nonatomic, retain) NSObject <ABVolumeHUDTapticFeedbackProviding>*tapticFeedbackProvider;
@property (nonatomic, retain) NSObject <ABVolumeHUDTheme>*lightModeTheme;
@property (nonatomic, retain) NSObject <ABVolumeHUDTheme>*darkModeTheme;
@property (nonatomic, assign) UIInterfaceOrientation orientation;
- (void)createViewIfDoesntExist;
- (NSObject <ABVolumeHUDTheme>*)theme;
- (void)volumeChangedTo:(CGFloat)volume withMode:(ABVolumeHUDVolumeMode)mode;
- (void)volumeChangedTo:(CGFloat)volume;
- (BOOL)oledMode;
- (void)setOLEDMode:(BOOL)oledMode;
@end
