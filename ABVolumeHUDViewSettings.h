//
//  ABVolumeHUDViewSettings.h
//  Ultrasound
//
//  Created by Ayden Panhuyzen on 8/28/18.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ABVolumeHUDStyle.h"

#define kHUDSettingsChanged @"kABVolumeHUDSettingsChangedNotificationName"

@interface ABVolumeHUDViewSettings : NSObject
+ (instancetype)sharedSettings;
@property (nonatomic, assign) BOOL showVolumeIcon;
@property (nonatomic, assign) BOOL showVolumePercentage;
@property (nonatomic, assign) CGFloat timeout;
@property (nonatomic, assign) BOOL showOLEDVolumeIcon;
@property (nonatomic, assign) BOOL showOLEDVolumePercentage;
@property (nonatomic, assign) BOOL enableHapticFeedback;
@property (nonatomic, assign) ABVolumeHUDStyle style;
@end
