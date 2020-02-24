//
//  ABVolumeHUDSystemVolumeInfoProvider.h
//  Ultrasound
//
//  Created by Ayden Panhuyzen on 10/8/18.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Headers.h"
#import "ABVolumeHUDVolumeInfoProviding.h"

@interface ABVolumeHUDSystemVolumeInfoProvider : NSObject <ABVolumeHUDVolumeInfoProviding>
- (CGFloat)volumeForVolumeMode:(ABVolumeHUDVolumeMode)mode;
+ (VolumeControl *)activeVolumeControl;
@end