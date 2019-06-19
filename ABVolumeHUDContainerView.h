//
//  ABVolumeHUDContainerView.h
//  Ultrasound
//
//  Created by Ayden Panhuyzen on 8/27/18.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ABVolumeHUDVolumeModeInfo.h"
#import "ABVolumeHUDView.h"

@interface ABVolumeHUDContainerView : UIView <ABVolumeHUDViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, assign, setter=setOLEDMode:) BOOL oledMode;
@property (nonatomic, retain, readonly) UIViewPropertyAnimator *animator;
@property (nonatomic, assign) UIInterfaceOrientation effectiveOrientation;
- (void)setOLEDMode:(BOOL)oledMode animated:(BOOL)animated;
- (void)volumeChangedTo:(CGFloat)volume withMode:(ABVolumeHUDVolumeMode)mode;
- (void)shouldSwitchModes;
@end
