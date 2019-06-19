//
//  ABVolumeHUDTheme.h
//  Ultrasound
//
//  Created by Ayden Panhuyzen on 10/8/18.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ABVolumeHUDTheme <NSObject>
- (UIBlurEffect *)backgroundEffect;
- (UIColor *)iconMaskColour;
- (UIColor *)sliderKnobColour;
- (UIColor *)sliderTrackColour;
- (UIColor *)sliderFilledTrackColour;
- (UIColor *)textColour;
@optional
- (UIColor *)backgroundColourTint;
- (BOOL)enableTextVibrancy;
- (BOOL)enableSliderKnobShadow;
@end
