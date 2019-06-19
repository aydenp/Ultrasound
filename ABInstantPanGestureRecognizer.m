//
//  ABInstantPanGestureRecognizer.m
//  Ultrasound
//
//  Created by Ayden Panhuyzen on 2018-09-09.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

#import "ABInstantPanGestureRecognizer.h"

@implementation ABInstantPanGestureRecognizer

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if (self.numberOfTouches < self.minimumNumberOfTouches) return;
    self.state = UIGestureRecognizerStateBegan;
}


- (void)setState:(UIGestureRecognizerState)state {
    if (state == UIGestureRecognizerStateBegan && state == self.state) return;
    [super setState:state];
}

- (BOOL)isBeingTouched {
    return self.state == UIGestureRecognizerStateBegan || self.state == UIGestureRecognizerStateChanged;
}

@end
