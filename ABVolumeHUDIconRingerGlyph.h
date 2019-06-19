//
//  ABVolumeHUDIconRingerGlyph.h
//  Ultrasound
//
//  Created by Ayden Panhuyzen on 9/3/18.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ABVolumeHUDIconGlyphProviding.h"

@interface ABVolumeHUDIconRingerGlyph : UIView <ABVolumeHUDIconGlyphProviding>
- (void)setVolume:(CGFloat)volume;
@end
