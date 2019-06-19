//
//  ABVolumeHUDIconView.h
//  Ultrasound
//
//  Created by Ayden Panhuyzen on 8/28/18.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ABVolumeHUDVolumeModeInfo.h"

@class ABVolumeHUDIconView;
@protocol ABVolumeHUDIconViewDelegate <NSObject>
@optional
- (void)tappedIconView:(ABVolumeHUDIconView *)iconView;
@end

@interface ABVolumeHUDIconView : UIView
@property (nonatomic, assign) CGFloat volume;
@property (nonatomic, retain) ABVolumeHUDVolumeModeInfo *modeInfo;
@property (nonatomic, assign) BOOL mustBeSquare;
@property (readonly, assign) BOOL isTouchedDown;
@property (nonatomic, weak) NSObject <ABVolumeHUDIconViewDelegate>*delegate;
@end
