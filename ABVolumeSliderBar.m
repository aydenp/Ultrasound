//
//  ABVolumeSliderBar.m
//  Ultrasound
//
//  Created by Ayden Panhuyzen on 8/27/18.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

#import "ABVolumeSliderBar.h"

@implementation ABVolumeSliderBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupForDisplay];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = self.bounds.size.width / 2;
}

- (void)setupForDisplay {
    self.userInteractionEnabled = NO;
    [self.widthAnchor constraintEqualToConstant:4].active = YES;
    self.clipsToBounds = YES;
}

@end
