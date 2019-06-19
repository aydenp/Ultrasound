//
//  ABVolumeHUDContainerView.m
//  Ultrasound
//
//  Created by Ayden Panhuyzen on 8/27/18.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

#import "ABVolumeHUDContainerView.h"
#import "ABVolumeHUDDeviceInfo.h"
#import "UIScreen+CornerRadius.h"
#import "ABVolumeHUDManager.h"
#import "ABVolumeHUDOLEDInfoView.h"
#import "ABInstantPanGestureRecognizer.h"
#import "ABVolumeHUDViewSettings.h"

#define kHUDDismissHorizontalOffset 28

@implementation ABVolumeHUDContainerView {
    ABVolumeHUDView *volumeHUD;
    ABVolumeHUDVisibilityManager *visibilityManager;
    NSLayoutConstraint *edgeConstraint;
    NSLayoutConstraint *edgeOLEDConstraint;
    BOOL isAnimatingVisibility;
    UIViewPropertyAnimator *animator;
    BOOL _visible;
    ABVolumeHUDDeviceInfo *deviceInfo;
    UIView *mockVolumeSlider;
    ABVolumeHUDOLEDInfoView *oledInfoView;
    ABVolumeHUDVolumeModeInfo *volumeModeInfo;
    ABInstantPanGestureRecognizer *interactiveDismissPan;
    CGFloat interactiveStartPosition;
    CGFloat interactiveTranslation;
    BOOL hasYetToDecideTouchPurpose;
    CGFloat previousSliderValue;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        deviceInfo = [ABVolumeHUDDeviceInfo infoForCurrentDevice];
        [self setupForDisplay];
        previousSliderValue = -1;
    }
    return self;
}

- (void)setEffectiveOrientation:(UIInterfaceOrientation)effectiveOrientation {
    _effectiveOrientation = effectiveOrientation;
    [self adjustOrientation];
}

- (void)adjustOrientation {
    UIInterfaceOrientation orientation = _effectiveOrientation;
    [UIView performWithoutAnimation:^{
        self->volumeHUD.containerView.transform = orientation == UIInterfaceOrientationPortraitUpsideDown || orientation == UIInterfaceOrientationLandscapeLeft ? CGAffineTransformMakeRotation(M_PI) : CGAffineTransformIdentity;
        self->volumeHUD.topContainerView.transform = _oledMode ? CGAffineTransformIdentity : self->volumeHUD.containerView.transform;
        BOOL isLandscape = UIInterfaceOrientationIsLandscape(orientation);
        self->volumeHUD.sliderView.transform = isLandscape && !_oledMode ? CGAffineTransformMakeRotation(M_PI) : CGAffineTransformIdentity;
        for (UIView *accessoryView in self->volumeHUD.accessoryViews) accessoryView.transform = isLandscape ? CGAffineTransformMakeRotation(M_PI_2) : CGAffineTransformIdentity;
        self->volumeHUD.isInLandscapeMode = isLandscape;
    }];
}

- (void)setupForDisplay {
    visibilityManager = [[ABVolumeHUDVisibilityManager alloc] init];
    visibilityManager.delegate = self;
    
    // Make a hidden view that always is aligned to physical buttons, for referencing in constraints later
    mockVolumeSlider = [[UIView alloc] init];
    mockVolumeSlider.hidden = YES;
    mockVolumeSlider.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:mockVolumeSlider];
    [mockVolumeSlider.heightAnchor constraintEqualToConstant:deviceInfo.volumeButtonHeight].active = YES;
    [mockVolumeSlider.widthAnchor constraintEqualToConstant:0].active = YES;
    [mockVolumeSlider.topAnchor constraintEqualToAnchor:self.topAnchor constant:deviceInfo.volumeButtonTopOffset].active = YES;
    [[self edgeAnchorForView:mockVolumeSlider] constraintEqualToAnchor:self.edgeAnchor].active = YES;
    
    // Create volume HUD view itself
    volumeHUD = [[ABVolumeHUDView alloc] init];
    volumeHUD.translatesAutoresizingMaskIntoConstraints = NO;
    volumeHUD.delegate = self;
    volumeHUD.sliderView.viewToAnimateLayout = self;
    volumeHUD.hidden = YES;
    [self addSubview:volumeHUD];
    
    interactiveDismissPan = [[ABInstantPanGestureRecognizer alloc] initWithTarget:self action:@selector(interactiveDismissPanned:)];
    interactiveDismissPan.delaysTouchesBegan = NO;
    interactiveDismissPan.delaysTouchesEnded = NO;
    interactiveDismissPan.cancelsTouchesInView = NO;
    interactiveDismissPan.delegate = self;
    [volumeHUD addGestureRecognizer:interactiveDismissPan];
    
    // Create view for additional info while in OLED mode
    oledInfoView = [[ABVolumeHUDOLEDInfoView alloc] init];
    oledInfoView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:oledInfoView];
    [[self edgeAnchorForView:oledInfoView] constraintEqualToAnchor:[self inverseEdgeAnchorForView:volumeHUD.sliderView] constant:12 * [self edgeConstantMultiplier]].active = YES;
    [oledInfoView.topAnchor constraintGreaterThanOrEqualToAnchor:volumeHUD.sliderView.topAnchor].active = YES;
    [oledInfoView.bottomAnchor constraintLessThanOrEqualToAnchor:volumeHUD.sliderView.bottomAnchor].active = YES;
    NSLayoutConstraint *followKnobConstraint = [oledInfoView.centerYAnchor constraintEqualToAnchor:volumeHUD.sliderView.knobVerticalAnchor];
    followKnobConstraint.priority = UILayoutPriorityDefaultLow;
    followKnobConstraint.active = YES;
    
    // Ensure that volume HUD doesn't go above top screen corner
    [volumeHUD.topAnchor constraintGreaterThanOrEqualToAnchor:self.topAnchor constant:fmax(8, [UIScreen mainScreen]._displayCornerRadius)].active = YES;
    
    // Create constraint to align slider with volume buttons from top
    NSLayoutConstraint *volumeButtonTopConstraint = [volumeHUD.sliderView.centerYAnchor constraintEqualToAnchor:mockVolumeSlider.centerYAnchor];
    volumeButtonTopConstraint.priority = UILayoutPriorityDefaultLow;
    volumeButtonTopConstraint.active = YES;
    
    // Make sure slider is same height as volume buttons
    NSLayoutConstraint *volumeButtonSliderHeightAnchor = [volumeHUD.sliderView.heightAnchor constraintEqualToAnchor:mockVolumeSlider.heightAnchor];
    volumeButtonSliderHeightAnchor.priority = UILayoutPriorityDefaultLow;
    volumeButtonSliderHeightAnchor.active = YES;
    
    // Constraint to pin volume HUD to edge of screen
    edgeConstraint = [[self edgeAnchorForView:volumeHUD] constraintEqualToAnchor:self.edgeAnchor constant:8 * self.edgeConstantMultiplier];
    edgeConstraint.active = YES;
    // Constraint to pin volume HUD to edge of screen while in OLED mode
    edgeOLEDConstraint = [[self edgeAnchorForView:volumeHUD.sliderView] constraintEqualToAnchor:self.edgeAnchor constant:2 * self.edgeConstantMultiplier];
    
    // Set initial positioning and transformation
    [self updateVolumeHUDVisible:_visible oledMode:_oledMode interactive:NO];
    [self updatePositioningAnimated:NO];
    [self layoutIfNeeded];
}

- (void)interactiveDismissPanned:(ABInstantPanGestureRecognizer *)gesture {
    CGFloat translation = [gesture translationInView:self].x;
    CGPoint velocity = [gesture velocityInView:self];
    if (gesture.state == UIGestureRecognizerStateBegan) {
        // Stop if already running
        if (animator.isRunning) {
            [animator stopAnimation:NO];
        }
        
        [self createVisibilityAnimatorForTransitionToVisible:NO interactive:YES];
        [self.visibilityManager prolongDisplayForReason:@"dismiss_interactive_touch"];
        interactiveStartPosition = deviceInfo.rightAlignControls ? self.bounds.size.width - CGRectGetMinX(volumeHUD.frame) : CGRectGetMaxX(volumeHUD.frame);
        
        // If the touch isn't inside the slider hit area, it's going to be a dismiss either way, so don't bother checking velocity later on. If it is inside, mark that we need to decide the touch's purpose
        CGPoint sliderRelativeLocation = [gesture locationInView:volumeHUD.sliderView];
        hasYetToDecideTouchPurpose = [volumeHUD.sliderView pointInside:sliderRelativeLocation withEvent:nil];
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        // Don't do anything without stopped animator
        if (!animator || animator.isRunning) return;
        
        // Cancel this pan if we're moving too far vertically
        if (hasYetToDecideTouchPurpose) {
            if (fabs(velocity.y) > 0.05 && fabs(velocity.x / velocity.y) <= 1) {
                // Touch is likely moving vertically and trying to adjust volume, cancel dismiss pan
                gesture.state = UIGestureRecognizerStateFailed;
                return;
            } else if (fabs(velocity.x) > 0.05 && fabs(velocity.y / velocity.x) <= 0.1) {
                // Touch seems to be moving horizontally, stop checking touch direction like this
                hasYetToDecideTouchPurpose = NO;
            }
        }
        
        // Calculate and apply completion
        CGFloat completionFraction = (translation + (deviceInfo.rightAlignControls ? 0 : interactiveStartPosition)) / interactiveStartPosition;
        animator.fractionComplete = MAX(0.001, MIN(0.999, deviceInfo.rightAlignControls ? completionFraction : 1 - completionFraction));
    } else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateFailed || gesture.state == UIGestureRecognizerStateCancelled) {
        [self.visibilityManager releaseProlongedDisplayForReason:@"dismiss_interactive_touch"];
        
        // Figure out whether to dismiss or not
        CGFloat dismissPositionThreshold = interactiveStartPosition / 2;
        BOOL willContinueDismiss = velocity.x * [self edgeConstantMultiplier] < -25 || -translation * [self edgeConstantMultiplier] > dismissPositionThreshold;
        animator.reversed = !willContinueDismiss;
        if (willContinueDismiss) {
            // If we are dismissing, make sure we set to not visible after done
            [animator addCompletion:^(UIViewAnimatingPosition finalPosition) {
                if (finalPosition == UIViewAnimatingPositionEnd) {
                    self->_visible = NO;
                }
            }];
        }
        
        // Continue animation
        UISpringTimingParameters *springParameters = [[UISpringTimingParameters alloc] initWithDampingRatio:0.9 initialVelocity:CGVectorMake(velocity.x / 100, velocity.y / 100)];
        [animator continueAnimationWithTimingParameters:springParameters durationFactor:0.9];
    }
}

- (void)volumeChangedTo:(CGFloat)volume withMode:(ABVolumeHUDVolumeMode)mode {
    if (!volumeModeInfo || mode != volumeModeInfo.mode) volumeModeInfo = [ABVolumeHUDVolumeModeInfo infoForVolumeMode:mode];
    [self layoutIfNeeded];
    [volumeHUD volumeChangedTo:volume withModeInfo:volumeModeInfo];
    [visibilityManager showVolumeHUD];
}

- (void)evaluateTapticFeedbackForVolume:(CGFloat)volume fromPreviousVolume:(CGFloat)previousVolume {
    if (previousVolume < 0 || ![ABVolumeHUDViewSettings sharedSettings].enableHapticFeedback) return;
    BOOL shouldPlayFeedback = (previousVolume > 0 && volume <= 0) || (previousVolume < 1 && volume >= 1);
    if (!shouldPlayFeedback) return;
    NSObject <ABVolumeHUDTapticFeedbackProviding>*tapticProvider = [ABVolumeHUDManager sharedManager].tapticFeedbackProvider;
    if (!tapticProvider) return;
    [tapticProvider actuate];
}

- (void)setOLEDMode:(BOOL)oledMode {
    [self setOLEDMode:oledMode animated:YES];
}

- (void)setOLEDMode:(BOOL)oledMode animated:(BOOL)animated {
    _oledMode = oledMode;
    [self updateInteractivePanEnabled];
    [self updateOLEDModeAnimated:animated];
    [self adjustOrientation];
}

- (void)updateOLEDModeAnimated:(BOOL)animated {
    if (isAnimatingVisibility) return;
    [volumeHUD setOLEDMode:_oledMode animated:animated];
    [self updatePositioningAnimated:animated];
    [visibilityManager restartIdleTimer];
    [self updateOLEDInfoViewAnimated:animated];
}

- (void)updatePositioningAnimated:(BOOL)animated {
    edgeConstraint.active = !_oledMode;
    edgeOLEDConstraint.active = _oledMode;
    volumeHUD.maxVolumeSliderHeightConstraint.active = !_oledMode;
    if (animated) {
        [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
            [self layoutIfNeeded];
        } completion:nil];
    }
}

- (void)updateOLEDInfoViewAnimated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [self updateOLEDInfoViewAnimated:NO];
        } completion:nil];
    } else {
        oledInfoView.alpha = _visible && _oledMode ? 1 : 0;
        oledInfoView.transform = _oledMode || !_visible ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(kHUDDismissHorizontalOffset, 0);
    }
}

- (void)createVisibilityAnimatorForTransitionToVisible:(BOOL)visible interactive:(BOOL)interactive {
    UIViewPropertyAnimator *animator = [[UIViewPropertyAnimator alloc] initWithDuration:0.35 dampingRatio:0.9 animations:^{
        [self updateVolumeHUDVisible:visible oledMode:self->_oledMode interactive:interactive];
        [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [self updateOLEDInfoViewAnimated:NO];
        } completion:nil];
    }];
    [animator addCompletion:^(UIViewAnimatingPosition finalPosition) {
        if (finalPosition == UIViewAnimatingPositionEnd && self->animator == animator) {
            self->isAnimatingVisibility = NO;
            self->volumeHUD.hidden = !visible;
            [self updateOLEDModeAnimated:NO];
            [self updateInteractivePanEnabled];
            [[NSNotificationCenter defaultCenter] postNotificationName:kControlVisibilityChangedNotification object:nil userInfo:@{@"visible": @(visible)}];
        }
    }];
    self->animator = animator;
}

- (void)updateInteractivePanEnabled {
    interactiveDismissPan.enabled = _visible && !isAnimatingVisibility && !_oledMode;
}

- (void)shouldSwitchModes {
    if (![ABVolumeHUDManager sharedManager].volumeInfoProvider) return;
    
    // Get new desired mode
    ABVolumeHUDVolumeMode newMode = volumeModeInfo.mode == ABVolumeHUDVolumeModeRinger ? ABVolumeHUDVolumeModeAudioVolume : ABVolumeHUDVolumeModeRinger;
    
    // Get new display volume
    CGFloat newVolume = [[ABVolumeHUDManager sharedManager].volumeInfoProvider volumeForVolumeMode:newMode];
    if (newVolume < 0) return;
    
    [[ABVolumeHUDManager sharedManager] volumeChangedTo:newVolume withMode:newMode];
    [[NSNotificationCenter defaultCenter] postNotificationName:kVolumeModeChangeNotification object:nil userInfo:@{@"mode": @(newMode)}];
}

// MARK: - Visibility Manager Delegate

- (void)shouldChangeVolumeHUDVisibleTo:(BOOL)visible {
    if (visible == _visible) return;
    _visible = visible;
    if (!isAnimatingVisibility) {
        [self updateVolumeHUDVisible:!visible oledMode:_oledMode];
        volumeHUD.hidden = NO;
    }
    isAnimatingVisibility = YES;
    [self createVisibilityAnimatorForTransitionToVisible:visible interactive:NO];
    [animator startAnimation];
}

- (void)updateVolumeHUDVisible:(BOOL)visible oledMode:(BOOL)oledMode {
    [self updateVolumeHUDVisible:visible oledMode:oledMode interactive:NO];
}

- (void)updateVolumeHUDVisible:(BOOL)visible oledMode:(BOOL)oledMode interactive:(BOOL)interactive {
    self->volumeHUD.alpha = visible || oledMode || interactive ? 1 : 0;
    if (visible) {
        self->volumeHUD.transform = CGAffineTransformIdentity;
    } else if (oledMode) {
        self->volumeHUD.transform = CGAffineTransformMakeTranslation(-6 * self.edgeConstantMultiplier, 0);
    } else {
        self->volumeHUD.transform = interactive ? CGAffineTransformMakeTranslation(-interactiveStartPosition * self.edgeConstantMultiplier, 0) : CGAffineTransformTranslate(CGAffineTransformMakeScale(0.5, 0.5), -24 * self.edgeConstantMultiplier, 0);
    }
}

// MARK: - Convenience for Edge Alignment

- (CGFloat)edgeConstantMultiplier {
    return deviceInfo.rightAlignControls ? -1 : 1;
}

- (NSLayoutAnchor *)edgeAnchor {
    return [self edgeAnchorForView:self];
}

- (NSLayoutAnchor *)edgeAnchorForView:(UIView *)view {
    if (deviceInfo.rightAlignControls) return view.rightAnchor;
    return view.leftAnchor;
}

- (NSLayoutAnchor *)inverseEdgeAnchorForView:(UIView *)view {
    if (deviceInfo.rightAlignControls) return view.leftAnchor;
    return view.rightAnchor;
}

// MARK: - Volume HUD Delegate

- (ABVolumeHUDVisibilityManager *)visibilityManager {
    return visibilityManager;
}

- (void)sliderValueChangedTo:(CGFloat)value {
    [oledInfoView volumeChangedTo:value withModeInfo:volumeModeInfo];
    
    CGFloat _volume = previousSliderValue;
    previousSliderValue = value;
    [self evaluateTapticFeedbackForVolume:value fromPreviousVolume:_volume];
}

// MARK: - Hit Test

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return [volumeHUD pointInside:[self convertPoint:point toView:volumeHUD] withEvent:event] || _oledMode;
}

// MARK - Gesture Recognizer Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return gestureRecognizer == interactiveDismissPan && otherGestureRecognizer == volumeHUD.sliderView.panGestureRecognizer;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return gestureRecognizer == interactiveDismissPan && interactiveDismissPan.state != UIGestureRecognizerStateFailed && otherGestureRecognizer == volumeHUD.sliderView.panGestureRecognizer;
}

@end
