//
//  ABVolumeHUDOLEDInfoView.h
//  Ultrasound
//
//  Created by Ayden Panhuyzen on 2018-09-02.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ABVolumeHUDVolumeModeInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface ABVolumeHUDOLEDInfoView : UIView
- (void)volumeChangedTo:(CGFloat)volume withModeInfo:(ABVolumeHUDVolumeModeInfo *)modeInfo;
@end

NS_ASSUME_NONNULL_END
