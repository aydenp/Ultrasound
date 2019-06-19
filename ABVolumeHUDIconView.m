//
//  ABVolumeHUDIconView.m
//  Ultrasound
//
//  Created by Ayden Panhuyzen on 8/28/18.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

#import "ABVolumeHUDIconView.h"
#import "ABVolumeHUDIconVolumeGlyph.h"
#import "ABVolumeHUDIconRingerGlyph.h"

@implementation ABVolumeHUDIconView {
    UIView<ABVolumeHUDIconGlyphProviding> *glyphView;
    NSLayoutConstraint *squareHeightConstraint;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) [self setupForDisplay];
    return self;
}

- (void)setupForDisplay {
    self.userInteractionEnabled = YES;
    NSLayoutConstraint *heightConstraint = [self.heightAnchor constraintEqualToConstant:22];
    heightConstraint.priority = UILayoutPriorityDefaultLow;
    heightConstraint.active = YES;
    [self.widthAnchor constraintEqualToConstant:26].active = YES;
    squareHeightConstraint = [self.heightAnchor constraintEqualToAnchor:self.widthAnchor];
    self.backgroundColor = [UIColor whiteColor];
}

- (void)setupGlyphView:(UIView<ABVolumeHUDIconGlyphProviding> *)_glyphView {
    if (glyphView) [glyphView removeFromSuperview];
    glyphView = _glyphView;
    glyphView.translatesAutoresizingMaskIntoConstraints = NO;
    [self updateVolume];
    
    self.maskView = glyphView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    glyphView.frame = CGRectMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds), 0, 0);
}

- (void)setVolume:(CGFloat)volume {
    _volume = volume;
    [self updateVolume];
}

- (void)updateVolume {
    [glyphView setVolume:_modeInfo ? [_modeInfo iconVolumeForRealVolume:_volume] : _volume];
}

- (void)setMustBeSquare:(BOOL)mustBeSquare {
    _mustBeSquare = mustBeSquare;
    squareHeightConstraint.active = mustBeSquare;
}

- (void)setModeInfo:(ABVolumeHUDVolumeModeInfo *)modeInfo {
    if (_modeInfo && _modeInfo.mode == modeInfo.mode) return;
    _modeInfo = modeInfo;
    [self setupGlyphView:modeInfo.iconGlyphProvider];
}

- (void)setIsTouchedDown:(BOOL)isTouchedDown {
    if (_isTouchedDown == isTouchedDown) return;
    _isTouchedDown = isTouchedDown;
    CGFloat newScale = isTouchedDown ? 0.85 : 1;
    [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:1 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.transform = CGAffineTransformMakeScale(newScale, newScale);
    } completion:nil];
}

- (void)handleTap {
    if (![self canHandleTouches]) return;
    [self.delegate tappedIconView:self];
}

- (BOOL)canHandleTouches {
    return self.delegate && [self.delegate respondsToSelector:@selector(tappedIconView:)];
}

// MARK: - Touch Handling

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.isTouchedDown = [self canHandleTouches];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.isTouchedDown = NO;
    [self isTouchedDown];
    [self handleTap];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.isTouchedDown = NO;
}

@end
