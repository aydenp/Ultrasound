//
//  ABVolumeHUDSystemTapticFeedbackProvider.m
//  Ultrasound
//
//  Created by Ayden Panhuyzen on 10/8/18.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

#import "Headers.h"
#import "ABVolumeHUDSystemTapticFeedbackProvider.h"

#define kTapticFeedbackReason @"kABVolumeHUDSystemTapticFeedbackProviderRequestedWarmUpReason"
#define kTapticFeedbackMask 0x6

@implementation ABVolumeHUDSystemTapticFeedbackProvider {
    SBFTapticEngine *engine;
}

- (id)init {
    self = [super init];
    if (self) {
        engine = [NSClassFromString(@"SBFTapticEngine") sharedInstance];
    }
    return self;
}

- (void)actuate {
    [engine actuateFeedback:0x0];
}

- (void)warmUp {
    [engine warmUpForFeedback:kTapticFeedbackMask withReason:kTapticFeedbackReason];
}

- (void)coolDown {
    [engine coolDownForFeedback:kTapticFeedbackMask withReason:kTapticFeedbackReason];
}

@end