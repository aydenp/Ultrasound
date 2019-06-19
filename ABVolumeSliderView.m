//
//  ABVolumeSliderView.m
//  Ultrasound
//
//  Created by Ayden Panhuyzen on 8/27/18.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

#import "ABVolumeSliderView.h"
#import "ABVolumeSliderBar.h"
#import "ABVolumeSliderKnob.h"

#define kSliderInactiveTrackColour [UIColor colorWithWhite:1 alpha:0.2]
#define kSliderActiveTrackAndKnobColour [UIColor whiteColor]

@implementation ABVolumeSliderView {
    ABVolumeSliderKnob *knobView;
    UIView *knobContainerView;
    ABVolumeSliderBar *activeBar;
    ABVolumeSliderBar *totalBar;
    NSLayoutConstraint *activeHeightConstraint;
    UIView *containerView;
    BOOL isBeingTouched;
    CGFloat beginningTouchValue;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _editable = YES;
        [self setupForDisplay];
    }
    return self;
}

- (void)setupForDisplay {
    containerView = [[UIView alloc] init];
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:containerView];
    [containerView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [containerView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [containerView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
    [containerView.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
    
    totalBar = [[ABVolumeSliderBar alloc] init];
    totalBar.translatesAutoresizingMaskIntoConstraints = NO;
    totalBar.backgroundColor = kSliderInactiveTrackColour;
    [containerView addSubview:totalBar];
    [totalBar.topAnchor constraintEqualToAnchor:containerView.topAnchor].active = YES;
    [totalBar.bottomAnchor constraintEqualToAnchor:containerView.bottomAnchor].active = YES;
    [totalBar.leftAnchor constraintEqualToAnchor:containerView.leftAnchor].active = YES;
    [totalBar.rightAnchor constraintEqualToAnchor:containerView.rightAnchor].active = YES;
    
    activeBar = [[ABVolumeSliderBar alloc] init];
    activeBar.translatesAutoresizingMaskIntoConstraints = NO;
    activeBar.backgroundColor = kSliderActiveTrackAndKnobColour;
    [containerView addSubview:activeBar];
    [activeBar.bottomAnchor constraintEqualToAnchor:containerView.bottomAnchor].active = YES;
    [activeBar.leftAnchor constraintEqualToAnchor:containerView.leftAnchor].active = YES;
    [activeBar.rightAnchor constraintEqualToAnchor:containerView.rightAnchor].active = YES;
    [self updateValueAnimated:NO];
    
    knobContainerView = [[UIView alloc] init];
    knobContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:knobContainerView];
    [knobContainerView.centerYAnchor constraintEqualToAnchor:activeBar.topAnchor].active = YES;
    [knobContainerView.centerXAnchor constraintEqualToAnchor:activeBar.centerXAnchor].active = YES;
    
    knobView = [[ABVolumeSliderKnob alloc] init];
    knobView.translatesAutoresizingMaskIntoConstraints = NO;
    knobView.backgroundColor = kSliderActiveTrackAndKnobColour;
    [knobContainerView addSubview:knobView];
    [knobView.topAnchor constraintEqualToAnchor:knobContainerView.topAnchor].active = YES;
    [knobView.bottomAnchor constraintEqualToAnchor:knobContainerView.bottomAnchor].active = YES;
    [knobView.leftAnchor constraintEqualToAnchor:knobContainerView.leftAnchor].active = YES;
    [knobView.rightAnchor constraintEqualToAnchor:knobContainerView.rightAnchor].active = YES;
    
    _panGestureRecognizer = [[ABInstantPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    _panGestureRecognizer.delaysTouchesBegan = NO;
    _panGestureRecognizer.delaysTouchesEnded = NO;
    _panGestureRecognizer.cancelsTouchesInView = NO;
    [self addGestureRecognizer:_panGestureRecognizer];
}

- (void)setValue:(CGFloat)value {
    [self setValue:value animated:YES];
}

- (void)setValue:(CGFloat)value animated:(BOOL)animated {
    [self setValue:value animated:animated fromSource:NO];
}

- (void)setValue:(CGFloat)value animated:(BOOL)animated fromSource:(BOOL)fromSource {
    if (isBeingTouched && !fromSource) return;
    _value = value;
    [self updateValueAnimated:animated];
    if (self.delegate) {
        [self.delegate sliderValueChangedTo:value];
        if (fromSource) [self notifyOfUserSliderValueChangeTo:value];
    }
}

- (void)updateValueAnimated:(BOOL)animated {
    if (activeHeightConstraint) activeHeightConstraint.active = NO;
    activeHeightConstraint = [activeBar.heightAnchor constraintEqualToAnchor:self.heightAnchor multiplier:fmin(1, fmax(0, _value))];
    activeHeightConstraint.active = YES;
    if (animated) [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
        [(self->_viewToAnimateLayout ? self->_viewToAnimateLayout : self) layoutIfNeeded];
    } completion:nil];
}

- (void)setEditable:(BOOL)editable {
    [self setEditable:editable animated:YES];
}

- (void)setEditable:(BOOL)editable animated:(BOOL)animated {
    if (!editable) [self changeBeingTouched:NO];
    if (animated) {
        [UIView animateWithDuration:editable ? 0.3 : 0.2 delay:0 usingSpringWithDamping:editable ? 0.5 : 1 initialSpringVelocity:1 options:0 animations:^{
            [self adjustTransformForEditable:editable];
        } completion:nil];
    } else [self adjustTransformForEditable:editable];
    beginningTouchValue = _value;
    self.userInteractionEnabled = editable;
    _panGestureRecognizer.enabled = editable;
    _editable = editable;
}

- (void)adjustTransformForEditable:(BOOL)editable {
    knobView.transform = editable ? CGAffineTransformIdentity : CGAffineTransformMakeScale(0.01, 0.01);
}

- (void)notifyOfUserSliderValueChangeTo:(CGFloat)value {
    if (!self.delegate || ![self.delegate respondsToSelector:@selector(userChangedSliderValueTo:)]) return;
    [self.delegate userChangedSliderValueTo:value];
}

- (void)panned:(ABInstantPanGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:totalBar];
    [self changeBeingTouched:gesture.isBeingTouched];
    if (gesture.state == UIGestureRecognizerStateCancelled || gesture.state == UIGestureRecognizerStateFailed) {
        [self setValue:beginningTouchValue animated:NO fromSource:YES];
        return;
    }
    if (gesture.state == UIGestureRecognizerStateBegan) {
        beginningTouchValue = _value;
    }
    CGFloat newVolume = fmin(1, fmax(0, 1 - point.y / totalBar.bounds.size.height));
    [self setValue:newVolume animated:gesture.state == UIGestureRecognizerStateBegan fromSource:YES];
}

- (void)changeBeingTouched:(BOOL)nowBeingTouched {
    if (isBeingTouched == nowBeingTouched) return;
    isBeingTouched = nowBeingTouched;
    if (!self.delegate || ![self.delegate respondsToSelector:@selector(sliderBeingTouchedChangedTo:)]) return;
    [self.delegate sliderBeingTouchedChangedTo:isBeingTouched];
    CGFloat knobScale = nowBeingTouched ? 1.25 : 1;
    [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:1 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
        self->knobContainerView.transform = CGAffineTransformMakeScale(knobScale, knobScale);
    } completion:nil];
}

- (CGFloat)barAlpha {
    return containerView.alpha;
}

- (void)setBarAlpha:(CGFloat)barAlpha {
    containerView.alpha = barAlpha;
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect outsetBounds = CGRectInset(self.bounds, -16, -16);
    return CGRectContainsPoint(outsetBounds, point);
}

- (NSLayoutAnchor *)knobVerticalAnchor {
    return knobView.centerYAnchor;
}

// MARK: - Colour Changes

- (UIColor *)knobColour {
    return knobView.backgroundColor;
}

- (void)setKnobColour:(UIColor *)knobColour {
    knobView.backgroundColor = knobColour ? knobColour : kSliderActiveTrackAndKnobColour;
}

- (BOOL)knobHasShadow {
    return knobView.hasShadow;
}

- (void)setKnobHasShadow:(BOOL)knobHasShadow {
    knobView.hasShadow = knobHasShadow;
}

- (UIColor *)trackColour {
    return totalBar.backgroundColor;
}

- (void)setTrackColour:(UIColor *)trackColour {
    totalBar.backgroundColor = trackColour ? trackColour : kSliderInactiveTrackColour;
}

- (UIColor *)filledTrackColour {
    return activeBar.backgroundColor;
}

- (void)setFilledTrackColour:(UIColor *)activeTrackColour {
    activeBar.backgroundColor = activeTrackColour ? activeTrackColour : kSliderActiveTrackAndKnobColour;
}

@end
