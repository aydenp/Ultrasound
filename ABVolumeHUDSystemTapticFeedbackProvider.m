//
//  ABVolumeHUDSystemTapticFeedbackProvider.m
//  Ultrasound
//
//  Created by Ayden Panhuyzen on 10/8/18.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "ABVolumeHUDSystemTapticFeedbackProvider.h"

@implementation ABVolumeHUDSystemTapticFeedbackProvider {
    UIImpactFeedbackGenerator *generator;
}

- (id)init {
    self = [super init];
    if (self) {
        // support level: 0 = none, 1 = 6s, 2 = > 7 (new API)
        NSInteger tapticSupportLevel = [[[UIDevice currentDevice] valueForKey:@"_feedbackSupportLevel"] integerValue];
        if (tapticSupportLevel > 1) generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
    }
    return self;
}

- (void)actuate {
    if (generator) [generator impactOccurred];
    else AudioServicesPlaySystemSound(1519);
}

- (void)warmUp {
    if (generator) [generator prepare];
}

@end