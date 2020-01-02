//
//  ABVolumeHUDIconVolumeGlyph.m
//  Ultrasound
//
//  Created by Ayden Panhuyzen on 9/3/18.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

#import "ABVolumeHUDIconVolumeGlyph.h"
#import "CCUICAPackageView.h"

#define kGlyphPackageName @"Volume"
#define kGlyphPackageBundle [NSBundle bundleWithURL:[ControlCenterModulesRoot URLByAppendingPathComponent:@"AudioModule.bundle"]]

@implementation ABVolumeHUDIconVolumeGlyph {
    CCUICAPackageView *glyphView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) [self setupForDisplay];
    return self;
}

- (void)setupForDisplay {
    glyphView = [[NSClassFromString(@"CCUICAPackageView") alloc] init];

    NSBundle *packageBundle = kGlyphPackageBundle;
    if (@available(iOS 13.0, *)) packageBundle = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/MediaControls.framework"];

    glyphView.packageDescription = [NSClassFromString(@"CCUICAPackageDescription") descriptionForPackageNamed:kGlyphPackageName inBundle:packageBundle];
    glyphView.translatesAutoresizingMaskIntoConstraints = NO;
    glyphView.transform = CGAffineTransformMakeScale(0.7, 0.7);
    [self addSubview:glyphView];
    [glyphView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [glyphView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
    [glyphView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [glyphView.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
}

- (void)setVolume:(CGFloat)volume {
    NSString *stateName = @"mute";
    if (volume > 0) {
        if (volume <= 0.33) stateName = @"min";
        else if (volume <= 0.66) stateName = @"half";
        else if (volume <= 0.9) stateName = @"full";
        else stateName = @"max";
    }
    [glyphView setStateName:stateName];
}

@end
