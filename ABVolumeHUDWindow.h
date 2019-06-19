//
//  ABVolumeHUDWindow.h
//  Ultrasound
//
//  Created by Ayden Panhuyzen on 8/27/18.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kOLEDWindowTappedNotification @"kABVolumeHUDOLEDWindowTappedNotification"

@interface ABVolumeHUDWindow : UIWindow
@property (nonatomic, assign) CGFloat darkScreenImitationAlpha;
@end
