//
//  ABVolumeHUDThemeDark.m
//  Ultrasound
//
//  Created by Ayden Panhuyzen on 10/8/18.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

#import "ABVolumeHUDThemeDark.h"

@implementation ABVolumeHUDThemeDark

- (UIColor *)foregroundColour {
    return [UIColor whiteColor];
}

- (UIBlurEffect *)backgroundEffect {
    return [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
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
    return [self foregroundColour];
}

- (UIColor *)textColour {
    return [self foregroundColour];
}

@end
