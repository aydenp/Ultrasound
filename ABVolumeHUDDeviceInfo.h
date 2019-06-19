//
//  ABVolumeHUDDeviceInfo.h
//  Ultrasound
//
//  Created by Ayden Panhuyzen on 8/27/18.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ABVolumeHUDDeviceInfo : NSObject
@property (nonatomic, assign, readonly) CGFloat volumeButtonTopOffset;
@property (nonatomic, assign, readonly) CGFloat volumeButtonHeight;
@property (nonatomic, assign, readonly) BOOL rightAlignControls;
@property (nonatomic, assign, readonly) BOOL hasOLEDScreen;
+ (instancetype)infoForCurrentDevice;
+ (instancetype)infoForDeviceModel:(NSString *)model;
@end
