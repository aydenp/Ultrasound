//
//  ABVolumeHUDSystemTapticFeedbackProvider.h
//  Ultrasound
//
//  Created by Ayden Panhuyzen on 10/8/18.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ABVolumeHUDTapticFeedbackProviding.h"

@interface ABVolumeHUDSystemTapticFeedbackProvider : NSObject <ABVolumeHUDTapticFeedbackProviding>
- (void)actuate;
- (void)warmUp;
@end