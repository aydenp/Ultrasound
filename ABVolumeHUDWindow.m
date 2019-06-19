//
//  ABVolumeHUDWindow.m
//  Ultrasound
//
//  Created by Ayden Panhuyzen on 8/27/18.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

#import "Headers.h"
#import "ABVolumeHUDWindow.h"
#import "ABVolumeHUDContainerViewController.h"

@implementation ABVolumeHUDWindow

- (id)init {
    self = [super init];
    if (self) {
        self.backgroundColor = nil;
        self.hidden = NO;
        self.windowLevel = 1100; // just above banners
    }
    return self;
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (_darkScreenImitationAlpha > 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kOLEDWindowTappedNotification object:nil];
        return NO;
    }
    for (UIView *view in self.subviews) {
        if ([view.nextResponder isKindOfClass:[ABVolumeHUDContainerViewController class]] && [view pointInside:[self convertPoint:point toView:view] withEvent:event]) return YES;
    }
    return NO;
}

- (BOOL)_shouldCreateContextAsSecure {
    return YES;
}

- (void)setDarkScreenImitationAlpha:(CGFloat)darkScreenImitationAlpha {
    _darkScreenImitationAlpha = darkScreenImitationAlpha;
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:darkScreenImitationAlpha];
}

@end
