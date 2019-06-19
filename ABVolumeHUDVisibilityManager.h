//
//  ABVolumeHUDVisibilityManager.h
//  Ultrasound
//
//  Created by Ayden Panhuyzen on 8/27/18.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ABVolumeHUDVisibilityManagerDelegate <NSObject>
- (void)shouldChangeVolumeHUDVisibleTo:(BOOL)visible;
@end

@interface ABVolumeHUDVisibilityManager : NSObject
/// A delegate to conform to that will notify of the desired state.
@property (nonatomic, weak) NSObject <ABVolumeHUDVisibilityManagerDelegate>*delegate;
/// The volume HUD should be shown (or the timer restarted).
- (void)showVolumeHUD;
/// The volume HUD's hide timer should be restarted if it is already showing.
- (void)restartIdleTimer;
/// Immediately hide the HUD, if possible.
- (void)hideImmediatelyIfPossible;
/// Request that the display be held for a reason, such as active touches.
- (void)prolongDisplayForReason:(NSString *)reason;
/// Remove a prior request to hold display.
- (void)releaseProlongedDisplayForReason:(NSString *)reason;
@end

NS_ASSUME_NONNULL_END
