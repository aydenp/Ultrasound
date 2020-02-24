//
//  ABVolumeHUDView.h
//  Ultrasound
//
//  Created by Ayden Panhuyzen on 8/27/18.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ABVolumeSliderView.h"
#import "ABVolumeHUDVisibilityManager.h"
#import "ABVolumeHUDVolumeModeInfo.h"
#import "ABVolumeHUDIconView.h"

@protocol ABVolumeHUDViewDelegate <NSObject>
- (ABVolumeHUDVisibilityManager *)visibilityManager;
- (void)sliderValueChangedTo:(CGFloat)value;
- (void)shouldSwitchModes;
@end

@interface ABVolumeHUDView : UIView <ABVolumeSliderViewDelegate, ABVolumeHUDIconViewDelegate>
@property (nonatomic, retain, readonly) UIView *containerView;
@property (nonatomic, retain, readonly) UIView *topContainerView;
@property (nonatomic, weak) NSObject <ABVolumeHUDViewDelegate>*delegate;
@property (nonatomic, retain, readonly) ABVolumeSliderView *sliderView;
@property (nonatomic, retain, readonly) UIView *iconContainerView;
@property (nonatomic, assign) BOOL oledMode;
@property (nonatomic, assign, setter=setInLandscapeMode:) BOOL isInLandscapeMode;
@property (nonatomic, retain, readonly) NSLayoutConstraint *maxVolumeSliderHeightConstraint;
- (NSArray <UIView *>*)accessoryViews;
- (void)volumeChangedTo:(CGFloat)volume withModeInfo:(ABVolumeHUDVolumeModeInfo *)modeInfo;
- (void)setOLEDMode:(BOOL)oledMode animated:(BOOL)animated;
- (void)applyThemeAnimated:(BOOL)animated;
@end
