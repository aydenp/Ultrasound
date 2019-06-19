//
//  ABVolumeHUDDeviceInfo.m
//  Ultrasound
//
//  Created by Ayden Panhuyzen on 8/27/18.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

#import "ABVolumeHUDDeviceInfo.h"
#import <sys/utsname.h>

@implementation ABVolumeHUDDeviceInfo

- (instancetype)initWithVolumeButtonTopOffset:(CGFloat)volumeButtonTopOffset andHeight:(CGFloat)volumeButtonHeight rightAlignControls:(BOOL)rightAlignControls hasOLEDScreen:(BOOL)hasOLEDScreen {
    self = [super init];
    if (self) {
        _volumeButtonTopOffset = volumeButtonTopOffset;
        _volumeButtonHeight = volumeButtonHeight;
        _rightAlignControls = rightAlignControls;
        _hasOLEDScreen = hasOLEDScreen;
    }
    return self;
}

- (instancetype)initWithVolumeButtonTopOffset:(CGFloat)volumeButtonTopOffset andHeight:(CGFloat)volumeButtonHeight rightAlignControls:(BOOL)rightAlignControls {
    return [self initWithVolumeButtonTopOffset:volumeButtonTopOffset andHeight:volumeButtonHeight rightAlignControls:rightAlignControls hasOLEDScreen:NO];
}

- (instancetype)initWithVolumeButtonTopOffset:(CGFloat)volumeButtonTopOffset andHeight:(CGFloat)volumeButtonHeight hasOLEDScreen:(BOOL)hasOLEDScreen {
    return [self initWithVolumeButtonTopOffset:volumeButtonTopOffset andHeight:volumeButtonHeight rightAlignControls:NO hasOLEDScreen:hasOLEDScreen];
}

- (instancetype)initWithVolumeButtonTopOffset:(CGFloat)volumeButtonTopOffset andHeight:(CGFloat)volumeButtonHeight {
    return [self initWithVolumeButtonTopOffset:volumeButtonTopOffset andHeight:volumeButtonHeight rightAlignControls:NO hasOLEDScreen:NO];
}

+ (instancetype)infoForCurrentDevice {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *model = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return [ABVolumeHUDDeviceInfo infoForDeviceModel:model];
}

+ (instancetype)infoForDeviceModel:(NSString *)model {
    NSString *group = @"";
    if ([model containsString:@"iPod"]) group = @"4-touch";
    else if ([model containsString:@"iPad"]) {
        // match iPads
        NSDictionary<NSString *, NSString *> *iPads = @{
            @"iPad4,1": @"9.7-ringer",
            @"iPad4,2": @"9.7-ringer",
            @"iPad4,3": @"9.7-ringer",
            @"iPad5,3": @"9.7",
            @"iPad5,4": @"9.7",
            @"iPad4,4": @"7.9-ringer",
            @"iPad4,5": @"7.9-ringer",
            @"iPad4,6": @"7.9-ringer",
            @"iPad4,7": @"7.9",
            @"iPad4,8": @"7.9",
            @"iPad4,9": @"7.9",
            @"iPad5,1": @"7.9",
            @"iPad5,2": @"7.9",
            @"iPad6,7": @"12.9",
            @"iPad6,8": @"12.9",
            @"iPad6,3": @"9.7",
            @"iPad6,4": @"9.7",
            @"iPad6,11": @"9.7",
            @"iPad6,12": @"9.7",
            @"iPad7,1": @"12.9",
            @"iPad7,2": @"12.9",
            @"iPad7,3": @"10.5",
            @"iPad7,4": @"10.5",
            @"iPad7,5": @"9.7",
            @"iPad7,6": @"9.7",
            @"iPad8,1": @"11-bezelless",
            @"iPad8,2": @"11-bezelless",
            @"iPad8,3": @"11-bezelless",
            @"iPad8,4": @"11-bezelless",
            @"iPad8,5": @"12.9-bezelless",
            @"iPad8,6": @"12.9-bezelless",
            @"iPad8,7": @"12.9-bezelless",
            @"iPad8,8": @"12.9-bezelless"
        };
        group = iPads[model];
        if (!group) group = @"10.5";
    } else {
        // match iPhones
        NSDictionary<NSString *, NSString *> *iPhones = @{
            @"iPhone6,1": @"4-round",
            @"iPhone6,2": @"4-round",
            @"iPhone7,2": @"4.7",
            @"iPhone7,1": @"5.5",
            @"iPhone8,1": @"4.7",
            @"iPhone8,2": @"5.5",
            @"iPhone8,4": @"4-round",
            @"iPhone9,1": @"4.7",
            @"iPhone9,2": @"5.5",
            @"iPhone9,3": @"4.7",
            @"iPhone9,4": @"5.5",
            @"iPhone10,1": @"4.7",
            @"iPhone10,2": @"5.5",
            @"iPhone10,3": @"X",
            @"iPhone10,4": @"4.7",
            @"iPhone10,5": @"5.5",
            @"iPhone10,6": @"X",
            @"iPhone11,2": @"X",
            @"iPhone11,4": @"X", // actually Xs Max but positioning is same
            @"iPhone11,6": @"X", // actually Xs Max but positioning is same
            @"iPhone11,8": @"Xr"
        };
        group = iPhones[model];
    }
    return [ABVolumeHUDDeviceInfo infoForDeviceGroup:group];
}

+ (instancetype)infoForDeviceGroup:(NSString *)group {
    if ([group isEqualToString:@"4-round"]) return [ABVolumeHUDDeviceInfo infoFor4Inch];
    else if ([group isEqualToString:@"4.7"]) return [ABVolumeHUDDeviceInfo infoFor47Inch];
    else if ([group isEqualToString:@"5.5"]) return [ABVolumeHUDDeviceInfo infoFor55Inch];
    else if ([group isEqualToString:@"4-touch"]) return [ABVolumeHUDDeviceInfo infoFor4InchTouch];
    else if ([group isEqualToString:@"9.7-ringer"]) return [ABVolumeHUDDeviceInfo infoFor97InchWithRinger];
    else if ([group isEqualToString:@"9.7"]) return [ABVolumeHUDDeviceInfo infoFor97Inch];
    else if ([group isEqualToString:@"10.5"]) return [ABVolumeHUDDeviceInfo infoFor105Inch];
    else if ([group isEqualToString:@"11-bezelless"]) return [ABVolumeHUDDeviceInfo infoFor11Inch];
    else if ([group isEqualToString:@"12.9"]) return [ABVolumeHUDDeviceInfo infoFor129Inch];
    else if ([group isEqualToString:@"12.9-bezelless"]) return [ABVolumeHUDDeviceInfo infoFor129InchWithoutBezels];
    else if ([group isEqualToString:@"7.9-ringer"]) return [ABVolumeHUDDeviceInfo infoFor79InchWithRinger];
    else if ([group isEqualToString:@"7.9"]) return [ABVolumeHUDDeviceInfo infoFor79Inch];
    else if ([group isEqualToString:@"Xr"]) return [ABVolumeHUDDeviceInfo infoForXr];
    else return [ABVolumeHUDDeviceInfo infoForX];
}

+ (instancetype)infoFor4Inch {
    return [[ABVolumeHUDDeviceInfo alloc] initWithVolumeButtonTopOffset:71 andHeight:94];
}

+ (instancetype)infoFor47Inch {
    return [[ABVolumeHUDDeviceInfo alloc] initWithVolumeButtonTopOffset:79 andHeight:145];
}

+ (instancetype)infoFor55Inch {
    return [[ABVolumeHUDDeviceInfo alloc] initWithVolumeButtonTopOffset:74 andHeight:137];
}

+ (instancetype)infoForX {
    return [[ABVolumeHUDDeviceInfo alloc] initWithVolumeButtonTopOffset:153 andHeight:139 hasOLEDScreen:YES];
}

+ (instancetype)infoForXr {
    return [[ABVolumeHUDDeviceInfo alloc] initWithVolumeButtonTopOffset:163 andHeight:149 hasOLEDScreen:NO];
}

+ (instancetype)infoFor4InchTouch {
    return [[ABVolumeHUDDeviceInfo alloc] initWithVolumeButtonTopOffset:0 andHeight:126];
}

+ (instancetype)infoFor97InchWithRinger {
    return [[ABVolumeHUDDeviceInfo alloc] initWithVolumeButtonTopOffset:55 andHeight:116 rightAlignControls:YES];
}

+ (instancetype)infoFor97Inch {
    return [[ABVolumeHUDDeviceInfo alloc] initWithVolumeButtonTopOffset:0 andHeight:125 rightAlignControls:YES];
}

+ (instancetype)infoFor105Inch {
    return [[ABVolumeHUDDeviceInfo alloc] initWithVolumeButtonTopOffset:22 andHeight:138 rightAlignControls:YES];
}

+ (instancetype)infoFor11Inch {
    return [[ABVolumeHUDDeviceInfo alloc] initWithVolumeButtonTopOffset:56 andHeight:112 rightAlignControls:YES];
}

+ (instancetype)infoFor129Inch {
    return [[ABVolumeHUDDeviceInfo alloc] initWithVolumeButtonTopOffset:0 andHeight:125 rightAlignControls:YES];
}

+ (instancetype)infoFor129InchWithoutBezels {
    return [[ABVolumeHUDDeviceInfo alloc] initWithVolumeButtonTopOffset:54 andHeight:114 rightAlignControls:YES];
}

+ (instancetype)infoFor79InchWithRinger {
    return [[ABVolumeHUDDeviceInfo alloc] initWithVolumeButtonTopOffset:76 andHeight:138 rightAlignControls:YES];
}

+ (instancetype)infoFor79Inch {
    return [[ABVolumeHUDDeviceInfo alloc] initWithVolumeButtonTopOffset:0 andHeight:153 rightAlignControls:YES];
}

@end
