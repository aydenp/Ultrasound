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

@end
