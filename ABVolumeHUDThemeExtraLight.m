//
//  ABVolumeHUDThemeExtraLight.m
//  Ultrasound
//
//  Created by Ayden Panhuyzen on 10/8/18.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

#import "ABVolumeHUDThemeExtraLight.h"

@implementation ABVolumeHUDThemeExtraLight

- (UIColor *)foregroundColour {
    return [UIColor darkGrayColor];
}

- (UIBlurEffect *)backgroundEffect {
    return [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
}

- (UIColor *)iconMaskColour {
    return [self foregroundColour];
}

- (UIColor *)sliderKnobColour {
    return [self foregroundColour];
}

- (UIColor *)sliderTrackColour {
    return [[self foregroundColour] colorWithAlphaComponent:0.2];
}

- (UIColor *)sliderFilledTrackColour {
    return [[self foregroundColour] colorWithAlphaComponent:0.7];
}

- (UIColor *)textColour {
    return [self foregroundColour];
}

- (BOOL)enableSliderKnobShadow {
    return NO;
}

- (UIColor *)backgroundColourTint {
    return [UIColor colorWithWhite:0 alpha:0.2];
}

@end
