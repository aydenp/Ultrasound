//
//  ABVolumeHUDIconRingerGlyph.m
//  Ultrasound
//
//  Created by Ayden Panhuyzen on 9/3/18.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

#import "ABVolumeHUDIconRingerGlyph.h"
#import "CCUICAPackageView.h"

#define kGlyphPackageName @"Mute"
#define kGlyphPackageBundle [NSBundle bundleWithURL:[ControlCenterModulesRoot URLByAppendingPathComponent:@"MuteModule.bundle"]]

@implementation ABVolumeHUDIconRingerGlyph {
    CCUICAPackageView *glyphView;
    BOOL hasSetVolume;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) [self setupForDisplay];
    return self;
}

- (void)setupForDisplay {
    glyphView = [[NSClassFromString(@"CCUICAPackageView") alloc] init];
    glyphView.packageDescription = [NSClassFromString(@"CCUICAPackageDescription") descriptionForPackageNamed:kGlyphPackageName inBundle:kGlyphPackageBundle];
    glyphView.translatesAutoresizingMaskIntoConstraints = NO;
    glyphView.transform = CGAffineTransformMakeScale(0.7, 0.7);
    [self addSubview:glyphView];
    [glyphView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [glyphView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
}

- (void)setVolume:(CGFloat)volume {
    [self adjustScaleForVolume:volume animated:hasSetVolume];
    [glyphView setStateName:volume > 0 ? @"ringer" : @"silent"];
    hasSetVolume = YES;
}

- (void)adjustScaleForVolume:(CGFloat)volume animated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:1 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [self adjustScaleForVolume:volume animated:NO];
        } completion:nil];
        return;
    }
    CGFloat scale = 0.65;
    if (volume <= 0.33) scale = 0.5;
    else if (volume <= 0.66) scale = 0.55;
    else if (volume <= 0.9) scale = 0.6;
    self->glyphView.transform = CGAffineTransformMakeScale(scale, scale);
}

@end
