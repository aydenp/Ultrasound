//
//  ABVolumeHUDSystemVolumeInfoProvider.m
//  Ultrasound
//
//  Created by Ayden Panhuyzen on 10/8/18.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

#import "Headers.h"
#import "ABVolumeHUDSystemVolumeInfoProvider.h"

@implementation ABVolumeHUDSystemVolumeInfoProvider

- (CGFloat)volumeForVolumeMode:(ABVolumeHUDVolumeMode)mode {
    if (mode == ABVolumeHUDVolumeModeRinger) {
        float volume;
        if (![[NSClassFromString(@"AVSystemController") sharedAVSystemController] getVolume:&volume forCategory:@"Ringtone"]) return -1;
        return (CGFloat)volume;
    }
    return (CGFloat)[[NSClassFromString(@"VolumeControl") sharedVolumeControl] getMediaVolume];
}

@end