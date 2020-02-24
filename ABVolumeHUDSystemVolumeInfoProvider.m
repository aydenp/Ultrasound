//
//  ABVolumeHUDSystemVolumeInfoProvider.m
//  Ultrasound
//
//  Created by Ayden Panhuyzen on 10/8/18.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

#import "ABVolumeHUDSystemVolumeInfoProvider.h"

@implementation ABVolumeHUDSystemVolumeInfoProvider

- (CGFloat)volumeForVolumeMode:(ABVolumeHUDVolumeMode)mode {
    if (mode == ABVolumeHUDVolumeModeRinger) {
        float volume;
        if (![[NSClassFromString(@"AVSystemController") sharedAVSystemController] getVolume:&volume forCategory:@"Ringtone"]) return -1;
        return (CGFloat)volume;
    }
    VolumeControl *control = [ABVolumeHUDSystemVolumeInfoProvider activeVolumeControl];
    return [control respondsToSelector:@selector(_getMediaVolumeForIAP)] ? [control _getMediaVolumeForIAP] : [control getMediaVolume];
}

+ (VolumeControl *)activeVolumeControl {
    Class iOS12Class = NSClassFromString(@"VolumeControl");
    if (iOS12Class && [iOS12Class respondsToSelector:@selector(sharedVolumeControl)]) return [iOS12Class sharedVolumeControl];

    Class iOS13Class = NSClassFromString(@"SBVolumeControl");
    if (iOS13Class && [iOS13Class respondsToSelector:@selector(sharedInstance)]) return [iOS13Class sharedInstance];

    return nil;
}

@end