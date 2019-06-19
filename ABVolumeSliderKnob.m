//
//  ABVolumeSliderKnob.m
//  Ultrasound
//
//  Created by Ayden Panhuyzen on 8/27/18.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

#import "ABVolumeSliderKnob.h"

@implementation ABVolumeSliderKnob

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupForDisplay];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = fmin(self.bounds.size.width, self.bounds.size.height) / 2;
}

- (void)setupForDisplay {
    self.userInteractionEnabled = NO;
    self.backgroundColor = [UIColor whiteColor];
    self.layer.shadowRadius = 2;
    self.layer.shadowOffset = CGSizeMake(0, 2);
    self.layer.shadowOpacity = 0.2;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    [self.heightAnchor constraintEqualToConstant:10].active = YES;
    [self.widthAnchor constraintEqualToAnchor:self.heightAnchor].active = YES;
}

- (void)setHasShadow:(BOOL)hasShadow {
    _hasShadow = hasShadow;
    self.layer.shadowOpacity = hasShadow ? 0.2 : 0;
}

@end
