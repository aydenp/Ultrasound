//
//  ABVolumeHUDView.m
//  Ultrasound
//
//  Created by Ayden Panhuyzen on 8/27/18.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

#import "ABVolumeHUDView.h"
#import "ABVolumeHUDViewSettings.h"
#import "ABVolumeHUDManager.h"
#import "ABVolumeHUDPassthroughView.h"
#import "NSObject+SafeKVC.h"

#define kVolumeLabelDefaultFont [UIFont systemFontOfSize:13 weight:UIFontWeightBold]
#define kVolumeLabelOverrideFont [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold]

@implementation ABVolumeHUDView {
    UIVisualEffectView *backdropView;
    UIStackView *topStackView;
    UIStackView *bottomStackView;
    UILabel *volumeLabel;
    UIVisualEffectView *volumeLabelVibranceView;
    ABVolumeHUDVolumeModeInfo *modeInfo;
    BOOL hasDeemphasized;
    NSLayoutConstraint *topContentConstraint;
    NSLayoutConstraint *bottomContentConstraint;
    NSLayoutConstraint *sliderLeftConstraint;
    NSLayoutConstraint *sliderRightConstraint;
    NSLayoutConstraint *sliderTopConstraint;
    NSLayoutConstraint *sliderBottomConstraint;
    ABVolumeHUDIconView *iconView;
    ABVolumeHUDStyle currentStyle;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) [self setupForDisplay];
    return self;
}

- (void)setupForDisplay {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applySettings) name:kHUDSettingsChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applyThemeWithNotification:) name:kThemeChangedNotification object:nil];
    
    backdropView = [[UIVisualEffectView alloc] init];
    backdropView.translatesAutoresizingMaskIntoConstraints = NO;
    backdropView.clipsToBounds = YES;
    if (@available(iOS 13.0, *)) {
        backdropView.layer.cornerCurve = kCACornerCurveContinuous;
    } else {
        [backdropView.layer safelySetValue:@(YES) forKey:@"continuousCorners"];
    }
    [self addSubview:backdropView];
    [backdropView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [backdropView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [backdropView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
    [backdropView.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
    
    volumeLabelVibranceView = [[UIVisualEffectView alloc] init];
    
    iconView = [[ABVolumeHUDIconView alloc] init];
    iconView.delegate = self;
    iconView.mustBeSquare = YES;
    
    _containerView = [[ABVolumeHUDPassthroughView alloc] init];
    _containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [backdropView.contentView addSubview:_containerView];
    [_containerView.leftAnchor constraintEqualToAnchor:backdropView.contentView.leftAnchor].active = YES;
    [_containerView.topAnchor constraintEqualToAnchor:backdropView.contentView.topAnchor].active = YES;
    [_containerView.rightAnchor constraintEqualToAnchor:backdropView.contentView.rightAnchor].active = YES;
    [_containerView.bottomAnchor constraintEqualToAnchor:backdropView.contentView.bottomAnchor].active = YES;
    
    _topContainerView = [[ABVolumeHUDPassthroughView alloc] init];
    _topContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_topContainerView];
    [_topContainerView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
    [_topContainerView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [_topContainerView.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
    [_topContainerView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    
    topStackView = [[UIStackView alloc] initWithArrangedSubviews:@[iconView]];
    topStackView.spacing = 8;
    topStackView.alignment = UIStackViewAlignmentCenter;
    topStackView.axis = UILayoutConstraintAxisVertical;
    topStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [_containerView addSubview:topStackView];
    [topStackView.leftAnchor constraintEqualToAnchor:_containerView.leftAnchor constant:8].active = YES;
    [topStackView.rightAnchor constraintEqualToAnchor:_containerView.rightAnchor constant:-8].active = YES;
    topContentConstraint = [topStackView.topAnchor constraintEqualToAnchor:_containerView.topAnchor constant:12];
    topContentConstraint.active = YES;
    
    volumeLabel = [[UILabel alloc] init];
    volumeLabel.font = kVolumeLabelDefaultFont;
    volumeLabel.adjustsFontSizeToFitWidth = YES;
    volumeLabel.minimumScaleFactor = 0.5;
    volumeLabel.textAlignment = NSTextAlignmentCenter;
    volumeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [volumeLabelVibranceView.contentView addSubview:volumeLabel];
    [volumeLabel.topAnchor constraintEqualToAnchor:volumeLabelVibranceView.contentView.topAnchor constant:4].active = YES;
    [volumeLabel.bottomAnchor constraintEqualToAnchor:volumeLabelVibranceView.contentView.bottomAnchor].active = YES;
    [volumeLabel.leftAnchor constraintEqualToAnchor:volumeLabelVibranceView.contentView.leftAnchor].active = YES;
    [volumeLabel.rightAnchor constraintEqualToAnchor:volumeLabelVibranceView.contentView.rightAnchor].active = YES;
    
    bottomStackView = [[UIStackView alloc] initWithArrangedSubviews:@[volumeLabelVibranceView]];
    bottomStackView.spacing = 8;
    bottomStackView.alignment = UIStackViewAlignmentCenter;
    bottomStackView.axis = UILayoutConstraintAxisVertical;
    bottomStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [_containerView addSubview:bottomStackView];
    [bottomStackView.leftAnchor constraintEqualToAnchor:_containerView.leftAnchor constant:8].active = YES;
    [bottomStackView.rightAnchor constraintEqualToAnchor:_containerView.rightAnchor constant:-8].active = YES;
    bottomContentConstraint = [bottomStackView.bottomAnchor constraintEqualToAnchor:_containerView.bottomAnchor constant:-12];
    bottomContentConstraint.active = YES;
    
    _sliderView = [[ABVolumeSliderView alloc] init];
    _sliderView.translatesAutoresizingMaskIntoConstraints = NO;
    _sliderView.delegate = self;
    [_topContainerView addSubview:_sliderView];
    sliderTopConstraint = [_sliderView.topAnchor constraintEqualToAnchor:topStackView.bottomAnchor];
    sliderTopConstraint.active = YES;
    sliderBottomConstraint = [_sliderView.bottomAnchor constraintEqualToAnchor:bottomStackView.topAnchor constant:-6];
    sliderBottomConstraint.active = YES;
    sliderLeftConstraint = [_sliderView.leftAnchor constraintEqualToAnchor:_topContainerView.leftAnchor];
    sliderLeftConstraint.active = YES;
    sliderRightConstraint = [_sliderView.rightAnchor constraintEqualToAnchor:_topContainerView.rightAnchor];
    sliderRightConstraint.active = YES;
    
    // Make sure slider still doesn't exceed a certain height (in non-OLED mode)
    _maxVolumeSliderHeightConstraint = [self.sliderView.heightAnchor constraintLessThanOrEqualToConstant:0];
    _maxVolumeSliderHeightConstraint.active = YES;
    
    [self applySettings];
    [self applyThemeAnimated:NO];
}

- (NSArray <UIView *>*)accessoryViews {
    return @[topStackView, bottomStackView];
}

- (void)applyThemeWithNotification:(NSNotification *)notif {
    BOOL animated = [notif.userInfo[@"animated"] boolValue];
    [self applyThemeAnimated:animated];
}

- (void)applyThemeAnimated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.75 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [self applyThemeAnimated:NO];
        } completion:nil];
        return;
    }
    [self updateBlurEffect];
    [self updateSliderStyling];
    NSObject <ABVolumeHUDTheme>*theme = [ABVolumeHUDManager sharedManager].theme;
    iconView.backgroundColor = theme.iconMaskColour;
    volumeLabel.textColor = theme.textColour;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    backdropView.layer.cornerRadius = [ABVolumeHUDViewSettings sharedSettings].style == ABVolumeHUDStyleRefined ? self.bounds.size.width / 2 : 12;
}

- (void)updateSliderStyling {
    NSObject <ABVolumeHUDTheme>*theme = [ABVolumeHUDManager sharedManager].theme;
    _sliderView.knobColour = _oledMode ? nil : theme.sliderKnobColour;
    _sliderView.knobHasShadow = ![theme respondsToSelector:@selector(enableSliderKnobShadow)] || theme.enableSliderKnobShadow;
    _sliderView.trackColour = _oledMode ? nil : theme.sliderTrackColour;
    _sliderView.filledTrackColour = _oledMode ? nil : theme.sliderFilledTrackColour;
}

- (void)updateBlurEffect {
    NSObject <ABVolumeHUDTheme>*theme = [ABVolumeHUDManager sharedManager].theme;
    UIBlurEffect *effect = theme.backgroundEffect;
    backdropView.effect = _oledMode ? nil : effect;
    backdropView.backgroundColor = !_oledMode && [theme respondsToSelector:@selector(backgroundColourTint)] ? theme.backgroundColourTint : nil;
    volumeLabelVibranceView.effect = ![theme respondsToSelector:@selector(enableTextVibrancy)] || theme.enableTextVibrancy ? [UIVibrancyEffect effectForBlurEffect:effect] : nil;
}

- (void)applySettings {
    ABVolumeHUDViewSettings *settings = [ABVolumeHUDViewSettings sharedSettings];
    iconView.hidden = !settings.showVolumeIcon;
    volumeLabelVibranceView.hidden = _isInLandscapeMode || !settings.showVolumePercentage;
    
    switch (settings.style) {
        case ABVolumeHUDStyleIconic:
            topContentConstraint.constant = 12;
            bottomContentConstraint.constant = -topContentConstraint.constant;
            _maxVolumeSliderHeightConstraint.constant = 105;
            sliderLeftConstraint.constant = 24;
            sliderTopConstraint.constant = 12;
            break;
        case ABVolumeHUDStyleRefined:
            topContentConstraint.constant = 16;
            bottomContentConstraint.constant = volumeLabelVibranceView.hidden ? -14 : -16;
            _maxVolumeSliderHeightConstraint.constant = 115;
            sliderLeftConstraint.constant = 23;
            sliderTopConstraint.constant = 10;
            break;
    }
    sliderRightConstraint.constant = -sliderLeftConstraint.constant;
    [UIView animateWithDuration:self.window == nil && currentStyle != settings.style ? 0 : 0.3 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.75 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self layoutIfNeeded];
    } completion:nil];
    currentStyle = settings.style;
}

- (void)volumeChangedTo:(CGFloat)volume withModeInfo:(ABVolumeHUDVolumeModeInfo *)modeInfo {
    self->modeInfo = modeInfo;
    _sliderView.value = volume;
    iconView.modeInfo = modeInfo;
    [self updateSliderEditableAnimated:YES];
}

- (void)setOLEDMode:(BOOL)oledMode animated:(BOOL)animated {
    _oledMode = oledMode;
    [self updateSliderEditableAnimated:animated];
    if (animated) {
        [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:oledMode ? 1 : 0.8 initialSpringVelocity:1 options:0 animations:^{
            [self adjustTransformForOLEDMode:oledMode];
        } completion:nil];
    } else [self adjustTransformForOLEDMode:oledMode];
}

- (void)updateSliderEditableAnimated:(BOOL)animated {
    [_sliderView setEditable:!_oledMode && [modeInfo allowsUserModificationForVolume:_sliderView.value] animated:animated];
    BOOL willDeemphasize = [modeInfo shouldDeemphasizeSliderForVolume:_sliderView.value];
    if (willDeemphasize == hasDeemphasized) return;
    hasDeemphasized = willDeemphasize;
    [UIView animateWithDuration:0.2 animations:^{
        self->_sliderView.barAlpha = willDeemphasize ? 0.25 : 1;
    }];
}

- (void)adjustTransformForOLEDMode:(BOOL)oledMode {
    [self updateSliderStyling];
    [self updateBlurEffect];
    backdropView.transform = oledMode ? CGAffineTransformMakeScale(0.7, 0.7) : CGAffineTransformIdentity;
    topStackView.alpha = oledMode ? 0 : 1;
    bottomStackView.alpha = oledMode ? 0 : 1;
}

- (void)setInLandscapeMode:(BOOL)isInLandscapeMode {
    _isInLandscapeMode = isInLandscapeMode;
    [self applySettings];
}

// MARK: - Icon View Delegate

- (void)tappedIconView:(ABVolumeHUDIconView *)iconView {
    if (self.delegate) [self.delegate shouldSwitchModes];
}

// MARK: - Volume Slider Delegate

- (void)sliderValueChangedTo:(CGFloat)value {
    NSString *overrideText = [modeInfo overrideTextForVolume:value];
    if (overrideText) {
        volumeLabel.attributedText = [[NSAttributedString alloc] initWithString:overrideText attributes:@{NSFontAttributeName: kVolumeLabelOverrideFont}];
    } else {
        volumeLabel.text = [NSString stringWithFormat:@"%.f%%", value * 100];
    }
    
    iconView.volume = value;
    
    if (self.delegate) [self.delegate sliderValueChangedTo:value];
}

- (void)sliderBeingTouchedChangedTo:(BOOL)isBeingTouched {
    if (!self.delegate) return;
    NSObject <ABVolumeHUDTapticFeedbackProviding>*tapticProvider = [ABVolumeHUDViewSettings sharedSettings].enableHapticFeedback ? [ABVolumeHUDManager sharedManager].tapticFeedbackProvider : nil;
    if (isBeingTouched) {
        [[self.delegate visibilityManager] prolongDisplayForReason:@"slider_touch"];
        if (tapticProvider) [tapticProvider warmUp];
    } else {
        [[self.delegate visibilityManager] releaseProlongedDisplayForReason:@"slider_touch"];
        if (tapticProvider) [tapticProvider coolDown];
    }
}

- (void)userChangedSliderValueTo:(CGFloat)value {
    [[NSNotificationCenter defaultCenter] postNotificationName:kVolumeChangeNotification object:nil userInfo:@{@"volume": @(value), @"mode": @(modeInfo.mode)}];
}

@end
