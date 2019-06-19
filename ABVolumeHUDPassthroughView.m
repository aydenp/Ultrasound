//
//  ABVolumeHUDPassthroughView.m
//  Ultrasound
//
//  Created by Ayden Panhuyzen on 2019-03-03.
//  Copyright © 2019 Ayden Panhuyzen. All rights reserved.
//

#import "ABVolumeHUDPassthroughView.h"

@implementation ABVolumeHUDPassthroughView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView *subview in self.subviews) {
        if ([subview pointInside:[self convertPoint:point toView:subview] withEvent:event]) return YES;
    }
    return NO;
}

@end
