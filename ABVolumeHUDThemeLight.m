//
//  ABVolumeHUDThemeLight.m
//  Ultrasound
//
//  Created by Ayden Panhuyzen on 10/8/18.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

#import "ABVolumeHUDThemeLight.h"

@implementation ABVolumeHUDThemeLight

- (UIColor *)foregroundColour {
    return [UIColor whiteColor];
}

- (UIBlurEffect *)backgroundEffect {
    UIBlurEffect *blur = [[NSClassFromString(@"_UICustomBlurEffect") alloc] init];
    [blur setValue:@40 forKey:@"blurRadius"];
    [blur setValue:[UIColor whiteColor] forKey:@"colorTint"];
    [blur setValue:@0.3 forKey:@"colorTintAlpha"];
    [blur setValue:@1.9 forKey:@"saturationDeltaFactor"];
    [blur setValue:@0.02 forKey:@"darkeningTintAlpha"];
    [blur setValue:@([UIScreen mainScreen].scale) forKey:@"scale"];
    return blur;
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

- (BOOL)enableTextVibrancy {
    return NO;
}

- (UIColor *)backgroundColourTint {
    return [UIColor colorWithWhite:0 alpha:0.25];
}

@end
