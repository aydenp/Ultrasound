//
//  ABVolumeHUDContainerView.m
//  Ultrasound
//
//  Created by Ayden Panhuyzen on 8/27/18.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

#import "ABVolumeHUDContainerViewController.h"

@implementation ABVolumeHUDContainerViewController

- (void)loadView {
    self.view = [[ABVolumeHUDContainerView alloc] init];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (ABVolumeHUDContainerView *)containerView {
    return (ABVolumeHUDContainerView *)self.view;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];

    if (@available(iOS 13.0, *)) {
        if (self.traitCollection.userInterfaceStyle == previousTraitCollection.userInterfaceStyle) return;
        [self.containerView userInterfaceStyleChanged];
    }
}

// Now required in addition to window-level security to display while locked: https://twitter.com/aydenpanhuyzen/status/1205981143377612800
- (BOOL)_canShowWhileLocked {
    return YES;
}

@end
