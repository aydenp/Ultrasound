//
//  ABVolumeHUDVisibilityManager.m
//  Ultrasound
//
//  Created by Ayden Panhuyzen on 8/27/18.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

#import "ABVolumeHUDVisibilityManager.h"
#import "ABVolumeHUDViewSettings.h"

@implementation ABVolumeHUDVisibilityManager {
    NSMutableSet <NSString *>*prolongedDisplayRequests;
    NSTimer *hideTimer;
    BOOL _visible;
}

- (void)showVolumeHUD {
    NSLog(@"Visibility manager instructed to show volume HUD.");
    [self changeVisibleTo:YES];
    [self evaluateTimerStart];
}

- (void)restartIdleTimer {
    if (!_visible) return;
    [self showVolumeHUD];
}

- (void)hideImmediatelyIfPossible {
    if (!_visible) return;
    [self attemptToHide];
}

- (void)prolongDisplayForReason:(NSString *)reason {
    NSLog(@"Visibility manager asked to prolong display for reason: %@", reason);
    [self stopTimerIfActive];
    [prolongedDisplayRequests addObject:reason];
}

- (void)releaseProlongedDisplayForReason:(NSString *)reason {
    NSLog(@"Visibility manager asked to release prolonged display for reason: %@", reason);
    [prolongedDisplayRequests removeObject:reason];
    [self evaluateTimerStart];
}

- (void)evaluateTimerStart {
    [self stopTimerIfActive];
    if (prolongedDisplayRequests.count > 0) return;
    hideTimer = [NSTimer scheduledTimerWithTimeInterval:[ABVolumeHUDViewSettings sharedSettings].timeout target:self selector:@selector(tick) userInfo:nil repeats:NO];
}

- (void)stopTimerIfActive {
    if (hideTimer) [hideTimer invalidate];
    hideTimer = nil;
}

- (void)changeVisibleTo:(BOOL)visible {
    _visible = visible;
    if (!self.delegate) return;
    [self.delegate shouldChangeVolumeHUDVisibleTo:visible];
}

- (void)attemptToHide {
    if (prolongedDisplayRequests.count > 0) return;
    [self changeVisibleTo:NO];
}

- (void)tick {
    [self attemptToHide];
}
                                                                 
@end
