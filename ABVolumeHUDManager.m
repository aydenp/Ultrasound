//
//  ABVolumeHUDManager.m
//  Ultrasound
//
//  Created by Ayden Panhuyzen on 8/27/18.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

#import "ABVolumeHUDManager.h"
#import "ABVolumeHUDContainerViewController.h"
#import "ABVolumeHUDThemeDark.h"
#import "ABVolumeHUDThemeExtraLight.h"

BOOL isDarkMode() {
    switch (UIScreen.mainScreen.traitCollection.userInterfaceStyle) {
        case UIUserInterfaceStyleDark:
            return true;
        case UIUserInterfaceStyleLight:
            return false;
    }
}

@implementation ABVolumeHUDManager {
    ABVolumeHUDContainerViewController *viewController;
    BOOL oledModeForHUDCreation;
}

@synthesize theme = _theme;

+ (instancetype)sharedManager {
    static ABVolumeHUDManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (void)createViewIfDoesntExist {
    if (![NSThread isMainThread]) return [self performSelectorOnMainThread:@selector(createViewIfDoesntExist) withObject:nil waitUntilDone:YES];
    if (viewController != nil || _targetView == nil) return;
    
    viewController = [[ABVolumeHUDContainerViewController alloc] init];
    viewController.containerView.effectiveOrientation = _orientation;
    viewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [viewController.containerView setOLEDMode:oledModeForHUDCreation animated:NO];
    oledModeForHUDCreation = NO;
    
    if ([_targetView isKindOfClass:[UIWindow class]]) ((UIWindow *)_targetView).rootViewController = viewController;
    else [_targetView addSubview:viewController.view];
}

- (void)destroyView {
    if (viewController == nil) return;
    if ([_targetView isKindOfClass:[UIWindow class]]) ((UIWindow *)_targetView).rootViewController = nil;
    else [viewController.view removeFromSuperview];
    viewController = nil;
}

- (void)setTargetView:(UIView *)targetView {
    [self destroyView];
    _targetView = targetView;
}

- (ABVolumeHUDVisibilityManager *)visibilityManager {
    [self createViewIfDoesntExist];
    return viewController.containerView.visibilityManager;
}

- (void)volumeChangedTo:(CGFloat)volume withMode:(ABVolumeHUDVolumeMode)mode {
    [self createViewIfDoesntExist];
    // If the HUD view still doesn't exist, just cancel.
    if (viewController == nil) return;
    
    if (isDarkMode()) {
        self.theme = [ABVolumeHUDThemeDark alloc];
    }
    else {
        self.theme = [ABVolumeHUDThemeExtraLight alloc];
    }

    [viewController.containerView volumeChangedTo:volume withMode:mode];
}

- (void)volumeChangedTo:(CGFloat)volume {
    [self volumeChangedTo:volume withMode:0];
    if (isDarkMode()) {
        self.theme = [ABVolumeHUDThemeDark alloc];
    }
    else {
        self.theme = [ABVolumeHUDThemeExtraLight alloc];
    }
}

- (BOOL)oledMode {
    if (viewController == nil) return NO;
    return viewController.containerView.oledMode;
}

- (void)setOLEDMode:(BOOL)oledMode {
    if (viewController == nil) {
        oledModeForHUDCreation = oledMode;
        return;
    }
    viewController.containerView.oledMode = oledMode;
}

- (NSObject <ABVolumeHUDTheme>*)theme {
    if (!_theme) _theme = [[ABVolumeHUDThemeDark alloc] init];
    return _theme;
}

- (void)setTheme:(NSObject<ABVolumeHUDTheme> *)theme {
    BOOL isChanged = _theme != theme;
    _theme = theme;
    [[NSNotificationCenter defaultCenter] postNotificationName:kThemeChangedNotification object:nil userInfo:@{@"animated": @(isChanged)}];
}

- (void)setOrientation:(UIInterfaceOrientation)orientation {
    _orientation = orientation;
    if (viewController) viewController.containerView.effectiveOrientation = orientation;
}

@end
