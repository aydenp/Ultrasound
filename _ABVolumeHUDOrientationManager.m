//
//  _ABVolumeHUDOrientationManager.m
//  Ultrasound
//
//  Created by Ayden Panhuyzen on 2019-03-02.
//  Copyright © 2018 Ayden Panhuyzen. All rights reserved.
//

#import "_ABVolumeHUDOrientationManager.h"

@implementation _ABVolumeHUDOrientationManager

-(void)activeInterfaceOrientationWillChangeToOrientation:(UIInterfaceOrientation)orientation {}

-(void)activeInterfaceOrientationDidChangeToOrientation:(UIInterfaceOrientation)orientation willAnimateWithDuration:(NSTimeInterval)duration fromOrientation:(UIInterfaceOrientation)previousOrientation {
    [ABVolumeHUDManager sharedManager].orientation = orientation;
}

@end