//
//  ABVolumeHUDOLEDInfoView.m
//  Ultrasound
//
//  Created by Ayden Panhuyzen on 2018-09-02.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

#import "ABVolumeHUDOLEDInfoView.h"
#import "ABVolumeHUDViewSettings.h"
#import "ABVolumeHUDIconView.h"

@implementation ABVolumeHUDOLEDInfoView {
    UIStackView *stackView;
    ABVolumeHUDIconView *iconView;
    UILabel *volumeLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) [self setupForDisplay];
    return self;
}

- (void)setupForDisplay {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applySettings) name:kHUDSettingsChanged object:nil];
    
    iconView = [[ABVolumeHUDIconView alloc] init];
    
    volumeLabel = [[UILabel alloc] init];
    volumeLabel.textColor = [UIColor whiteColor];
    volumeLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
    
    stackView = [[UIStackView alloc] initWithArrangedSubviews:@[iconView, volumeLabel]];
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.spacing = 6;
    stackView.alignment = UIStackViewAlignmentCenter;
    [self addSubview:stackView];
    [stackView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [stackView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [stackView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
    [stackView.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
    
    [self applySettings];
}

- (void)applySettings {
    iconView.hidden = ![ABVolumeHUDViewSettings sharedSettings].showOLEDVolumeIcon;
    volumeLabel.hidden = ![ABVolumeHUDViewSettings sharedSettings].showOLEDVolumePercentage;
}

- (void)volumeChangedTo:(CGFloat)volume withModeInfo:(ABVolumeHUDVolumeModeInfo *)modeInfo {
    CATransition *animation = [[CATransition alloc] init];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionFade;
    animation.duration = 0.1;
    animation.removedOnCompletion = YES;
    [volumeLabel.layer addAnimation:animation forKey:@"textTransition"];
    
    NSString *overrideText = [modeInfo overrideTextForVolume:volume];
    volumeLabel.text = overrideText ? overrideText : [NSString stringWithFormat:@"%.f%%", volume * 100];
    
    iconView.volume = volume;
    iconView.modeInfo = modeInfo;
}

@end
