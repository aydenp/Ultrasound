//
//  Tweak.mm
//  Ultrasound
//
//  Created by Ayden Panhuyzen on 9/4/18.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

#import "Headers.h"
#import "NSObject+SafeKVC.h"
#import "_ABVolumeHUDOrientationManager.h"

// Use boot backlight adjustment source as it will never be used by SpringBoard directly
#define kWillowBacklightAdjustmentSource 15
#define kPrefsAppID CFSTR("applebetas.ios.tweak.willow")

@interface VolumeControl (Additions)
- (void)__us_commonInit;
- (BOOL)__us_presentVolumeHUDWithMode:(int)mode volume:(float)volume;
- (void)__us_presentVolumeHUDWithMode:(int)mode;
- (void)updateSliderVolumeWithNotification:(NSNotification *)note;
- (void)volumeHUDControlHidden;
@end

// MARK: - Convenience

static void wakeScreen() {
    [[%c(SBLockScreenManager) sharedInstance] unlockUIFromSource:0x5 withOptions:@{@"SBUIUnlockOptionsStartFadeInAnimation": @YES, @"SBUIUnlockOptionsTurnOnScreenFirstKey": @YES}];
    [[%c(SBScreenWakeAnimationController) sharedInstance] _startWakeIfNecessary];
}

static SBLockScreenViewControllerBase *getLockScreenViewController() {
    SBLockScreenManager *manager = [%c(SBLockScreenManager) sharedInstance];
    if ([manager respondsToSelector:@selector(coverSheetViewController)]) return [manager coverSheetViewController];
    if ([manager respondsToSelector:@selector(lockScreenViewController)]) return [manager lockScreenViewController];
    return nil;
}

static VolumeControl *getVolumeControl() {
    Class iOS12Class = NSClassFromString(@"VolumeControl");
    if (iOS12Class && [iOS12Class respondsToSelector:@selector(sharedVolumeControl)]) return [iOS12Class sharedVolumeControl];

    Class iOS13Class = NSClassFromString(@"SBVolumeControl");
    if (iOS13Class && [iOS13Class respondsToSelector:@selector(sharedInstance)]) return [iOS13Class sharedInstance];

    return nil;
}

// MARK: - Settings

static BOOL hasLoadedSettings = NO;
static BOOL enabled = YES;
static CGFloat timeout = 1.5;
static BOOL showVolumePercentage = YES;
static BOOL enableOLEDMode = YES;
static BOOL showOLEDVolumeIcon = YES;
static BOOL showOLEDVolumePercentage = YES;
static BOOL enableHapticFeedback = YES;
static NSString *themeName = nil;
static ABVolumeHUDStyle volumeStyle = ABVolumeHUDStyleIconic;
static BOOL themeChanged = NO;
static BOOL styleChanged = NO;

static void applySettings() {
    [ABVolumeHUDViewSettings sharedSettings].timeout = timeout;
    [ABVolumeHUDViewSettings sharedSettings].showVolumePercentage = showVolumePercentage;
    if (!enabled) [[ABVolumeHUDManager sharedManager].visibilityManager hideImmediatelyIfPossible];
    [ABVolumeHUDViewSettings sharedSettings].showOLEDVolumeIcon = showOLEDVolumeIcon;
    [ABVolumeHUDViewSettings sharedSettings].showOLEDVolumePercentage = showOLEDVolumePercentage;
    [ABVolumeHUDManager sharedManager].theme = themeName ? [[NSClassFromString(themeName) alloc] init] : nil;
    [ABVolumeHUDViewSettings sharedSettings].style = volumeStyle;
    [ABVolumeHUDViewSettings sharedSettings].enableHapticFeedback = enableHapticFeedback;

    // If we changed theme or style, show the volume HUD for a preview
    if ((themeChanged || styleChanged) && enabled) [getVolumeControl() __us_presentVolumeHUDWithMode:ABVolumeHUDVolumeModeAudio];
}

static void loadSettings() {
    // TODO: Clean this up
    NSDictionary *settings = nil;
    CFPreferencesAppSynchronize(kPrefsAppID);
    CFArrayRef keyList = CFPreferencesCopyKeyList(kPrefsAppID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    if (keyList) {
        settings = (NSDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, kPrefsAppID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost));
        CFRelease(keyList);
    }
    if (settings && settings[@"Enabled"]) enabled = [settings[@"Enabled"] boolValue];
    if (settings && settings[@"Timeout"]) timeout = [settings[@"Timeout"] doubleValue];
    if (settings && settings[@"ShowVolumePercentage"]) showVolumePercentage = [settings[@"ShowVolumePercentage"] boolValue];
    if (settings && settings[@"EnableOLEDMode"]) {
        enableOLEDMode = [settings[@"EnableOLEDMode"] boolValue];
    } else {
        enableOLEDMode = [ABVolumeHUDDeviceInfo infoForCurrentDevice].hasOLEDScreen;
        NSDictionary *dict = [NSDictionary dictionaryWithObject:@(enableOLEDMode) forKey:@"EnableOLEDMode"];
        CFPreferencesSetMultiple((__bridge CFDictionaryRef)dict, nil, kPrefsAppID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
        CFPreferencesAppSynchronize(kPrefsAppID);
    }
    if (settings && settings[@"ShowVolumeIconOLED"]) showOLEDVolumeIcon = [settings[@"ShowVolumeIconOLED"] boolValue];
    if (settings && settings[@"ShowVolumePercentageOLED"]) showOLEDVolumePercentage = [settings[@"ShowVolumePercentageOLED"] boolValue];
    if (settings && settings[@"Theme"]) {
        NSString *newThemeName = [settings[@"Theme"] stringValue];
        themeChanged = themeName && ![themeName isEqualToString:newThemeName];
        themeName = newThemeName;
    }
    if (settings && settings[@"Style"]) {
        ABVolumeHUDStyle newStyle = (ABVolumeHUDStyle)[settings[@"Style"] integerValue];
        styleChanged = hasLoadedSettings && volumeStyle != newStyle;
        volumeStyle = newStyle;
    }
    if (settings && settings[@"EnableHapticFeedback"]) enableHapticFeedback = [settings[@"EnableHapticFeedback"] boolValue];
    hasLoadedSettings = YES;
    applySettings();
}

static void settingsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    loadSettings();
}

// MARK: - Window Management

static ABVolumeHUDWindow *hudWindow;
static void createWindowIfNeeded() {
    if (hudWindow != nil) return;
    hudWindow = [[ABVolumeHUDWindow alloc] init];
    [[ABVolumeHUDManager sharedManager] setTargetView:hudWindow];
}

static void changeFakeScreenOffAlpha(CGFloat alpha) {
    createWindowIfNeeded();
    hudWindow.darkScreenImitationAlpha = alpha;
}

static void setInOLEDMode(BOOL isInOLEDMode) {
    if ([ABVolumeHUDManager sharedManager]) [ABVolumeHUDManager sharedManager].oledMode = isInOLEDMode;

    // Prevent screen from using system idle timer and accidentally turning off on its own while in OLED mode
    if (isInOLEDMode) [[%c(SBBacklightController) sharedInstance] preventIdleSleep];
    else [[%c(SBBacklightController) sharedInstance] allowIdleSleep];
}

// MARK: - Hooks

static BOOL pretendToNotBeLocked = NO;
static BOOL isGoingToDisplayOLEDVolume = NO;
static BOOL isDisplayingOLEDVolume = NO;

// Renamed to SBVolumeControl on iOS 13+
%hook VolumeControl

// iOS 13+
- (instancetype)initWithHUDController:(id)arg1 ringerControl:(id)arg2 {
    self = %orig;
    if (self) [self __us_commonInit];
    return self;
}

// iOS 12 and lower
- (instancetype)init {
    self = %orig;
    if (self) [self __us_commonInit];
    return self;
}

%new
- (void)__us_commonInit {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSliderVolumeWithNotification:) name:kVolumeChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateVolumeModeWithNotification:) name:kVolumeModeChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeHUDControlVisibilityChangedWithNotification:) name:kControlVisibilityChangedNotification object:nil];
}

%new
- (BOOL)__us_presentVolumeHUDWithMode:(int)mode volume:(float)volume {
    if (!enabled) return NO;
    createWindowIfNeeded();
    if (!hudWindow) return NO;
    if (enableOLEDMode && [getLockScreenViewController() isInScreenOffMode]) {
        // Add black curtain and wake screen for OLED mode
        isGoingToDisplayOLEDVolume = YES;
        changeFakeScreenOffAlpha(1);
        // Delay a tiny bit to allow curtain to appear on slow phones
        if (!isDisplayingOLEDVolume) {
            dispatch_after(DISPATCH_TIME_NOW + 0.01, dispatch_get_main_queue(), ^{
                [[%c(SBBacklightController) sharedInstance] _animateBacklightToFactor:1 duration:0 source:kWillowBacklightAdjustmentSource silently:YES completion:^{
                    isDisplayingOLEDVolume = YES;
                    [[ABVolumeHUDManager sharedManager] volumeChangedTo:volume withMode:(ABVolumeHUDVolumeMode)mode];
                }];
            });
            return YES;
        } 
        isDisplayingOLEDVolume = YES;
    }
    [[ABVolumeHUDManager sharedManager] volumeChangedTo:volume withMode:(ABVolumeHUDVolumeMode)mode];
    return YES;
}

%new
- (void)__us_presentVolumeHUDWithMode:(int)mode {
    float volume = [self respondsToSelector:@selector(_getMediaVolumeForIAP)] ? [self _getMediaVolumeForIAP] : [self getMediaVolume];
    [self __us_presentVolumeHUDWithMode:mode volume:volume];
}

// Exists only on iOS 13+
- (void)_presentVolumeHUDWithVolume:(float)volume {
    if ([self __us_presentVolumeHUDWithMode:ABVolumeHUDVolumeModeAudio volume:volume]) return;
    %orig;
}

// Exists only on iOS 12 and below
- (void)_presentVolumeHUDWithMode:(int)mode volume:(float)volume {
    if ([self __us_presentVolumeHUDWithMode:mode volume:volume]) return;
    %orig;
}

- (BOOL)_HUDIsDisplayableForCategory:(NSString *)category {
    if (!enabled) return %orig;
    SBLockScreenManager *manager = [%c(SBLockScreenManager) sharedInstance];
    if (manager.isUILocked) {
        // By default, lock screen doesn't show volume HUD, but users likely want to see it on the lock screen with Ultrasound.
        // If the screen is off (OLED mode) or no media controls are shown, we force it to show on the lock screen.
        SBLockScreenViewControllerBase *lsViewController = getLockScreenViewController();
        return [lsViewController isInScreenOffMode] || ![lsViewController isShowingMediaControls] || %orig;
    }
    return %orig;
}

- (void)handleVolumeButtonWithType:(long long)arg1 down:(BOOL)arg2 {
    pretendToNotBeLocked = YES;
    %orig;
    pretendToNotBeLocked = NO;
}

- (void)hideVolumeHUDIfVisible {
    %orig;
    [[ABVolumeHUDManager sharedManager].visibilityManager hideImmediatelyIfPossible];
}

//- US Notifications

%new
- (void)updateSliderVolumeWithNotification:(NSNotification *)note {
    CGFloat volume = [note.userInfo[@"volume"] floatValue];
    if ([note.userInfo[@"mode"] integerValue] == ABVolumeHUDVolumeModeRinger) {
        // Changing the ringer volume
        [[%c(AVSystemController) sharedAVSystemController] setVolumeTo:volume forCategory:@"Ringtone"];
    } else {
        // Changing the media volume
        if ([self respondsToSelector:@selector(setMediaVolume:)]) [self setMediaVolume:volume];
        else if ([self respondsToSelector:@selector(_setMediaVolumeForIAP:)]) [self _setMediaVolumeForIAP:volume];
    }
}

%new
- (void)updateVolumeModeWithNotification:(NSNotification *)note {
    int mode = [note.userInfo[@"mode"] intValue];
    [self safelySetValue:@(mode) forKey:@"_mode"];
}

%new
- (void)volumeHUDControlVisibilityChangedWithNotification:(NSNotification *)note {
    if ([note.userInfo[@"visible"] boolValue]) return;
    if (![ABVolumeHUDManager sharedManager].oledMode || !isDisplayingOLEDVolume || ((SBBacklightController *)[%c(SBBacklightController) sharedInstance]).screenIsOn) return;
    [[%c(SBBacklightController) sharedInstance] setBacklightFactor:0 source:kWillowBacklightAdjustmentSource];
    isDisplayingOLEDVolume = NO;
    isGoingToDisplayOLEDVolume = NO;
    changeFakeScreenOffAlpha(0);
}

%end

%hook SBRingerHUDController

+ (void)activate:(int)arg1 {
    // Call the original activate method so we get test vibration based on user settings (fix HUD showing below)
    %orig;

    if (!enabled) return;
    createWindowIfNeeded();
    if (!hudWindow) return;
    float volume;
    if (![[%c(AVSystemController) sharedAVSystemController] getVolume:&volume forCategory:@"Ringtone"]) return;
    [[ABVolumeHUDManager sharedManager] volumeChangedTo:volume withMode:ABVolumeHUDVolumeModeRinger];
}

%end

%hook SBHUDController

// iOS 12 and below
- (void)presentHUDView:(UIView *)view autoDismissWithDelay:(double)delay {
    // Never show the ringer HUD view (since we still call activate for vibrate)
    if (enabled && [view isKindOfClass:%c(SBRingerHUDView)]) return;
    %orig;
}

%end

%hook SBLockScreenManager

- (BOOL)isUILocked {
    // Getting called for the volume HUD presentation requires isUILocked to be NO
    if (enabled && enableOLEDMode && pretendToNotBeLocked) return NO;
    return %orig;
}

%end

%hook SBBacklightController

- (BOOL)screenIsOn {
    // If we're in OLED mode, trick system into thinking the screen is off
    if (enabled && isDisplayingOLEDVolume) return NO;
    return %orig;
}

- (BOOL)screenIsDim {
    // If we're in OLED mode, trick system into thinking the screen is dim
    if (enabled && isDisplayingOLEDVolume) return YES;
    return %orig;
}

-(void)_animateBacklightToFactor:(float)factor duration:(double)duration source:(long long)source silently:(BOOL)silently completion:(/*^block*/id)completion {
    if (enableOLEDMode && isDisplayingOLEDVolume && source != kWillowBacklightAdjustmentSource) {
        // Hacky solution to fix animations not working because SpringBoard ignores this wake
        // Basically, when we wake for OLED mode, we do it with silently set to YES. The rest of SpringBoard isn't notified.
        // But when we actually want to wake up the phone for real, it isn't sent because the factor is already 1.
        // Here we adjust the factor by a tiny bit so that the events get sent throughout SpringBoard.
        [[%c(SBBacklightController) sharedInstance] _animateBacklightToFactor:factor-.0001 duration:0 source:kWillowBacklightAdjustmentSource silently:YES completion:nil];
    }
    %orig;
    if (!enableOLEDMode || !isDisplayingOLEDVolume || source == kWillowBacklightAdjustmentSource) return;
    // Animate the OLED mode curtain away if we're animating backlight
    isDisplayingOLEDVolume = NO;
    isGoingToDisplayOLEDVolume = NO;
    [UIView animateWithDuration:duration animations:^{
        changeFakeScreenOffAlpha(0);
    } completion:^(BOOL finished) {
        if (!finished) return;
        isGoingToDisplayOLEDVolume = NO;
        // Let biometric auth know we actually turned on so it can get ready
        [[%c(SBUIBiometricResource) sharedInstance] noteScreenWillTurnOn];
    }];
}

- (void)setBacklightFactor:(float)factor source:(long long)source {
    if (enableOLEDMode && isDisplayingOLEDVolume && factor <= 0 && source != kWillowBacklightAdjustmentSource) return;
    %orig;
}

%end

%hook SBUIBiometricResource

- (void)noteScreenWillTurnOn {
    if (enableOLEDMode && (isDisplayingOLEDVolume || isGoingToDisplayOLEDVolume)) {
        // If we're in OLED mode, disable Face ID detecting faces
        [self safelySetValue:@NO forKey:@"_isPresenceDetectionAllowed"];
        return;
    }
    %orig;
}

%end

@interface SpringBoard (Willow) 
@property (nonatomic, retain) _ABVolumeHUDOrientationManager *__willow_orientationManager;
@end;

%hook SpringBoard
%property (nonatomic, retain) _ABVolumeHUDOrientationManager *__willow_orientationManager;

- (instancetype)init {
    self = %orig;
    if (self) {
        self.__willow_orientationManager = [[_ABVolumeHUDOrientationManager alloc] init];
        [self addActiveOrientationObserver:self.__willow_orientationManager];
    }
    return self;
}

- (void)applicationDidFinishLaunching:(id)arg1 {
    %orig;
    [ABVolumeHUDManager sharedManager].tapticFeedbackProvider = [[ABVolumeHUDSystemTapticFeedbackProvider alloc] init];
    [ABVolumeHUDManager sharedManager].volumeInfoProvider = [[ABVolumeHUDSystemVolumeInfoProvider alloc] init];
    [ABVolumeHUDManager sharedManager].orientation = [self activeInterfaceOrientation];
}

%end

%group iOS11

%hook SBDashBoardViewController

-(void)setInScreenOffMode:(BOOL)inScreenOffMode forAutoUnlock:(BOOL)autoUnlock {
    %orig;
    // Set OLED mode based on screen state
    if (enabled) setInOLEDMode(inScreenOffMode && enableOLEDMode);
}

%end

%hook SBLiftToWakeManager

- (void)liftToWakeController:(id)arg1 didObserveTransition:(NSInteger)transition {
    if (enabled && isDisplayingOLEDVolume && transition == 2) {
        // Restore lift to wake while in OLED mode
        wakeScreen();
        return;
    }
    %orig;
}

%end

%end

%group iOS12Up

%hook SBDashBoardViewController

-(void)setInScreenOffMode:(BOOL)inScreenOffMode forAutoUnlock:(BOOL)autoUnlock fromUnlockSource:(int)source {
    %orig;
    // Set OLED mode based on screen state
    if (enabled) setInOLEDMode(inScreenOffMode && enableOLEDMode);
}

%end

%hook SBLiftToWakeManager

- (void)liftToWakeController:(id)arg1 didObserveTransition:(NSInteger)transition deviceOrientation:(NSInteger)deviceOrientation {
    if (enabled && isDisplayingOLEDVolume && transition == 2) {
        // Restore lift to wake while in OLED mode
        wakeScreen();
        return;
    }
    %orig;
}

%end

%end

%group iOS13Up

%hook SBRingerControl

- (void)activateRingerHUD:(int)arg1 withInitialVolume:(float)initialVolume fromSource:(unsigned long long)source {
    // Call the original activate method so we get test vibration based on user settings (fix HUD showing below)
    %orig;

    if (!enabled) return;
    createWindowIfNeeded();
    if (!hudWindow) return;
    [[ABVolumeHUDManager sharedManager] volumeChangedTo:[self volume] withMode:ABVolumeHUDVolumeModeRinger];
}

- (void)setVolume:(float)volume forKeyPress:(BOOL)forKeyPress {
    %orig;
    if (!enabled || !hudWindow) return;
    [[ABVolumeHUDManager sharedManager] volumeChangedTo:[self volume] withMode:ABVolumeHUDVolumeModeRinger];
}

%end

// on iOS 13+, the system determines whether or not to vibrate for a ringer change by checking if the HUD is currently presented, so now just literally hide the view
%hook SBRingerHUDViewController

- (void)viewDidLayoutSubviews {
    %orig;
    if (enabled) ((UIViewController *)self).view.hidden = YES;
}

%end

%end

%ctor {
    @autoreleasepool {
        applySettings();
        loadSettings();

        [[NSNotificationCenter defaultCenter] addObserverForName:kOLEDWindowTappedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            if ([%c(SBTapToWakeController) isTapToWakeSupported]) wakeScreen();
        }];

        // listen for notifications from settings
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                        NULL,
                                        (CFNotificationCallback)settingsChanged,
                                        CFSTR("applebetas.ios.tweak.willow.changed"),
                                        NULL,
                                        CFNotificationSuspensionBehaviorDeliverImmediately);


        // This is a bit bad™ for future-proofing as apple could change more details of the class, but for now they're mostly the same (save for one method)
        BOOL isiOS13 = [[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){13,0,0}];
        %init(VolumeControl=objc_getClass(isiOS13 ? "SBVolumeControl" : "VolumeControl"));
        
        if (@available(iOS 13.0, *)) %init(iOS13Up);
        if (@available(iOS 12.0, *)) {
            %init(iOS12Up, SBDashBoardViewController=objc_getClass(isiOS13 ? "CSCoverSheetViewController" : "SBDashBoardViewController"));
        } else {
            %init(iOS11);
        }
   }
}